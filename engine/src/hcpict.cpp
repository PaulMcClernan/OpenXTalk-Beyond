/* Copyright (C) 2026 OXT-Beyond contributors.

This file is part of OXT-Beyond, a fork of LiveCode Community.

LiveCode is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License v3 as published by the Free
Software Foundation.

LiveCode is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with LiveCode.  If not see <http://www.gnu.org/licenses/>.  */

// A QuickDraw picture decoder, written from Inside Macintosh: Imaging With
// QuickDraw (1994), appendix A "Picture Opcodes", and chapter 4 (CopyBits,
// PixMap, PackBits). It draws what HyperCard stacks hold in their PICT
// resources: bitmaps and pixel maps (BitsRect, PackBitsRect, BitsRgn,
// PackBitsRgn, DirectBitsRect, DirectBitsRgn; 1 to 32 bits a pixel), and
// QuickDraw's shapes (lines, rectangles, rounded rectangles, ovals, arcs,
// polygons and regions, framed, painted, erased, inverted or filled with
// 8x8 patterns). Text and embedded QuickTime images are skipped, and
// reported in r_skipped.

#include "hcpict.h"

#include <string.h>
#include <math.h>
#include <new>

namespace
{

// The largest picture drawn, in pixels a side: a card is 512x342 to
// 1280x1024, and a scan or a poster rarely more than this.
const int32_t kMaxSide = 8192;

struct Rect
{
	int32_t top, left, bottom, right;
	int32_t width() const { return right - left; }
	int32_t height() const { return bottom - top; }
	bool empty() const { return right <= left || bottom <= top; }
};

struct Reader
{
	const uint8_t *data;
	uint32_t size;
	uint32_t pos;
	bool ok;

	bool need(uint32_t n)
	{
		if (!ok || n > size - pos)
		{
			ok = false;
			return false;
		}
		return true;
	}
	uint8_t u8()
	{
		if (!need(1))
			return 0;
		return data[pos++];
	}
	uint16_t u16()
	{
		if (!need(2))
			return 0;
		uint16_t v = (uint16_t)((data[pos] << 8) | data[pos + 1]);
		pos += 2;
		return v;
	}
	int16_t s16()
	{
		return (int16_t)u16();
	}
	uint32_t u32()
	{
		uint32_t hi = u16();
		return (hi << 16) | u16();
	}
	void skip(uint32_t n)
	{
		if (need(n))
			pos += n;
	}
	const uint8_t *take(uint32_t n)
	{
		if (!need(n))
			return NULL;
		const uint8_t *p = data + pos;
		pos += n;
		return p;
	}
	Rect rect()
	{
		Rect r;
		r.top = s16();
		r.left = s16();
		r.bottom = s16();
		r.right = s16();
		return r;
	}
};

// A region: its bounds and, for each row, the spans inside it.
struct Region
{
	Rect bounds;
	// one entry per row of bounds: the start of its spans in xs
	int32_t *rowstart;
	int32_t *xs;
	uint32_t nxs;
	bool rectangular;

	Region() : rowstart(NULL), xs(NULL), nxs(0), rectangular(true)
	{
		bounds.top = bounds.left = bounds.bottom = bounds.right = 0;
	}
	~Region()
	{
		delete[] rowstart;
		delete[] xs;
	}
	void clear()
	{
		delete[] rowstart;
		delete[] xs;
		rowstart = NULL;
		xs = NULL;
		nxs = 0;
		rectangular = true;
	}
};

// Read a region (size, bounds, then for a non-rectangular one its
// inversion points: row, xs..., 0x7FFF, ..., 0x7FFF).
bool read_region(Reader &r, Region &rgn)
{
	rgn.clear();
	uint32_t t_start = r.pos;
	uint16_t t_size = r.u16();
	rgn.bounds = r.rect();
	if (!r.ok || t_size < 10)
		return false;
	uint32_t t_end = t_start + t_size;
	if (t_end > r.size)
	{
		r.ok = false;
		return false;
	}
	if (t_size == 10 || rgn.bounds.empty())
	{
		r.pos = t_end;
		return true;
	}
	int32_t t_height = rgn.bounds.height();
	if (t_height > kMaxSide * 4 || rgn.bounds.width() > kMaxSide * 4)
	{
		r.pos = t_end;
		return true;
	}
	rgn.rectangular = false;
	// The inversion points of each row are toggled into the current set;
	// the spans of a row are the set's points taken in pairs.
	const uint32_t kMaxPoints = 4096;
	int32_t *t_current = new (std::nothrow) int32_t[kMaxPoints];
	uint32_t t_ncurrent = 0;
	uint32_t t_capacity = 1024;
	rgn.xs = new (std::nothrow) int32_t[t_capacity];
	rgn.rowstart = new (std::nothrow) int32_t[t_height + 1];
	if (t_current == NULL || rgn.xs == NULL || rgn.rowstart == NULL)
	{
		delete[] t_current;
		rgn.clear();
		r.pos = t_end;
		return false;
	}
	int32_t t_row = rgn.bounds.top;
	bool t_done = false;
	while (!t_done)
	{
		int32_t t_next_row;
		if (r.pos + 2 > t_end)
			t_next_row = rgn.bounds.bottom;
		else
		{
			t_next_row = r.s16();
			if (t_next_row == 0x7FFF)
			{
				t_next_row = rgn.bounds.bottom;
				t_done = true;
			}
		}
		if (t_next_row > rgn.bounds.bottom)
			t_next_row = rgn.bounds.bottom;
		// rows up to the next entry repeat the current set
		for (; t_row < t_next_row ; t_row++)
		{
			int32_t t_index = t_row - rgn.bounds.top;
			if (t_index < 0)
				continue;
			rgn.rowstart[t_index] = (int32_t)rgn.nxs;
			if (rgn.nxs + t_ncurrent > t_capacity)
			{
				uint32_t t_new_capacity = (rgn.nxs + t_ncurrent) * 2;
				int32_t *t_new = new (std::nothrow) int32_t[t_new_capacity];
				if (t_new == NULL)
				{
					delete[] t_current;
					rgn.clear();
					r.pos = t_end;
					return false;
				}
				memcpy(t_new, rgn.xs, rgn.nxs * sizeof(int32_t));
				delete[] rgn.xs;
				rgn.xs = t_new;
				t_capacity = t_new_capacity;
			}
			memcpy(rgn.xs + rgn.nxs, t_current, t_ncurrent * sizeof(int32_t));
			rgn.nxs += t_ncurrent;
		}
		if (t_done || r.pos + 2 > t_end)
			break;
		// toggle this entry's points into the set, kept sorted
		for (;;)
		{
			if (r.pos + 2 > t_end)
			{
				t_done = true;
				break;
			}
			int32_t x = r.s16();
			if (x == 0x7FFF)
				break;
			uint32_t i = 0;
			while (i < t_ncurrent && t_current[i] < x)
				i++;
			if (i < t_ncurrent && t_current[i] == x)
			{
				memmove(&t_current[i], &t_current[i + 1], (t_ncurrent - i - 1) * sizeof(int32_t));
				t_ncurrent--;
			}
			else if (t_ncurrent < kMaxPoints)
			{
				memmove(&t_current[i + 1], &t_current[i], (t_ncurrent - i) * sizeof(int32_t));
				t_current[i] = x;
				t_ncurrent++;
			}
		}
	}
	for (; t_row < rgn.bounds.bottom ; t_row++)
		rgn.rowstart[t_row - rgn.bounds.top] = (int32_t)rgn.nxs;
	rgn.rowstart[t_height] = (int32_t)rgn.nxs;
	delete[] t_current;
	r.pos = t_end;
	return r.ok;
}

// Pixel transfer modes
enum
{
	kSrcCopy = 0, kSrcOr = 1, kSrcXor = 2, kSrcBic = 3,
	kNotSrcCopy = 4, kNotSrcOr = 5, kNotSrcXor = 6, kNotSrcBic = 7,
	kPatCopy = 8, kPatOr = 9, kPatXor = 10, kPatBic = 11,
	kNotPatCopy = 12, kNotPatOr = 13, kNotPatXor = 14, kNotPatBic = 15,
	kTransparent = 36,
};

const uint32_t kBlack = 0xFF000000;
const uint32_t kWhite = 0xFFFFFFFF;

uint32_t rgb48(uint16_t r, uint16_t g, uint16_t b)
{
	return 0xFF000000 | ((uint32_t)(r >> 8) << 16) | ((uint32_t)(g >> 8) << 8) | (uint32_t)(b >> 8);
}

// The eight colours of the original QuickDraw (FgColor, BkColor)
uint32_t old_colour(uint32_t p_colour)
{
	switch (p_colour)
	{
	case 30: return kWhite;
	case 69: return 0xFFFCF305;   // yellow
	case 137: return 0xFFF20884;  // magenta
	case 205: return 0xFFDD0806;  // red
	case 273: return 0xFF02ABEA;  // cyan
	case 341: return 0xFF1FB714;  // green
	case 409: return 0xFF0000D4;  // blue
	default: return kBlack;
	}
}

struct Canvas
{
	uint32_t *pixels;
	int32_t width, height;
	// picture coordinates to canvas pixels: x' = (x - ox) * sx_num / sx_den
	Rect source;
	int32_t originx, originy;
	Rect clip;

	int32_t cx(int32_t x) const
	{
		int64_t t = (int64_t)(x - originx - source.left) * width;
		return (int32_t)(t >= 0 ? t / source.width() : -((-t + source.width() - 1) / source.width()));
	}
	int32_t cy(int32_t y) const
	{
		int64_t t = (int64_t)(y - originy - source.top) * height;
		return (int32_t)(t >= 0 ? t / source.height() : -((-t + source.height() - 1) / source.height()));
	}
	Rect crect(const Rect &r) const
	{
		Rect c;
		c.top = cy(r.top);
		c.left = cx(r.left);
		c.bottom = cy(r.bottom);
		c.right = cx(r.right);
		return c;
	}
	bool scaled() const
	{
		return source.width() != width || source.height() != height;
	}
};

struct Pattern
{
	uint8_t bits[8];
};

struct State
{
	int version;
	Pattern pen, back, fill;
	int32_t penw, penh;
	int32_t penmode;
	int32_t penx, peny;
	uint32_t fg, bg;
	int32_t ovalw, ovalh;
	Rect lastrect, lastrrect, lastoval, lastarc;
	int32_t arcstart, arcangle;
	uint32_t skipped;
};

void set_pattern(Pattern &p, uint8_t v)
{
	memset(p.bits, v, 8);
}

// The ways a shape is drawn
enum Verb { kFrame, kPaint, kErase, kInvert, kFill };

// Draw the span [x0, x1) of row y with a verb's pattern and mode
void draw_span(Canvas &c, const State &s, Verb verb, int32_t y, int32_t x0, int32_t x1)
{
	if (y < c.clip.top || y >= c.clip.bottom)
		return;
	if (x0 < c.clip.left)
		x0 = c.clip.left;
	if (x1 > c.clip.right)
		x1 = c.clip.right;
	if (x0 >= x1)
		return;
	uint32_t *row = c.pixels + (size_t)y * c.width;
	if (verb == kInvert)
	{
		for (int32_t x = x0 ; x < x1 ; x++)
			row[x] ^= 0x00FFFFFF;
		return;
	}
	const Pattern *pat;
	int32_t mode;
	uint32_t fg = s.fg, bg = s.bg;
	switch (verb)
	{
	case kErase:
		pat = &s.back;
		mode = kPatCopy;
		// erasing draws the background pattern in the background colour
		fg = s.bg;
		break;
	case kFill:
		pat = &s.fill;
		mode = kPatCopy;
		break;
	default:
		pat = &s.pen;
		mode = s.penmode;
		break;
	}
	uint8_t bits = pat->bits[y & 7];
	for (int32_t x = x0 ; x < x1 ; x++)
	{
		bool on = ((bits >> (7 - (x & 7))) & 1) != 0;
		switch (mode & 0x0F)
		{
		case kPatCopy: case kSrcCopy: row[x] = on ? fg : bg; break;
		case kPatOr: case kSrcOr: if (on) row[x] = fg; break;
		case kPatXor: case kSrcXor: if (on) row[x] ^= 0x00FFFFFF; break;
		case kPatBic: case kSrcBic: if (on) row[x] = bg; break;
		case kNotPatCopy: case kNotSrcCopy: row[x] = on ? bg : fg; break;
		case kNotPatOr: case kNotSrcOr: if (!on) row[x] = fg; break;
		case kNotPatXor: case kNotSrcXor: if (!on) row[x] ^= 0x00FFFFFF; break;
		case kNotPatBic: case kNotSrcBic: if (!on) row[x] = bg; break;
		}
	}
}

// The rows of r that the clip lets through
void clip_rows(const Canvas &c, const Rect &r, int32_t &y0, int32_t &y1)
{
	y0 = r.top < c.clip.top ? c.clip.top : r.top;
	y1 = r.bottom > c.clip.bottom ? c.clip.bottom : r.bottom;
}

// The half-width of an ellipse of radii (rx, ry) at a distance dy from its
// centre
double half_width(double rx, double ry, double dy)
{
	if (ry <= 0 || fabs(dy) >= ry)
		return -1;
	return rx * sqrt(1.0 - (dy * dy) / (ry * ry));
}

// The span of a rounded rectangle's row (an oval when the corners are as
// large as the rectangle): false if the row is outside it
bool rrect_span(const Rect &r, int32_t ow, int32_t oh, int32_t y, int32_t &x0, int32_t &x1)
{
	if (y < r.top || y >= r.bottom || r.empty())
		return false;
	if (ow > r.width())
		ow = r.width();
	if (oh > r.height())
		oh = r.height();
	x0 = r.left;
	x1 = r.right;
	if (ow <= 0 || oh <= 0)
		return true;
	double ry = oh / 2.0, rx = ow / 2.0;
	double yc = y + 0.5;
	double dy;
	if (yc < r.top + ry)
		dy = r.top + ry - yc;
	else if (yc > r.bottom - ry)
		dy = yc - (r.bottom - ry);
	else
		return true;
	double hw = half_width(rx, ry, dy);
	if (hw < 0)
		return false;
	int32_t inset = (int32_t)floor(rx - hw + 0.5);
	x0 = r.left + inset;
	x1 = r.right - inset;
	return x0 < x1;
}

// Draw a rounded rectangle (ovals and plain rectangles are kinds of it)
void draw_rrect(Canvas &c, const State &s, Verb verb, const Rect &pr, int32_t pow, int32_t poh)
{
	Rect r = c.crect(pr);
	int32_t ow = c.cx(pr.left + pow) - c.cx(pr.left);
	int32_t oh = c.cy(pr.top + poh) - c.cy(pr.top);
	if (r.empty())
		return;
	int32_t t_y0, t_y1;
	clip_rows(c, r, t_y0, t_y1);
	if (verb != kFrame)
	{
		for (int32_t y = t_y0 ; y < t_y1 ; y++)
		{
			int32_t x0, x1;
			if (rrect_span(r, ow, oh, y, x0, x1))
				draw_span(c, s, verb, y, x0, x1);
		}
		return;
	}
	// a frame is the shape less the same shape inset by the pen
	int32_t pw = c.cx(pr.left + s.penw) - c.cx(pr.left);
	int32_t ph = c.cy(pr.top + s.penh) - c.cy(pr.top);
	if (pw <= 0 || ph <= 0)
		return;
	Rect inner = r;
	inner.top += ph;
	inner.left += pw;
	inner.bottom -= ph;
	inner.right -= pw;
	int32_t iow = ow - 2 * pw, ioh = oh - 2 * ph;
	for (int32_t y = t_y0 ; y < t_y1 ; y++)
	{
		int32_t x0, x1, i0, i1;
		if (!rrect_span(r, ow, oh, y, x0, x1))
			continue;
		if (inner.empty() || !rrect_span(inner, iow > 0 ? iow : 0, ioh > 0 ? ioh : 0, y, i0, i1))
			draw_span(c, s, verb, y, x0, x1);
		else
		{
			draw_span(c, s, verb, y, x0, i0);
			draw_span(c, s, verb, y, i1, x1);
		}
	}
}

// QuickDraw's angle of a point from the centre of a rectangle: 0 at the
// top, growing clockwise, 45 at the top right corner whatever its shape
double arc_angle_of(double dx, double dy, double rx, double ry)
{
	double a = atan2(dx / rx, -dy / ry) * 180.0 / M_PI;
	if (a < 0)
		a += 360.0;
	return a;
}

bool in_arc(double a, int32_t start, int32_t extent)
{
	if (extent == 0)
		return false;
	if (extent >= 360 || extent <= -360)
		return true;
	double s = start, e = extent;
	if (e < 0)
	{
		s += e;
		e = -e;
	}
	s = fmod(s, 360.0);
	if (s < 0)
		s += 360.0;
	double d = a - s;
	if (d < 0)
		d += 360.0;
	return d < e;
}

void draw_arc(Canvas &c, const State &s, Verb verb, const Rect &pr, int32_t start, int32_t extent)
{
	Rect r = c.crect(pr);
	if (r.empty())
		return;
	double rx = r.width() / 2.0, ry = r.height() / 2.0;
	double xc = r.left + rx, ycen = r.top + ry;
	int32_t pw = verb == kFrame ? c.cx(pr.left + s.penw) - c.cx(pr.left) : 0;
	int32_t ph = verb == kFrame ? c.cy(pr.top + s.penh) - c.cy(pr.top) : 0;
	if (verb == kFrame && (pw <= 0 || ph <= 0))
		return;
	int32_t t_y0, t_y1;
	clip_rows(c, r, t_y0, t_y1);
	for (int32_t y = t_y0 ; y < t_y1 ; y++)
	{
		int32_t x0, x1;
		if (!rrect_span(r, r.width(), r.height(), y, x0, x1))
			continue;
		if (x0 < c.clip.left)
			x0 = c.clip.left;
		if (x1 > c.clip.right)
			x1 = c.clip.right;
		Rect inner = r;
		inner.top += ph;
		inner.left += pw;
		inner.bottom -= ph;
		inner.right -= pw;
		int32_t i0 = 0, i1 = 0;
		bool t_have_inner = verb == kFrame && !inner.empty()
		                    && rrect_span(inner, inner.width(), inner.height(), y, i0, i1);
		// runs of pixels inside the wedge
		int32_t t_run = -1;
		for (int32_t x = x0 ; x <= x1 ; x++)
		{
			bool on = false;
			if (x < x1 && !(t_have_inner && x >= i0 && x < i1))
				on = in_arc(arc_angle_of(x + 0.5 - xc, y + 0.5 - ycen, rx, ry), start, extent);
			if (on && t_run < 0)
				t_run = x;
			else if (!on && t_run >= 0)
			{
				draw_span(c, s, verb, y, t_run, x);
				t_run = -1;
			}
		}
	}
}

// A line, drawn as QuickDraw does: the pen, a rectangle hanging below and
// to the right of the point, at every point of the line
void draw_line(Canvas &c, const State &s, int32_t px0, int32_t py0, int32_t px1, int32_t py1)
{
	if (s.penw <= 0 || s.penh <= 0)
		return;
	int32_t x0 = c.cx(px0), y0 = c.cy(py0), x1 = c.cx(px1), y1 = c.cy(py1);
	int32_t pw = c.cx(px0 + s.penw) - x0, ph = c.cy(py0 + s.penh) - y0;
	if (pw <= 0)
		pw = 1;
	if (ph <= 0)
		ph = 1;
	int32_t dx = x1 > x0 ? x1 - x0 : x0 - x1;
	int32_t dy = y1 > y0 ? y1 - y0 : y0 - y1;
	int32_t sx = x0 < x1 ? 1 : -1, sy = y0 < y1 ? 1 : -1;
	int32_t err = dx - dy;
	// a pen wider than a pixel: one rectangle per point
	int32_t n = 0;
	for (;;)
	{
		for (int32_t y = y0 ; y < y0 + ph ; y++)
			draw_span(c, s, kPaint, y, x0, x0 + pw);
		if ((x0 == x1 && y0 == y1) || ++n > kMaxSide * 4)
			break;
		int32_t e2 = 2 * err;
		if (e2 > -dy)
		{
			err -= dy;
			x0 += sx;
		}
		if (e2 < dx)
		{
			err += dx;
			y0 += sy;
		}
	}
}

struct Polygon
{
	int32_t npoints;
	int32_t *xs, *ys;
	Polygon() : npoints(0), xs(NULL), ys(NULL) {}
	~Polygon()
	{
		delete[] xs;
		delete[] ys;
	}
};

bool read_polygon(Reader &r, Polygon &poly)
{
	uint32_t t_start = r.pos;
	uint16_t t_size = r.u16();
	r.rect();
	if (!r.ok || t_size < 10 || t_start + t_size > r.size)
	{
		r.ok = false;
		return false;
	}
	delete[] poly.xs;
	delete[] poly.ys;
	poly.npoints = (t_size - 10) / 4;
	poly.xs = new (std::nothrow) int32_t[poly.npoints + 1];
	poly.ys = new (std::nothrow) int32_t[poly.npoints + 1];
	if (poly.xs == NULL || poly.ys == NULL)
	{
		poly.npoints = 0;
		r.pos = t_start + t_size;
		return false;
	}
	for (int32_t i = 0 ; i < poly.npoints ; i++)
	{
		poly.ys[i] = r.s16();
		poly.xs[i] = r.s16();
	}
	r.pos = t_start + t_size;
	return r.ok;
}

void draw_polygon(Canvas &c, const State &s, Verb verb, const Polygon &poly)
{
	if (poly.npoints < 2)
		return;
	if (verb == kFrame)
	{
		for (int32_t i = 0 ; i + 1 < poly.npoints ; i++)
			draw_line(c, s, poly.xs[i], poly.ys[i], poly.xs[i + 1], poly.ys[i + 1]);
		return;
	}
	int32_t miny = INT32_MAX, maxy = INT32_MIN;
	int32_t *cxs = new (std::nothrow) int32_t[poly.npoints];
	int32_t *cys = new (std::nothrow) int32_t[poly.npoints];
	int32_t *crossings = new (std::nothrow) int32_t[poly.npoints + 1];
	if (cxs == NULL || cys == NULL || crossings == NULL)
	{
		delete[] cxs;
		delete[] cys;
		delete[] crossings;
		return;
	}
	for (int32_t i = 0 ; i < poly.npoints ; i++)
	{
		cxs[i] = c.cx(poly.xs[i]);
		cys[i] = c.cy(poly.ys[i]);
		if (cys[i] < miny)
			miny = cys[i];
		if (cys[i] > maxy)
			maxy = cys[i];
	}
	if (miny < c.clip.top)
		miny = c.clip.top;
	if (maxy > c.clip.bottom)
		maxy = c.clip.bottom;
	// even-odd, sampled at the centres of the pixels; the polygon is
	// closed back to its first point
	for (int32_t y = miny ; y < maxy ; y++)
	{
		double yc = y + 0.5;
		int32_t n = 0;
		for (int32_t i = 0 ; i < poly.npoints ; i++)
		{
			int32_t j = (i + 1) % poly.npoints;
			double ya = cys[i], yb = cys[j];
			if ((ya <= yc && yb > yc) || (yb <= yc && ya > yc))
			{
				double x = cxs[i] + (yc - ya) * (cxs[j] - cxs[i]) / (yb - ya);
				crossings[n++] = (int32_t)floor(x + 0.5);
			}
		}
		for (int32_t a = 1 ; a < n ; a++)
			for (int32_t b = a ; b > 0 && crossings[b - 1] > crossings[b] ; b--)
			{
				int32_t t = crossings[b];
				crossings[b] = crossings[b - 1];
				crossings[b - 1] = t;
			}
		for (int32_t k = 0 ; k + 1 < n ; k += 2)
			draw_span(c, s, verb, y, crossings[k], crossings[k + 1]);
	}
	delete[] cxs;
	delete[] cys;
	delete[] crossings;
}

// Is canvas pixel (x, y) inside a region (in picture coordinates)?
bool region_contains(const Canvas &c, const Region &rgn, int32_t x, int32_t y)
{
	// back to picture coordinates
	int32_t px = c.originx + c.source.left + (int32_t)(((int64_t)x * c.source.width() + c.source.width() / 2) / c.width);
	int32_t py = c.originy + c.source.top + (int32_t)(((int64_t)y * c.source.height() + c.source.height() / 2) / c.height);
	if (px < rgn.bounds.left || px >= rgn.bounds.right || py < rgn.bounds.top || py >= rgn.bounds.bottom)
		return false;
	if (rgn.rectangular)
		return true;
	int32_t row = py - rgn.bounds.top;
	int32_t from = rgn.rowstart[row], to = rgn.rowstart[row + 1];
	for (int32_t i = from ; i + 1 < to ; i += 2)
		if (px >= rgn.xs[i] && px < rgn.xs[i + 1])
			return true;
	return false;
}

void draw_region(Canvas &c, const State &s, Verb verb, const Region &rgn)
{
	Rect r = c.crect(rgn.bounds);
	if (r.empty())
		return;
	// a framed region is drawn as its outline: the pixels inside it with
	// a neighbour outside
	int32_t t_y0, t_y1;
	clip_rows(c, r, t_y0, t_y1);
	int32_t t_x0 = r.left < c.clip.left ? c.clip.left : r.left;
	int32_t t_x1 = r.right > c.clip.right ? c.clip.right : r.right;
	for (int32_t y = t_y0 ; y < t_y1 ; y++)
	{
		int32_t t_run = -1;
		for (int32_t x = t_x0 ; x <= t_x1 ; x++)
		{
			bool on = x < t_x1 && region_contains(c, rgn, x, y);
			if (on && verb == kFrame)
				on = !region_contains(c, rgn, x - 1, y) || !region_contains(c, rgn, x + 1, y)
				     || !region_contains(c, rgn, x, y - 1) || !region_contains(c, rgn, x, y + 1);
			if (on && t_run < 0)
				t_run = x;
			else if (!on && t_run >= 0)
			{
				draw_span(c, s, verb == kFrame ? kPaint : verb, y, t_run, x);
				t_run = -1;
			}
		}
	}
}

// PackBits: n >= 0, n + 1 literal units; n < 0 (not -128), the next unit
// 1 - n times. p_unit is 1 or 2 bytes.
bool unpack_bits(const uint8_t *p_src, uint32_t p_srclen, uint8_t *p_dst, uint32_t p_dstlen, uint32_t p_unit)
{
	uint32_t s = 0, d = 0;
	while (s < p_srclen && d < p_dstlen)
	{
		int8_t n = (int8_t)p_src[s++];
		if (n >= 0)
		{
			uint32_t t_count = ((uint32_t)n + 1) * p_unit;
			if (t_count > p_srclen - s)
				t_count = p_srclen - s;
			if (t_count > p_dstlen - d)
				t_count = p_dstlen - d;
			memcpy(p_dst + d, p_src + s, t_count);
			s += t_count;
			d += t_count;
		}
		else if (n != -128)
		{
			uint32_t t_count = (uint32_t)(1 - n);
			if (p_unit > p_srclen - s)
				break;
			for (uint32_t i = 0 ; i < t_count && d + p_unit <= p_dstlen ; i++)
			{
				memcpy(p_dst + d, p_src + s, p_unit);
				d += p_unit;
			}
			s += p_unit;
		}
	}
	return true;
}

struct PixMap
{
	bool pixmap;
	uint32_t rowbytes;
	Rect bounds;
	uint16_t packtype;
	uint16_t pixelsize;
	uint16_t cmpcount;
	uint32_t palette[256];
};

// Read the pixels of a bitmap or pixel map, after its source and
// destination rectangles and mode (and mask region), into ARGB
bool read_pixels(Reader &r, const PixMap &pm, bool p_packed, uint32_t *r_argb, uint32_t p_fg, uint32_t p_bg)
{
	int32_t w = pm.bounds.width(), h = pm.bounds.height();
	uint32_t t_rowbytes = pm.rowbytes;
	// the bytes of one row once unpacked
	uint32_t t_rowlen = t_rowbytes;
	bool t_planar = false;
	uint32_t t_unit = 1;
	if (pm.pixelsize == 32 && (pm.packtype == 0 || pm.packtype == 4) && p_packed && t_rowbytes >= 8)
	{
		t_planar = true;
		t_rowlen = (uint32_t)w * (pm.cmpcount == 4 ? 4 : 3);
	}
	else if (pm.pixelsize == 32 && pm.packtype == 2)
		t_rowlen = (uint32_t)w * 3;
	else if (pm.pixelsize == 16 && (pm.packtype == 0 || pm.packtype == 3))
		t_unit = 2;
	if (t_rowlen < (uint32_t)((w * pm.pixelsize + 7) / 8) && !t_planar && pm.packtype != 2)
		return false;
	uint8_t *t_row = new (std::nothrow) uint8_t[t_rowlen + 8];
	if (t_row == NULL)
		return false;
	bool t_unpacked = !p_packed || t_rowbytes < 8 || pm.packtype == 1 || pm.packtype == 2;
	for (int32_t y = 0 ; y < h && r.ok ; y++)
	{
		memset(t_row, 0, t_rowlen + 8);
		if (t_unpacked)
		{
			uint32_t t_len = pm.packtype == 2 ? t_rowlen : t_rowbytes;
			const uint8_t *t_src = r.take(t_len);
			if (t_src == NULL)
				break;
			memcpy(t_row, t_src, t_len < t_rowlen ? t_len : t_rowlen);
		}
		else
		{
			uint32_t t_count = t_rowbytes > 250 ? r.u16() : r.u8();
			const uint8_t *t_src = r.take(t_count);
			if (t_src == NULL)
				break;
			unpack_bits(t_src, t_count, t_row, t_rowlen, t_unit);
		}
		uint32_t *t_out = r_argb + (size_t)y * w;
		for (int32_t x = 0 ; x < w ; x++)
		{
			uint32_t v;
			if (t_planar)
			{
				if (pm.cmpcount == 4)
					v = 0xFF000000 | ((uint32_t)t_row[w + x] << 16) | ((uint32_t)t_row[2 * w + x] << 8) | t_row[3 * w + x];
				else
					v = 0xFF000000 | ((uint32_t)t_row[x] << 16) | ((uint32_t)t_row[w + x] << 8) | t_row[2 * w + x];
			}
			else if (pm.pixelsize == 32)
			{
				if (pm.packtype == 2)
					v = 0xFF000000 | ((uint32_t)t_row[x * 3] << 16) | ((uint32_t)t_row[x * 3 + 1] << 8) | t_row[x * 3 + 2];
				else
					v = 0xFF000000 | ((uint32_t)t_row[x * 4 + 1] << 16) | ((uint32_t)t_row[x * 4 + 2] << 8) | t_row[x * 4 + 3];
			}
			else if (pm.pixelsize == 16)
			{
				uint32_t p = ((uint32_t)t_row[x * 2] << 8) | t_row[x * 2 + 1];
				uint32_t r5 = (p >> 10) & 31, g5 = (p >> 5) & 31, b5 = p & 31;
				v = 0xFF000000 | (((r5 << 3) | (r5 >> 2)) << 16) | (((g5 << 3) | (g5 >> 2)) << 8) | ((b5 << 3) | (b5 >> 2));
			}
			else
			{
				uint32_t t_bit = (uint32_t)x * pm.pixelsize;
				uint32_t t_index = (t_row[t_bit / 8] >> (8 - pm.pixelsize - (t_bit % 8))) & ((1 << pm.pixelsize) - 1);
				if (!pm.pixmap)
					v = t_index ? p_fg : p_bg;
				else
					v = pm.palette[t_index & 0xFF];
			}
			t_out[x] = v;
		}
	}
	delete[] t_row;
	return r.ok;
}

// Copy a bitmap to the canvas, from its rectangle sr to the canvas
// rectangle of dr, through an optional mask region
void copy_bits(Canvas &c, const uint32_t *p_src, const Rect &bounds, const Rect &sr, const Rect &pdr,
               int32_t p_mode, const Region *p_mask, bool p_onebit, uint32_t p_fg, uint32_t p_bg)
{
	Rect dr = c.crect(pdr);
	if (dr.empty() || sr.empty())
		return;
	int32_t w = bounds.width();
	int32_t y0 = dr.top < c.clip.top ? c.clip.top : dr.top;
	int32_t y1 = dr.bottom > c.clip.bottom ? c.clip.bottom : dr.bottom;
	int32_t x0 = dr.left < c.clip.left ? c.clip.left : dr.left;
	int32_t x1 = dr.right > c.clip.right ? c.clip.right : dr.right;
	int32_t mode = p_mode & 0x3F;
	if (p_mode & 0x40)
		mode = kSrcCopy;  // ditherCopy
	for (int32_t y = y0 ; y < y1 ; y++)
	{
		int32_t sy = sr.top + (int32_t)((int64_t)(y - dr.top) * sr.height() / dr.height());
		if (sy < bounds.top || sy >= bounds.bottom)
			continue;
		const uint32_t *t_srcrow = p_src + (size_t)(sy - bounds.top) * w;
		uint32_t *t_dst = c.pixels + (size_t)y * c.width;
		for (int32_t x = x0 ; x < x1 ; x++)
		{
			int32_t sx = sr.left + (int32_t)((int64_t)(x - dr.left) * sr.width() / dr.width());
			if (sx < bounds.left || sx >= bounds.right)
				continue;
			if (p_mask != NULL && !region_contains(c, *p_mask, x, y))
				continue;
			uint32_t v = t_srcrow[sx - bounds.left];
			// for a bitmap, "black" is a set bit, drawn in the foreground
			bool t_black = p_onebit ? v == p_fg : v == kBlack;
			bool t_white = p_onebit ? v == p_bg : v == kWhite;
			switch (mode)
			{
			case kSrcOr:
				if (!t_white)
					t_dst[x] = v;
				break;
			case kSrcXor:
				if (t_black || !t_white)
					t_dst[x] ^= 0x00FFFFFF;
				break;
			case kSrcBic:
				if (!t_white)
					t_dst[x] = p_bg;
				break;
			case kNotSrcCopy:
				t_dst[x] = v ^ 0x00FFFFFF;
				break;
			case kNotSrcOr:
				if (!t_black)
					t_dst[x] = v ^ 0x00FFFFFF;
				break;
			case kNotSrcXor:
				if (!t_black)
					t_dst[x] ^= 0x00FFFFFF;
				break;
			case kNotSrcBic:
				if (t_white)
					t_dst[x] = p_bg;
				break;
			case kTransparent:
				if (v != p_bg)
					t_dst[x] = v;
				break;
			default:
				t_dst[x] = v;
				break;
			}
		}
	}
}

// BitsRect, BitsRgn, PackBitsRect, PackBitsRgn, DirectBitsRect and
// DirectBitsRgn
bool do_bits(Reader &r, Canvas &c, State &s, bool p_direct, bool p_packed, bool p_region)
{
	PixMap pm;
	memset(&pm, 0, sizeof(pm));
	if (p_direct)
		r.u32();  // baseAddr, 0x000000FF
	uint16_t t_rowbytes = r.u16();
	pm.pixmap = (t_rowbytes & 0x8000) != 0 || p_direct;
	pm.rowbytes = t_rowbytes & 0x3FFF;
	pm.bounds = r.rect();
	pm.pixelsize = 1;
	pm.cmpcount = 1;
	if (pm.pixmap)
	{
		r.u16();               // pmVersion
		pm.packtype = r.u16();
		r.u32();               // packSize
		r.u32();               // hRes
		r.u32();               // vRes
		r.u16();               // pixelType
		pm.pixelsize = r.u16();
		pm.cmpcount = r.u16();
		r.u16();               // cmpSize
		r.u32();               // planeBytes
		r.u32();               // pmTable
		r.u32();               // pmReserved
		if (pm.pixelsize != 1 && pm.pixelsize != 2 && pm.pixelsize != 4 && pm.pixelsize != 8
		    && pm.pixelsize != 16 && pm.pixelsize != 32)
			return false;
		if (!p_direct)
		{
			// the colour table
			r.u32();           // ctSeed
			uint16_t t_flags = r.u16();
			uint16_t t_count = r.u16();
			for (uint32_t i = 0 ; i <= t_count && r.ok ; i++)
			{
				uint16_t t_value = r.u16();
				uint16_t t_r = r.u16(), t_g = r.u16(), t_b = r.u16();
				uint32_t t_index = (t_flags & 0x8000) ? i : t_value;
				if (t_index < 256)
					pm.palette[t_index] = rgb48(t_r, t_g, t_b);
			}
		}
	}
	Rect t_src = r.rect();
	Rect t_dst = r.rect();
	int32_t t_mode = r.u16();
	Region t_mask;
	if (p_region)
		read_region(r, t_mask);
	if (!r.ok)
		return false;
	int32_t w = pm.bounds.width(), h = pm.bounds.height();
	if (w <= 0 || h <= 0 || w > kMaxSide || h > kMaxSide)
		return false;
	uint32_t *t_argb = new (std::nothrow) uint32_t[(size_t)w * h];
	if (t_argb == NULL)
		return false;
	for (size_t i = 0 ; i < (size_t)w * h ; i++)
		t_argb[i] = kWhite;
	bool t_read = read_pixels(r, pm, p_packed, t_argb, s.fg, s.bg);
	copy_bits(c, t_argb, pm.bounds, t_src, t_dst, t_mode, p_region ? &t_mask : NULL,
	          !pm.pixmap, s.fg, s.bg);
	delete[] t_argb;
	return t_read;
}

// The length of the data of a version 2 opcode this decoder does not draw
// (appendix A's table of reserved opcodes), or -1 if unknown
int64_t reserved_length(Reader &r, uint16_t op)
{
	if ((op >= 0x0017 && op <= 0x0019) || (op >= 0x003D && op <= 0x003F) || (op >= 0x004D && op <= 0x004F)
	    || (op >= 0x005D && op <= 0x005F) || (op >= 0x007D && op <= 0x007F) || (op >= 0x008D && op <= 0x008F)
	    || (op >= 0x00B0 && op <= 0x00CF) || (op >= 0x8000 && op <= 0x80FF))
		return 0;
	if (op >= 0x0035 && op <= 0x0037)
		return 8;
	if (op >= 0x0045 && op <= 0x0047)
		return 8;
	if (op >= 0x0055 && op <= 0x0057)
		return 8;
	if (op >= 0x0065 && op <= 0x0067)
		return 12;
	if (op >= 0x006D && op <= 0x006F)
		return 4;
	if ((op >= 0x0024 && op <= 0x0027) || op == 0x002F || (op >= 0x0075 && op <= 0x0077)
	    || (op >= 0x0085 && op <= 0x0087) || (op >= 0x0092 && op <= 0x0097)
	    || (op >= 0x009C && op <= 0x009F) || (op >= 0x00A2 && op <= 0x00AF))
		return r.u16();
	if ((op >= 0x00D0 && op <= 0x00FE) || op >= 0x8100)
		return r.u32();
	if (op >= 0x0100 && op <= 0x7FFF)
		return (op >> 8) * 2;
	return -1;
}

} // namespace

bool MCHcPictDecode(const uint8_t *p_data, uint32_t p_size,
                    uint32_t *&r_pixels, uint32_t &r_width, uint32_t &r_height,
                    uint32_t &r_skipped)
{
	Reader r = { p_data, p_size, 0, true };
	r.u16();  // the size, wrong for pictures over 32 KB
	Rect t_frame = r.rect();
	if (!r.ok || t_frame.empty() || t_frame.width() > kMaxSide || t_frame.height() > kMaxSide)
		return false;

	State s;
	memset(&s, 0, sizeof(s));
	// the version: 0x1101 (version 1), or 0x0011 0x02FF (version 2)
	if (r.pos + 2 <= p_size && p_data[r.pos] == 0x11 && p_data[r.pos + 1] == 0x01)
	{
		s.version = 1;
		r.pos += 2;
	}
	else if (r.pos + 4 <= p_size && p_data[r.pos] == 0x00 && p_data[r.pos + 1] == 0x11
	         && p_data[r.pos + 2] == 0x02 && p_data[r.pos + 3] == 0xFF)
	{
		s.version = 2;
		r.pos += 4;
	}
	else
		return false;

	Canvas c;
	c.width = t_frame.width();
	c.height = t_frame.height();
	c.source = t_frame;
	c.originx = c.originy = 0;
	c.clip.top = c.clip.left = 0;
	c.clip.bottom = c.height;
	c.clip.right = c.width;
	c.pixels = new (std::nothrow) uint32_t[(size_t)c.width * c.height];
	if (c.pixels == NULL)
		return false;
	for (size_t i = 0 ; i < (size_t)c.width * c.height ; i++)
		c.pixels[i] = kWhite;

	set_pattern(s.pen, 0xFF);
	set_pattern(s.fill, 0xFF);
	set_pattern(s.back, 0x00);
	s.penw = s.penh = 1;
	s.penmode = kPatCopy;
	s.fg = kBlack;
	s.bg = kWhite;

	Polygon t_poly;
	Region t_rgn;
	bool t_drew = false;
	bool t_end = false;
	while (!t_end && r.ok && r.pos < p_size)
	{
		uint16_t op;
		if (s.version == 2)
		{
			if (r.pos & 1)
				r.pos++;
			op = r.u16();
		}
		else
			op = r.u8();
		if (!r.ok)
			break;
		// shapes: 0x30-0x8F, eight opcodes a shape, the verb in the low
		// three bits and "the same shape as last time" when bit 3 is set
		if (op >= 0x30 && op <= 0x8F && (op & 7) <= 4)
		{
			Verb t_verb = (Verb)(op & 7);
			bool t_same = (op & 8) != 0;
			uint16_t t_shape = op & 0xF0;
			switch (t_shape)
			{
			case 0x30:
				if (!t_same)
					s.lastrect = r.rect();
				draw_rrect(c, s, t_verb, s.lastrect, 0, 0);
				break;
			case 0x40:
				if (!t_same)
					s.lastrrect = r.rect();
				draw_rrect(c, s, t_verb, s.lastrrect, s.ovalw, s.ovalh);
				break;
			case 0x50:
				if (!t_same)
					s.lastoval = r.rect();
				draw_rrect(c, s, t_verb, s.lastoval, s.lastoval.width(), s.lastoval.height());
				break;
			case 0x60:
				if (!t_same)
					s.lastarc = r.rect();
				s.arcstart = r.s16();
				s.arcangle = r.s16();
				draw_arc(c, s, t_verb, s.lastarc, s.arcstart, s.arcangle);
				break;
			case 0x70:
				if (!t_same)
					read_polygon(r, t_poly);
				draw_polygon(c, s, t_verb, t_poly);
				break;
			case 0x80:
				if (!t_same)
					read_region(r, t_rgn);
				draw_region(c, s, t_verb, t_rgn);
				break;
			}
			t_drew = true;
			continue;
		}
		switch (op)
		{
		case 0x0000:  // NOP
		case 0x001C:  // HiliteMode
		case 0x001E:  // DefHilite
			break;
		case 0x0001:  // Clip
			{
				Region t_clip;
				if (read_region(r, t_clip))
				{
					Rect t_box = c.crect(t_clip.bounds);
					c.clip.top = t_box.top < 0 ? 0 : t_box.top;
					c.clip.left = t_box.left < 0 ? 0 : t_box.left;
					c.clip.bottom = t_box.bottom > c.height ? c.height : t_box.bottom;
					c.clip.right = t_box.right > c.width ? c.width : t_box.right;
				}
			}
			break;
		case 0x0002:  // BkPat
			memcpy(s.back.bits, r.take(8) ? p_data + r.pos - 8 : s.back.bits, 8);
			break;
		case 0x0003:  // TxFont
		case 0x0005:  // TxMode
		case 0x000D:  // TxSize
		case 0x0015:  // PnLocHFrac
		case 0x0016:  // ChExtra
			r.skip(2);
			break;
		case 0x0004:  // TxFace
			r.skip(1);
			break;
		case 0x0006:  // SpExtra
			r.skip(4);
			break;
		case 0x0007:  // PnSize
			s.penh = r.s16();
			s.penw = r.s16();
			break;
		case 0x0008:  // PnMode
			s.penmode = r.u16();
			break;
		case 0x0009:  // PnPat
			memcpy(s.pen.bits, r.take(8) ? p_data + r.pos - 8 : s.pen.bits, 8);
			break;
		case 0x000A:  // FillPat
			memcpy(s.fill.bits, r.take(8) ? p_data + r.pos - 8 : s.fill.bits, 8);
			break;
		case 0x000B:  // OvSize
			s.ovalh = r.s16();
			s.ovalw = r.s16();
			break;
		case 0x000C:  // Origin
			{
				int32_t dh = r.s16(), dv = r.s16();
				c.originx += dh;
				c.originy += dv;
			}
			break;
		case 0x000E:  // FgColor
			s.fg = old_colour(r.u32());
			break;
		case 0x000F:  // BkColor
			s.bg = old_colour(r.u32());
			break;
		case 0x0010:  // TxRatio
			r.skip(8);
			break;
		case 0x0011:  // Version
			r.skip(s.version == 2 ? 2 : 1);
			break;
		case 0x0012:  // BkPixPat, PnPixPat, FillPixPat: their 8x8
		case 0x0013:  // black-and-white pattern is used, the colour
		case 0x0014:  // pixel map read past
			{
				uint16_t t_type = r.u16();
				Pattern t_pat;
				const uint8_t *t_bits = r.take(8);
				if (t_bits != NULL)
					memcpy(t_pat.bits, t_bits, 8);
				else
					set_pattern(t_pat, 0xFF);
				if (t_type == 1)
				{
					// a pixel map, a colour table and its pixels
					s.skipped |= kHCPictSkippedPattern;
					PixMap pm;
					memset(&pm, 0, sizeof(pm));
					uint16_t t_rb = r.u16();
					pm.pixmap = true;
					pm.rowbytes = t_rb & 0x3FFF;
					pm.bounds = r.rect();
					r.u16();
					pm.packtype = r.u16();
					r.skip(12);
					r.u16();
					pm.pixelsize = r.u16();
					pm.cmpcount = r.u16();
					r.skip(14);
					r.u32();
					uint16_t t_flags = r.u16();
					uint16_t t_count = r.u16();
					(void)t_flags;
					r.skip(((uint32_t)t_count + 1) * 8);
					int32_t w = pm.bounds.width(), h = pm.bounds.height();
					if (!r.ok || w <= 0 || h <= 0 || w > 64 || h > 64 || pm.pixelsize > 8 || pm.pixelsize == 0)
					{
						r.ok = false;
						break;
					}
					uint32_t *t_tmp = new (std::nothrow) uint32_t[(size_t)w * h];
					if (t_tmp == NULL)
					{
						r.ok = false;
						break;
					}
					read_pixels(r, pm, true, t_tmp, s.fg, s.bg);
					delete[] t_tmp;
				}
				else if (t_type == 2)
					r.skip(6);  // a dithered RGB colour
				if (op == 0x0012)
					s.back = t_pat;
				else if (op == 0x0013)
					s.pen = t_pat;
				else
					s.fill = t_pat;
			}
			break;
		case 0x001A:  // RGBFgCol
			{
				uint16_t t_r = r.u16(), t_g = r.u16(), t_b = r.u16();
				s.fg = rgb48(t_r, t_g, t_b);
			}
			break;
		case 0x001B:  // RGBBkCol
			{
				uint16_t t_r = r.u16(), t_g = r.u16(), t_b = r.u16();
				s.bg = rgb48(t_r, t_g, t_b);
			}
			break;
		case 0x001D:  // HiliteColor
		case 0x001F:  // OpColor
			r.skip(6);
			break;
		case 0x0020:  // Line
			{
				int32_t y0 = r.s16(), x0 = r.s16(), y1 = r.s16(), x1 = r.s16();
				draw_line(c, s, x0, y0, x1, y1);
				s.penx = x1;
				s.peny = y1;
				t_drew = true;
			}
			break;
		case 0x0021:  // LineFrom
			{
				int32_t y1 = r.s16(), x1 = r.s16();
				draw_line(c, s, s.penx, s.peny, x1, y1);
				s.penx = x1;
				s.peny = y1;
				t_drew = true;
			}
			break;
		case 0x0022:  // ShortLine
			{
				int32_t y0 = r.s16(), x0 = r.s16();
				int32_t dh = (int8_t)r.u8(), dv = (int8_t)r.u8();
				draw_line(c, s, x0, y0, x0 + dh, y0 + dv);
				s.penx = x0 + dh;
				s.peny = y0 + dv;
				t_drew = true;
			}
			break;
		case 0x0023:  // ShortLineFrom
			{
				int32_t dh = (int8_t)r.u8(), dv = (int8_t)r.u8();
				draw_line(c, s, s.penx, s.peny, s.penx + dh, s.peny + dv);
				s.penx += dh;
				s.peny += dv;
				t_drew = true;
			}
			break;
		case 0x0028:  // LongText
			r.skip(4);
			r.skip(r.u8());
			s.skipped |= kHCPictSkippedText;
			break;
		case 0x0029:  // DHText
		case 0x002A:  // DVText
			r.skip(1);
			r.skip(r.u8());
			s.skipped |= kHCPictSkippedText;
			break;
		case 0x002B:  // DHDVText
			r.skip(2);
			r.skip(r.u8());
			s.skipped |= kHCPictSkippedText;
			break;
		case 0x002C:  // fontName
		case 0x002D:  // lineJustify
		case 0x002E:  // glyphState
			r.skip(r.u16());
			break;
		case 0x0090:  // BitsRect
		case 0x0091:  // BitsRgn
		case 0x0098:  // PackBitsRect
		case 0x0099:  // PackBitsRgn
		case 0x009A:  // DirectBitsRect
		case 0x009B:  // DirectBitsRgn
			if (!do_bits(r, c, s, op >= 0x009A, op >= 0x0098, (op & 1) != 0))
				r.ok = false;
			else
				t_drew = true;
			break;
		case 0x00A0:  // ShortComment
			r.skip(2);
			break;
		case 0x00A1:  // LongComment
			r.skip(2);
			r.skip(r.u16());
			break;
		case 0x00FF:  // OpEndPic
			t_end = true;
			break;
		case 0x0C00:  // HeaderOp
			{
				int16_t t_version = r.s16();
				r.u16();
				uint32_t t_hres = r.u32();
				uint32_t t_vres = r.u32();
				Rect t_source = r.rect();
				r.skip(4);
				// an extended version 2 header: the picture is drawn at
				// its own resolution in t_source, and shown at 72 dpi in
				// the frame
				if (t_version == -2 && t_hres != 0 && t_vres != 0 && !t_source.empty())
					c.source = t_source;
			}
			break;
		case 0x8200:  // CompressedQuickTime
		case 0x8201:  // UncompressedQuickTime
			r.skip(r.u32());
			s.skipped |= kHCPictSkippedQuickTime;
			break;
		default:
			{
				int64_t t_length = s.version == 2 ? reserved_length(r, op) : -1;
				if (t_length < 0)
				{
					s.skipped |= kHCPictSkippedUnknown;
					t_end = true;
				}
				else
					r.skip((uint32_t)t_length);
			}
			break;
		}
	}
	// a picture that ends early keeps what it drew; one that drew nothing
	// and failed is not a picture
	if (!r.ok && !t_drew)
	{
		delete[] c.pixels;
		return false;
	}
	if (!r.ok)
		s.skipped |= kHCPictSkippedUnknown;
	r_pixels = c.pixels;
	r_width = (uint32_t)c.width;
	r_height = (uint32_t)c.height;
	r_skipped = s.skipped;
	return true;
}
