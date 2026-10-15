/* Copyright (C) 2026 OXT-Beyond contributors.

This file is part of OXT-Beyond.

OXT-Beyond is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License v3 as published by the Free
Software Foundation.

OXT-Beyond is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with OXT-Beyond.  If not see <http://www.gnu.org/licenses/>.  */

/* Printing in a web standalone.
 *
 * A page cannot talk to a printer: it can only ask the browser to print a
 * document, and the browser's print dialog then lets the user pick the
 * printer, the copies and the pages, or save the document as a PDF. So the
 * web engine draws each page that a stack prints as a picture, at 300 dots
 * an inch, as the desktop engine draws a card on the screen, and when
 * printing closes, the browser prints the pictures, one a page, on paper
 * of the size and orientation that the print properties say
 * (em-printer.js). The engine waits until the browser has them, as a
 * desktop engine waits until the system has its pages. It has no dialog of
 * its own to show before that, so answer printer, answer page setup and
 * open printing with dialog go on as if the user clicked OK, and the
 * browser's dialog opens when printing closes.
 *
 * open printing to pdf, and printing with the printerOutput set to
 * "file:<path>", write the pages to that file as a PDF instead, with the
 * anchors, links and bookmarks that print anchor, print link and print
 * bookmark make. Its pages are the same pictures, where a desktop engine's
 * PDF has the text and shapes themselves. A file written under /downloads
 * goes to the user as a download (em-filehandle.cpp), and ask file returns
 * a path there. */

#include "prefix.h"

#include "globdefs.h"
#include "filedefs.h"
#include "objdefs.h"
#include "parsedef.h"
#include "mcio.h"

#include "globals.h"
#include "uidc.h"
#include "context.h"
#include "graphicscontext.h"
#include "printer.h"

#include "em-printer.h"

#include "zlib.h"

#include <cmath>
#include <cstdarg>
#include <cstdio>
#include <cstring>
#include <ctime>
#include <strings.h>
#include <algorithm>
#include <string>
#include <vector>

/* These functions are implemented in JavaScript (em-printer.js) */
extern "C" bool MCEmscriptenPrinterUsesLetter(void);
extern "C" uint32_t MCEmscriptenPrintJobBegin(const unichar_t *p_title, size_t p_title_length);
extern "C" bool MCEmscriptenPrintJobAddPage(uint32_t p_job, const uint8_t *p_rgba, uint32_t p_width, uint32_t p_height, double p_width_pt, double p_height_pt);
extern "C" void MCEmscriptenPrintJobEnd(uint32_t p_job);
extern "C" bool MCEmscriptenPrintJobIsPrinting(uint32_t p_job);
extern "C" bool MCEmscriptenPrintJobFailed(uint32_t p_job);
extern "C" void MCEmscriptenPrintJobRelease(uint32_t p_job);

/* A page's picture has 300 dots an inch, unless that is more pixels than
 * a browser's canvas can have (Safari's limit is 16.7 million), so paper
 * bigger than 11 by 17 inches gets fewer */
static const double kMCEmscriptenPrintResolution = 300.0;
static const double kMCEmscriptenPrintMaxPixels = 16000000.0;
static const double kMCEmscriptenPrintMaxSide = 16384.0;

/* A4 paper, in points (the default paper, unless the browser's language is
 * of a country that uses US Letter) */
static const int32_t kMCEmscriptenPrintA4Width = 595;
static const int32_t kMCEmscriptenPrintA4Height = 842;

/* ================================================================
 * The PDF
 * ================================================================ */

/* A PDF whose pages are pictures: each page is an image (8-bit RGB,
 * compressed with zlib) over the whole page, and the links, anchors and
 * bookmarks made on it. Its coordinates are points from the page's bottom
 * left. The writer keeps the file in memory until Close() writes it, so
 * printing that is cancelled or fails leaves no file (and sends no
 * download). */
class MCEmscriptenPDFWriter
{
public:
	MCEmscriptenPDFWriter(void);

	/* The number of pages added */
	uint32_t GetPageCount(void) const;

	/* Adds a page: its picture, <p_rgba> (opaque), <p_width> by
	 * <p_height> pixels, on paper <p_width_pt> by <p_height_pt> points */
	bool AddPage(const uint8_t *p_rgba, uint32_t p_width, uint32_t p_height, double p_width_pt, double p_height_pt);

	/* These go on the page that AddPage() adds next. A link goes to a URI,
	 * or to the anchor of its name; anchors' names are compared without
	 * case, as by the desktop's PDF printer. <p_depth> 0 puts a bookmark
	 * at the level of the one before it. */
	void AddAnchor(const char *p_name, double p_x, double p_y);
	void AddLink(const char *p_destination, bool p_is_uri, double p_left, double p_bottom, double p_right, double p_top);
	void AddBookmark(const char *p_title, double p_x, double p_y, uint32_t p_depth, bool p_closed);

	/* Writes the file to <p_path>, with the entries of <p_info> (an array,
	 * or nil) in its document information */
	bool Close(MCStringRef p_path, MCArrayRef p_info);

private:
	struct Destination
	{
		uint32_t page;
		double x;
		double y;
	};

	struct Anchor
	{
		std::string name;
		Destination destination;
	};

	struct Link
	{
		std::string destination;
		bool is_uri;
		double rect[4];
	};

	struct Bookmark
	{
		std::string title;
		Destination destination;
		uint32_t depth;
		bool closed;
		int32_t parent;
		int32_t prev;
		int32_t next;
		int32_t first;
		int32_t last;
		int32_t count;
		uint32_t object;
	};

	void Append(const char *p_text);
	void Append(const std::string &p_text);
	void Appendf(const char *p_format, ...);
	void AppendNumber(double p_number);
	void AppendHex(const void *p_bytes, size_t p_length);
	void AppendTextString(const char *p_native);
	void AppendTextString(MCStringRef p_string);
	void AppendName(const char *p_name);
	void AppendDestination(const Destination &p_destination);

	uint32_t NewObject(void);
	void BeginObject(uint32_t p_object);
	void EndObject(void);

	const std::string &DestinationName(const char *p_name);
	int32_t CountBookmarks(int32_t p_first);

	static bool AppendInfo(void *p_context, MCArrayRef p_array, MCNameRef p_key, MCValueRef p_value);

	std::string m_data;
	std::vector<size_t> m_offsets;
	uint32_t m_catalog;
	uint32_t m_page_tree;
	std::vector<uint32_t> m_pages;
	std::vector<std::string> m_destination_names;
	std::vector<Anchor> m_anchors;
	std::vector<Link> m_links;
	std::vector<Bookmark> m_bookmarks;
	uint32_t m_bookmark_depth;
	bool m_failed;
	bool m_has_creation_date;
};

MCEmscriptenPDFWriter::MCEmscriptenPDFWriter(void)
	: m_bookmark_depth(1), m_failed(false), m_has_creation_date(false)
{
	/* The comment of bytes above 127 says that the file is binary */
	Append("%PDF-1.4\n%\xE2\xE3\xCF\xD3\n");
	m_catalog = NewObject();
	m_page_tree = NewObject();
}

uint32_t
MCEmscriptenPDFWriter::GetPageCount(void) const
{
	return uint32_t(m_pages.size());
}

void
MCEmscriptenPDFWriter::Append(const char *p_text)
{
	m_data.append(p_text);
}

void
MCEmscriptenPDFWriter::Append(const std::string &p_text)
{
	m_data.append(p_text);
}

void
MCEmscriptenPDFWriter::Appendf(const char *p_format, ...)
{
	char t_buffer[256];
	va_list t_args;
	va_start(t_args, p_format);
	int t_length = vsnprintf(t_buffer, sizeof(t_buffer), p_format, t_args);
	va_end(t_args);
	if (t_length < 0 || size_t(t_length) >= sizeof(t_buffer))
	{
		m_failed = true;
		return;
	}
	m_data.append(t_buffer, t_length);
}

/* A PDF number has no exponent: points to a hundredth, with no trailing
 * zeros */
static std::string
MCEmscriptenPDFNumber(double p_number)
{
	if (!std::isfinite(p_number))
	{
		p_number = 0;
	}
	char t_buffer[64];
	snprintf(t_buffer, sizeof(t_buffer), "%.2f", p_number);
	std::string t_number(t_buffer);
	if (t_number.find('.') != std::string::npos)
	{
		t_number.erase(t_number.find_last_not_of('0') + 1);
		if (t_number.back() == '.')
		{
			t_number.pop_back();
		}
	}
	return t_number == "-0" ? "0" : t_number;
}

void
MCEmscriptenPDFWriter::AppendNumber(double p_number)
{
	m_data.append(MCEmscriptenPDFNumber(p_number));
}

/* A string of any bytes, in hexadecimal */
void
MCEmscriptenPDFWriter::AppendHex(const void *p_bytes, size_t p_length)
{
	static const char s_digits[] = "0123456789ABCDEF";
	const uint8_t *t_bytes = static_cast<const uint8_t *>(p_bytes);
	m_data.push_back('<');
	for (size_t i = 0; i < p_length; i++)
	{
		m_data.push_back(s_digits[t_bytes[i] >> 4]);
		m_data.push_back(s_digits[t_bytes[i] & 15]);
	}
	m_data.push_back('>');
}

/* A text string, for people to read: UTF-16BE after its byte order mark.
 * The printer's text is the engine's native text, ISO-8859-1 on the web,
 * whose characters are the first 256 of Unicode. */
void
MCEmscriptenPDFWriter::AppendTextString(const char *p_native)
{
	std::string t_utf16("\xFE\xFF", 2);
	for (const uint8_t *t_char = reinterpret_cast<const uint8_t *>(p_native); *t_char != 0; t_char++)
	{
		t_utf16.push_back('\0');
		t_utf16.push_back(char(*t_char));
	}
	AppendHex(t_utf16.data(), t_utf16.size());
}

void
MCEmscriptenPDFWriter::AppendTextString(MCStringRef p_string)
{
	MCAutoStringRefAsUTF16String t_chars;
	if (!t_chars.Lock(p_string))
	{
		m_failed = true;
		AppendHex("", 0);
		return;
	}
	std::string t_utf16("\xFE\xFF", 2);
	for (uindex_t i = 0; i < t_chars.Size(); i++)
	{
		t_utf16.push_back(char(t_chars.Ptr()[i] >> 8));
		t_utf16.push_back(char(t_chars.Ptr()[i] & 0xFF));
	}
	AppendHex(t_utf16.data(), t_utf16.size());
}

/* A name: a byte that is not a regular character is #<hex> */
void
MCEmscriptenPDFWriter::AppendName(const char *p_name)
{
	m_data.push_back('/');
	for (const uint8_t *t_char = reinterpret_cast<const uint8_t *>(p_name); *t_char != 0; t_char++)
	{
		if (*t_char > ' ' && *t_char < 127 && strchr("#()<>[]{}/%", *t_char) == nullptr)
		{
			m_data.push_back(char(*t_char));
		}
		else
		{
			Appendf("#%02X", *t_char);
		}
	}
}

/* A place on a page, where the view goes, at the zoom it had */
void
MCEmscriptenPDFWriter::AppendDestination(const Destination &p_destination)
{
	Appendf("[%u 0 R /XYZ ", m_pages[p_destination.page]);
	AppendNumber(p_destination.x);
	Append(" ");
	AppendNumber(p_destination.y);
	Append(" null]");
}

uint32_t
MCEmscriptenPDFWriter::NewObject(void)
{
	m_offsets.push_back(0);
	return uint32_t(m_offsets.size());
}

void
MCEmscriptenPDFWriter::BeginObject(uint32_t p_object)
{
	m_offsets[p_object - 1] = m_data.size();
	Appendf("%u 0 obj\n", p_object);
}

void
MCEmscriptenPDFWriter::EndObject(void)
{
	Append("endobj\n");
}

/* The name of an anchor: the first spelling given, of those that differ
 * only in case */
const std::string &
MCEmscriptenPDFWriter::DestinationName(const char *p_name)
{
	for (const std::string &t_name : m_destination_names)
	{
		if (strcasecmp(t_name.c_str(), p_name) == 0)
		{
			return t_name;
		}
	}
	m_destination_names.push_back(p_name);
	return m_destination_names.back();
}

bool
MCEmscriptenPDFWriter::AddPage(const uint8_t *p_rgba, uint32_t p_width, uint32_t p_height, double p_width_pt, double p_height_pt)
{
	uint32_t t_image = NewObject();
	uint32_t t_image_length = NewObject();
	uint32_t t_contents = NewObject();
	uint32_t t_page = NewObject();

	/* The picture, a row at a time */
	BeginObject(t_image);
	Appendf("<< /Type /XObject /Subtype /Image /Width %u /Height %u /ColorSpace /DeviceRGB "
	        "/BitsPerComponent 8 /Filter /FlateDecode /Length %u 0 R >>\nstream\n",
	        p_width, p_height, t_image_length);
	size_t t_start = m_data.size();

	z_stream t_zip;
	memset(&t_zip, 0, sizeof(t_zip));
	if (deflateInit(&t_zip, Z_DEFAULT_COMPRESSION) != Z_OK)
	{
		return false;
	}
	std::vector<uint8_t> t_row(size_t(p_width) * 3);
	uint8_t t_out[65536];
	int t_status = Z_OK;
	for (uint32_t y = 0; y <= p_height && t_status == Z_OK; y++)
	{
		int t_flush = Z_FINISH;
		if (y < p_height)
		{
			const uint8_t *t_in = p_rgba + size_t(y) * p_width * 4;
			for (uint32_t x = 0; x < p_width; x++)
			{
				t_row[x * 3] = t_in[x * 4];
				t_row[x * 3 + 1] = t_in[x * 4 + 1];
				t_row[x * 3 + 2] = t_in[x * 4 + 2];
			}
			t_zip.next_in = t_row.data();
			t_zip.avail_in = uInt(t_row.size());
			t_flush = Z_NO_FLUSH;
		}
		do
		{
			t_zip.next_out = t_out;
			t_zip.avail_out = sizeof(t_out);
			t_status = deflate(&t_zip, t_flush);
			m_data.append(reinterpret_cast<const char *>(t_out), sizeof(t_out) - t_zip.avail_out);
		}
		while (t_status == Z_OK && (t_zip.avail_in > 0 || t_zip.avail_out == 0));
		if (t_flush == Z_NO_FLUSH && t_status == Z_BUF_ERROR)
		{
			/* No progress was possible: the row went in whole */
			t_status = Z_OK;
		}
	}
	deflateEnd(&t_zip);
	if (t_status != Z_STREAM_END)
	{
		return false;
	}
	size_t t_length = m_data.size() - t_start;
	Append("\nendstream\n");
	EndObject();

	BeginObject(t_image_length);
	Appendf("%lu\n", (unsigned long)t_length);
	EndObject();

	/* The picture over the whole page */
	std::string t_drawing = "q " + MCEmscriptenPDFNumber(p_width_pt) + " 0 0 " +
		MCEmscriptenPDFNumber(p_height_pt) + " 0 0 cm /Im0 Do Q";
	BeginObject(t_contents);
	Appendf("<< /Length %lu >>\nstream\n", (unsigned long)t_drawing.size());
	Append(t_drawing);
	Append("\nendstream\n");
	EndObject();

	/* The page's links */
	std::vector<uint32_t> t_annotations;
	for (const Link &t_link : m_links)
	{
		uint32_t t_annotation = NewObject();
		t_annotations.push_back(t_annotation);
		BeginObject(t_annotation);
		Append("<< /Type /Annot /Subtype /Link /Rect [");
		for (int i = 0; i < 4; i++)
		{
			if (i > 0)
			{
				Append(" ");
			}
			AppendNumber(t_link.rect[i]);
		}
		Append("] /Border [0 0 0] /A << ");
		if (t_link.is_uri)
		{
			Append("/S /URI /URI ");
		}
		else
		{
			Append("/S /GoTo /D ");
		}
		AppendHex(t_link.destination.data(), t_link.destination.size());
		Append(" >> >>\n");
		EndObject();
	}
	m_links.clear();

	BeginObject(t_page);
	Appendf("<< /Type /Page /Parent %u 0 R /MediaBox [0 0 ", m_page_tree);
	AppendNumber(p_width_pt);
	Append(" ");
	AppendNumber(p_height_pt);
	Appendf("] /Resources << /XObject << /Im0 %u 0 R >> >> /Contents %u 0 R", t_image, t_contents);
	if (!t_annotations.empty())
	{
		Append(" /Annots [");
		for (size_t i = 0; i < t_annotations.size(); i++)
		{
			Appendf(i == 0 ? "%u 0 R" : " %u 0 R", t_annotations[i]);
		}
		Append("]");
	}
	Append(" >>\n");
	EndObject();

	m_pages.push_back(t_page);
	return !m_failed;
}

void
MCEmscriptenPDFWriter::AddAnchor(const char *p_name, double p_x, double p_y)
{
	Anchor t_anchor;
	t_anchor.name = DestinationName(p_name);
	t_anchor.destination.page = uint32_t(m_pages.size());
	t_anchor.destination.x = p_x;
	t_anchor.destination.y = p_y;

	/* An anchor made again moves */
	for (Anchor &t_other : m_anchors)
	{
		if (t_other.name == t_anchor.name)
		{
			t_other = t_anchor;
			return;
		}
	}
	m_anchors.push_back(t_anchor);
}

void
MCEmscriptenPDFWriter::AddLink(const char *p_destination, bool p_is_uri, double p_left, double p_bottom, double p_right, double p_top)
{
	Link t_link;
	t_link.destination = p_is_uri ? std::string(p_destination) : DestinationName(p_destination);
	t_link.is_uri = p_is_uri;
	t_link.rect[0] = p_left;
	t_link.rect[1] = p_bottom;
	t_link.rect[2] = p_right;
	t_link.rect[3] = p_top;
	m_links.push_back(t_link);
}

/* A bookmark is a child of the one before it, if it is one level deeper,
 * or else the next of the last one at its level: a level more than one
 * deeper than the one before is one deeper */
void
MCEmscriptenPDFWriter::AddBookmark(const char *p_title, double p_x, double p_y, uint32_t p_depth, bool p_closed)
{
	if (p_depth == 0)
	{
		p_depth = m_bookmark_depth;
	}
	if (m_bookmarks.empty())
	{
		p_depth = 1;
	}
	else
	{
		p_depth = std::min(p_depth, m_bookmarks.back().depth + 1);
	}
	m_bookmark_depth = p_depth;

	Bookmark t_bookmark;
	t_bookmark.title = p_title;
	t_bookmark.destination.page = uint32_t(m_pages.size());
	t_bookmark.destination.x = p_x;
	t_bookmark.destination.y = p_y;
	t_bookmark.depth = p_depth;
	t_bookmark.closed = p_closed;
	t_bookmark.parent = -1;
	t_bookmark.prev = -1;
	t_bookmark.next = -1;
	t_bookmark.first = -1;
	t_bookmark.last = -1;
	t_bookmark.count = 0;
	t_bookmark.object = 0;

	int32_t t_index = int32_t(m_bookmarks.size());
	if (t_index > 0)
	{
		int32_t t_before = t_index - 1;
		while (m_bookmarks[t_before].depth > p_depth)
		{
			t_before = m_bookmarks[t_before].parent;
		}
		if (m_bookmarks[t_before].depth == p_depth)
		{
			m_bookmarks[t_before].next = t_index;
			t_bookmark.prev = t_before;
			t_bookmark.parent = m_bookmarks[t_before].parent;
			if (t_bookmark.parent != -1)
			{
				m_bookmarks[t_bookmark.parent].last = t_index;
			}
		}
		else
		{
			m_bookmarks[t_before].first = t_index;
			m_bookmarks[t_before].last = t_index;
			t_bookmark.parent = t_before;
		}
	}
	m_bookmarks.push_back(t_bookmark);
}

/* The number of bookmarks shown in the list that starts at <p_first>,
 * with those of the open ones' lists: a bookmark's count is that of its
 * list, negative if it is closed */
int32_t
MCEmscriptenPDFWriter::CountBookmarks(int32_t p_first)
{
	int32_t t_shown = 0;
	for (int32_t t_index = p_first; t_index != -1; t_index = m_bookmarks[t_index].next)
	{
		t_shown += 1;
		if (m_bookmarks[t_index].first != -1)
		{
			int32_t t_children = CountBookmarks(m_bookmarks[t_index].first);
			m_bookmarks[t_index].count = m_bookmarks[t_index].closed ? -t_children : t_children;
			if (!m_bookmarks[t_index].closed)
			{
				t_shown += t_children;
			}
		}
	}
	return t_shown;
}

/* An entry of the document information: the keys that a PDF reader knows
 * as it spells them */
bool
MCEmscriptenPDFWriter::AppendInfo(void *p_context, MCArrayRef p_array, MCNameRef p_key, MCValueRef p_value)
{
	static const char *s_known_keys[] = {"Title", "Author", "Subject", "Keywords", "Creator", "Producer", "CreationDate"};
	MCEmscriptenPDFWriter *self = static_cast<MCEmscriptenPDFWriter *>(p_context);

	MCStringRef t_value;
	if (MCValueGetTypeCode(p_value) == kMCValueTypeCodeName)
	{
		t_value = MCNameGetString(static_cast<MCNameRef>(p_value));
	}
	else if (MCValueGetTypeCode(p_value) == kMCValueTypeCodeString)
	{
		t_value = static_cast<MCStringRef>(p_value);
	}
	else
	{
		return true;
	}

	char *t_key = nullptr;
	if (!MCStringConvertToCString(MCNameGetString(p_key), t_key))
	{
		self->m_failed = true;
		return true;
	}

	const char *t_name = t_key;
	for (const char *t_known : s_known_keys)
	{
		if (strcasecmp(t_name, t_known) == 0)
		{
			t_name = t_known;
			break;
		}
	}
	if (strcmp(t_name, "CreationDate") == 0)
	{
		self->m_has_creation_date = true;
	}

	self->Append(" ");
	self->AppendName(t_name);
	self->Append(" ");
	self->AppendTextString(t_value);
	MCMemoryDeleteArray(t_key);
	return true;
}

bool
MCEmscriptenPDFWriter::Close(MCStringRef p_path, MCArrayRef p_info)
{
	/* The anchors, by name in the order of their bytes */
	uint32_t t_names = 0;
	if (!m_anchors.empty())
	{
		std::sort(m_anchors.begin(), m_anchors.end(), [](const Anchor &a, const Anchor &b) {
			return a.name < b.name;
		});
		t_names = NewObject();
		BeginObject(t_names);
		Append("<< /Names [");
		for (const Anchor &t_anchor : m_anchors)
		{
			Append("\n");
			AppendHex(t_anchor.name.data(), t_anchor.name.size());
			Append(" ");
			AppendDestination(t_anchor.destination);
		}
		Append("\n] >>\n");
		EndObject();
	}

	/* The bookmarks */
	uint32_t t_outlines = 0;
	if (!m_bookmarks.empty())
	{
		int32_t t_shown = CountBookmarks(0);
		t_outlines = NewObject();
		for (Bookmark &t_bookmark : m_bookmarks)
		{
			t_bookmark.object = NewObject();
		}
		int32_t t_last = 0;
		while (m_bookmarks[t_last].next != -1)
		{
			t_last = m_bookmarks[t_last].next;
		}
		BeginObject(t_outlines);
		Appendf("<< /Type /Outlines /First %u 0 R /Last %u 0 R /Count %d >>\n",
		        m_bookmarks[0].object, m_bookmarks[t_last].object, t_shown);
		EndObject();
		for (const Bookmark &t_bookmark : m_bookmarks)
		{
			BeginObject(t_bookmark.object);
			Append("<< /Title ");
			AppendTextString(t_bookmark.title.c_str());
			Appendf(" /Parent %u 0 R", t_bookmark.parent == -1 ? t_outlines : m_bookmarks[t_bookmark.parent].object);
			if (t_bookmark.prev != -1)
			{
				Appendf(" /Prev %u 0 R", m_bookmarks[t_bookmark.prev].object);
			}
			if (t_bookmark.next != -1)
			{
				Appendf(" /Next %u 0 R", m_bookmarks[t_bookmark.next].object);
			}
			if (t_bookmark.first != -1)
			{
				Appendf(" /First %u 0 R /Last %u 0 R /Count %d", m_bookmarks[t_bookmark.first].object,
				        m_bookmarks[t_bookmark.last].object, t_bookmark.count);
			}
			Append(" /Dest ");
			AppendDestination(t_bookmark.destination);
			Append(" >>\n");
			EndObject();
		}
	}

	BeginObject(m_page_tree);
	Append("<< /Type /Pages /Kids [");
	for (size_t i = 0; i < m_pages.size(); i++)
	{
		Appendf(i == 0 ? "%u 0 R" : " %u 0 R", m_pages[i]);
	}
	Appendf("] /Count %lu >>\n", (unsigned long)m_pages.size());
	EndObject();

	BeginObject(m_catalog);
	Appendf("<< /Type /Catalog /Pages %u 0 R", m_page_tree);
	if (t_names != 0)
	{
		Appendf(" /Names << /Dests %u 0 R >>", t_names);
	}
	if (t_outlines != 0)
	{
		Appendf(" /Outlines %u 0 R /PageMode /UseOutlines", t_outlines);
	}
	Append(" >>\n");
	EndObject();

	uint32_t t_info = NewObject();
	BeginObject(t_info);
	Append("<<");
	if (p_info != nil)
	{
		MCArrayApply(p_info, AppendInfo, this);
	}
	if (!m_has_creation_date)
	{
		time_t t_now = time(nullptr);
		struct tm t_time;
		gmtime_r(&t_now, &t_time);
		Appendf(" /CreationDate (D:%04d%02d%02d%02d%02d%02dZ)", t_time.tm_year + 1900, t_time.tm_mon + 1,
		        t_time.tm_mday, t_time.tm_hour, t_time.tm_min, t_time.tm_sec);
	}
	Append(" >>\n");
	EndObject();

	/* The cross-reference table: each entry is 20 bytes */
	size_t t_xref = m_data.size();
	Appendf("xref\n0 %lu\n", (unsigned long)m_offsets.size() + 1);
	Append("0000000000 65535 f \n");
	for (size_t t_offset : m_offsets)
	{
		Appendf("%010lu 00000 n \n", (unsigned long)t_offset);
	}
	Appendf("trailer\n<< /Size %lu /Root %u 0 R /Info %u 0 R >>\nstartxref\n%lu\n%%%%EOF\n",
	        (unsigned long)m_offsets.size() + 1, m_catalog, t_info, (unsigned long)t_xref);

	if (m_failed)
	{
		return false;
	}

	IO_handle t_stream = MCS_open(p_path, kMCOpenFileModeWrite, False, False, 0);
	if (t_stream == nil)
	{
		return false;
	}
	bool t_written = IO_write(m_data.data(), 1, uint32_t(m_data.size()), t_stream) == IO_NORMAL;
	MCS_close(t_stream);
	return t_written;
}

/* ================================================================
 * The printer's device: a print job
 * ================================================================ */

class MCEmscriptenPrinterDevice: public MCPrinterDevice
{
public:
	MCEmscriptenPrinterDevice(MCPrinter *p_printer);
	virtual ~MCEmscriptenPrinterDevice(void);

	/* Starts the job: with <p_pdf_path> nil, the browser prints its pages,
	 * or else they go to that file as a PDF, with <p_pdf_info> */
	MCPrinterResult Start(MCStringRef p_title, MCStringRef p_pdf_path, MCArrayRef p_pdf_info);

	/* Ends the job: the browser prints its pages, or the PDF is written */
	MCPrinterResult Finish(void);

	virtual const char *Error(void) const;
	virtual MCPrinterResult Cancel(void);
	virtual MCPrinterResult Show(void);
	virtual MCPrinterResult Begin(const MCPrinterRectangle &p_src_rect, const MCPrinterRectangle &p_dst_rect, MCContext *&r_context);
	virtual MCPrinterResult End(MCContext *p_context);
	virtual MCPrinterResult Anchor(const char *p_name, double p_x, double p_y);
	virtual MCPrinterResult Link(const char *p_destination, const MCPrinterRectangle &p_area, MCPrinterLinkType p_type);
	virtual MCPrinterResult Bookmark(const char *p_title, double p_x, double p_y, int p_depth, bool p_closed);

private:
	MCPrinterResult GetState(void) const;
	MCPrinterResult Fail(void);

	bool StartPage(void);
	bool EndPage(void);
	void DropPage(void);

	/* A point of the page (the units of its rectangle, from its top left)
	 * in the PDF's points, from its bottom left */
	double PageX(double p_x) const;
	double PageY(double p_y) const;

	MCPrinter *m_printer;

	/* The browser's job, or the PDF */
	uint32_t m_job;
	MCEmscriptenPDFWriter *m_pdf;
	MCStringRef m_pdf_path;
	MCArrayRef m_pdf_info;

	bool m_cancelled;
	bool m_failed;

	/* The page being drawn: its picture, and its paper in points */
	bool m_page_started;
	uint8_t *m_page_pixels;
	uint32_t m_page_width;
	uint32_t m_page_height;
	MCGContextRef m_page_context;
	double m_page_width_pt;
	double m_page_height_pt;
	double m_page_scale;
};

MCEmscriptenPrinterDevice::MCEmscriptenPrinterDevice(MCPrinter *p_printer)
	: m_printer(p_printer),
	  m_job(0), m_pdf(nullptr), m_pdf_path(nil), m_pdf_info(nil),
	  m_cancelled(false), m_failed(false),
	  m_page_started(false), m_page_pixels(nullptr), m_page_width(0), m_page_height(0),
	  m_page_context(nil), m_page_width_pt(0), m_page_height_pt(0), m_page_scale(1)
{
}

MCEmscriptenPrinterDevice::~MCEmscriptenPrinterDevice(void)
{
	DropPage();
	if (m_job != 0)
	{
		MCEmscriptenPrintJobRelease(m_job);
	}
	delete m_pdf;
	MCValueRelease(m_pdf_path);
	MCValueRelease(m_pdf_info);
}

MCPrinterResult
MCEmscriptenPrinterDevice::Start(MCStringRef p_title, MCStringRef p_pdf_path, MCArrayRef p_pdf_info)
{
	if (p_pdf_path != nil)
	{
		m_pdf_path = MCValueRetain(p_pdf_path);
		if (p_pdf_info != nil)
		{
			m_pdf_info = MCValueRetain(p_pdf_info);
		}
		m_pdf = new (nothrow) MCEmscriptenPDFWriter;
		if (m_pdf == nullptr)
		{
			return Fail();
		}
		return PRINTER_RESULT_SUCCESS;
	}

	MCAutoStringRefAsUTF16String t_title;
	if (!t_title.Lock(p_title != nil ? p_title : kMCEmptyString))
	{
		return Fail();
	}
	m_job = MCEmscriptenPrintJobBegin(t_title.Ptr(), t_title.Size());
	if (m_job == 0)
	{
		return Fail();
	}
	return PRINTER_RESULT_SUCCESS;
}

MCPrinterResult
MCEmscriptenPrinterDevice::Finish(void)
{
	MCPrinterResult t_result = GetState();

	/* The last page, which no print break ended */
	if (t_result == PRINTER_RESULT_SUCCESS && m_page_started && !EndPage())
	{
		t_result = Fail();
	}

	if (m_pdf != nullptr)
	{
		/* A PDF has a page, if only a blank one, as the desktop's has */
		if (t_result == PRINTER_RESULT_SUCCESS && m_pdf->GetPageCount() == 0 &&
		    (!StartPage() || !EndPage()))
		{
			t_result = Fail();
		}
		if (t_result == PRINTER_RESULT_SUCCESS && !m_pdf->Close(m_pdf_path, m_pdf_info))
		{
			t_result = Fail();
		}
	}
	else if (m_job != 0 && t_result == PRINTER_RESULT_SUCCESS)
	{
		/* The browser gets the pages once it has made their pictures into
		 * files, and prints them. The engine waits until it has, running
		 * no messages meanwhile, as when the system takes a desktop
		 * engine's pages (a handler that the page calls cannot wait: the
		 * pages print when they can). */
		MCEmscriptenPrintJobEnd(m_job);
		while (!MCquit && MCEmscriptenPrintJobIsPrinting(m_job))
		{
			if (MCscreen->wait(60.0, False, True))
			{
				break;
			}
		}
		if (MCEmscriptenPrintJobFailed(m_job))
		{
			t_result = Fail();
		}
	}

	if (m_job != 0)
	{
		MCEmscriptenPrintJobRelease(m_job);
		m_job = 0;
	}
	DropPage();
	return t_result;
}

const char *
MCEmscriptenPrinterDevice::Error(void) const
{
	return m_failed ? "printing failed" : nullptr;
}

MCPrinterResult
MCEmscriptenPrinterDevice::GetState(void) const
{
	if (m_cancelled)
	{
		return PRINTER_RESULT_CANCEL;
	}
	if (m_failed)
	{
		return PRINTER_RESULT_ERROR;
	}
	return PRINTER_RESULT_SUCCESS;
}

MCPrinterResult
MCEmscriptenPrinterDevice::Fail(void)
{
	m_failed = true;
	return PRINTER_RESULT_ERROR;
}

/* Cancelling forgets the pages: none print, and no PDF is written */
MCPrinterResult
MCEmscriptenPrinterDevice::Cancel(void)
{
	MCPrinterResult t_state = GetState();
	if (t_state != PRINTER_RESULT_SUCCESS)
	{
		return t_state;
	}
	m_cancelled = true;
	DropPage();
	if (m_job != 0)
	{
		MCEmscriptenPrintJobRelease(m_job);
		m_job = 0;
	}
	delete m_pdf;
	m_pdf = nullptr;
	return PRINTER_RESULT_CANCEL;
}

MCPrinterResult
MCEmscriptenPrinterDevice::Show(void)
{
	MCPrinterResult t_state = GetState();
	if (t_state != PRINTER_RESULT_SUCCESS)
	{
		return t_state;
	}
	if (!m_page_started && !StartPage())
	{
		return Fail();
	}
	if (!EndPage())
	{
		return Fail();
	}
	return PRINTER_RESULT_SUCCESS;
}

/* The context draws on the page's picture: the source rectangle (of the
 * card) maps to the destination rectangle (of the page), which clips it */
MCPrinterResult
MCEmscriptenPrinterDevice::Begin(const MCPrinterRectangle &p_src_rect, const MCPrinterRectangle &p_dst_rect, MCContext *&r_context)
{
	r_context = nullptr;
	MCPrinterResult t_state = GetState();
	if (t_state != PRINTER_RESULT_SUCCESS)
	{
		return t_state;
	}
	if (!m_page_started && !StartPage())
	{
		return Fail();
	}

	double t_src_width = p_src_rect.right - p_src_rect.left;
	double t_src_height = p_src_rect.bottom - p_src_rect.top;
	double t_dst_width = p_dst_rect.right - p_dst_rect.left;
	double t_dst_height = p_dst_rect.bottom - p_dst_rect.top;

	MCGContextSave(m_page_context);
	/* The page's units in pixels */
	MCGContextScaleCTM(m_page_context, m_page_width / (m_page_width_pt / m_page_scale),
	                   m_page_height / (m_page_height_pt / m_page_scale));
	MCGContextClipToRect(m_page_context, MCGRectangleMake(p_dst_rect.left, p_dst_rect.top, t_dst_width, t_dst_height));
	MCGContextTranslateCTM(m_page_context, p_dst_rect.left, p_dst_rect.top);
	MCGContextScaleCTM(m_page_context, t_src_width > 0 ? t_dst_width / t_src_width : 1,
	                   t_src_height > 0 ? t_dst_height / t_src_height : 1);
	MCGContextTranslateCTM(m_page_context, -p_src_rect.left, -p_src_rect.top);

	r_context = new (nothrow) MCGraphicsContext(m_page_context);
	if (r_context == nullptr)
	{
		MCGContextRestore(m_page_context);
		return Fail();
	}
	return PRINTER_RESULT_SUCCESS;
}

MCPrinterResult
MCEmscriptenPrinterDevice::End(MCContext *p_context)
{
	if (p_context != nullptr)
	{
		delete p_context;
		if (m_page_context != nil)
		{
			MCGContextRestore(m_page_context);
		}
	}
	return GetState();
}

double
MCEmscriptenPrinterDevice::PageX(double p_x) const
{
	return p_x * m_page_scale;
}

double
MCEmscriptenPrinterDevice::PageY(double p_y) const
{
	return m_page_height_pt - p_y * m_page_scale;
}

/* Anchors, links and bookmarks are a PDF's: a printer has none */
MCPrinterResult
MCEmscriptenPrinterDevice::Anchor(const char *p_name, double p_x, double p_y)
{
	MCPrinterResult t_state = GetState();
	if (t_state != PRINTER_RESULT_SUCCESS || m_pdf == nullptr)
	{
		return t_state;
	}
	if (!m_page_started && !StartPage())
	{
		return Fail();
	}
	m_pdf->AddAnchor(p_name, PageX(p_x), PageY(p_y));
	return PRINTER_RESULT_SUCCESS;
}

/* A link of no type is to a URI if its destination starts with a scheme
 * (letters and a colon), or else to an anchor, as on the desktop */
MCPrinterResult
MCEmscriptenPrinterDevice::Link(const char *p_destination, const MCPrinterRectangle &p_area, MCPrinterLinkType p_type)
{
	MCPrinterResult t_state = GetState();
	if (t_state != PRINTER_RESULT_SUCCESS || m_pdf == nullptr)
	{
		return t_state;
	}
	if (!m_page_started && !StartPage())
	{
		return Fail();
	}

	if (p_type == kMCPrinterLinkUnspecified)
	{
		const char *t_char = p_destination;
		while ((*t_char >= 'a' && *t_char <= 'z') || (*t_char >= 'A' && *t_char <= 'Z'))
		{
			t_char++;
		}
		p_type = (*t_char == ':' && t_char != p_destination) ? kMCPrinterLinkURI : kMCPrinterLinkAnchor;
	}
	m_pdf->AddLink(p_destination, p_type == kMCPrinterLinkURI, PageX(p_area.left), PageY(p_area.bottom),
	               PageX(p_area.right), PageY(p_area.top));
	return PRINTER_RESULT_SUCCESS;
}

MCPrinterResult
MCEmscriptenPrinterDevice::Bookmark(const char *p_title, double p_x, double p_y, int p_depth, bool p_closed)
{
	MCPrinterResult t_state = GetState();
	if (t_state != PRINTER_RESULT_SUCCESS || m_pdf == nullptr)
	{
		return t_state;
	}
	if (!m_page_started && !StartPage())
	{
		return Fail();
	}
	m_pdf->AddBookmark(p_title, PageX(p_x), PageY(p_y), p_depth > 0 ? uint32_t(p_depth) : 0, p_closed);
	return PRINTER_RESULT_SUCCESS;
}

/* A page is white paper of the size and orientation that the printer has
 * when it starts */
bool
MCEmscriptenPrinterDevice::StartPage(void)
{
	MCPrinterOrientation t_orientation = m_printer->GetPageOrientation();
	if (t_orientation == PRINTER_ORIENTATION_LANDSCAPE || t_orientation == PRINTER_ORIENTATION_REVERSE_LANDSCAPE)
	{
		m_page_width_pt = m_printer->GetPageHeight();
		m_page_height_pt = m_printer->GetPageWidth();
	}
	else
	{
		m_page_width_pt = m_printer->GetPageWidth();
		m_page_height_pt = m_printer->GetPageHeight();
	}
	m_page_scale = m_printer->GetPageScale();
	if (m_page_width_pt < 1 || m_page_height_pt < 1 || !(m_page_scale > 0))
	{
		return false;
	}

	double t_resolution = kMCEmscriptenPrintResolution / 72.0;
	t_resolution = std::min(t_resolution, sqrt(kMCEmscriptenPrintMaxPixels / (m_page_width_pt * m_page_height_pt)));
	t_resolution = std::min(t_resolution, kMCEmscriptenPrintMaxSide / std::max(m_page_width_pt, m_page_height_pt));
	m_page_width = std::max(uint32_t(1), uint32_t(round(m_page_width_pt * t_resolution)));
	m_page_height = std::max(uint32_t(1), uint32_t(round(m_page_height_pt * t_resolution)));

	size_t t_size = size_t(m_page_width) * m_page_height * 4;
	m_page_pixels = static_cast<uint8_t *>(malloc(t_size));
	if (m_page_pixels == nullptr)
	{
		return false;
	}
	memset(m_page_pixels, 0xFF, t_size);
	if (!MCGContextCreateWithPixels(m_page_width, m_page_height, m_page_width * 4, m_page_pixels, true, m_page_context))
	{
		DropPage();
		return false;
	}

	m_page_started = true;
	return true;
}

/* The page's picture, on white where it is not opaque, goes to the
 * browser or into the PDF */
bool
MCEmscriptenPrinterDevice::EndPage(void)
{
	uint8_t *t_pixel = m_page_pixels;
	uint8_t *t_end = m_page_pixels + size_t(m_page_width) * m_page_height * 4;
	for (; t_pixel < t_end; t_pixel += 4)
	{
		/* The colours are premultiplied by the alpha, which is last */
		uint8_t t_white = 255 - t_pixel[3];
		if (t_white != 0)
		{
			t_pixel[0] += t_white;
			t_pixel[1] += t_white;
			t_pixel[2] += t_white;
			t_pixel[3] = 255;
		}
	}

	bool t_success;
	if (m_pdf != nullptr)
	{
		t_success = m_pdf->AddPage(m_page_pixels, m_page_width, m_page_height, m_page_width_pt, m_page_height_pt);
	}
	else
	{
		t_success = MCEmscriptenPrintJobAddPage(m_job, m_page_pixels, m_page_width, m_page_height,
		                                        m_page_width_pt, m_page_height_pt);
	}

	DropPage();
	return t_success;
}

void
MCEmscriptenPrinterDevice::DropPage(void)
{
	if (m_page_context != nil)
	{
		MCGContextRelease(m_page_context);
		m_page_context = nil;
	}
	free(m_page_pixels);
	m_page_pixels = nullptr;
	m_page_started = false;
}

/* ================================================================
 * The printer
 * ================================================================ */

class MCEmscriptenPrinter: public MCPrinter
{
public:
	/* The browser's printer has no name; the printer of open printing to
	 * pdf is called "pdf", as on the desktop, and has the options */
	MCEmscriptenPrinter(MCStringRef p_name, MCArrayRef p_pdf_info);
	virtual ~MCEmscriptenPrinter(void);

protected:
	virtual void DoInitialize(void);
	virtual void DoFinalize(void);
	virtual bool DoReset(MCStringRef p_name);
	virtual bool DoResetSettings(MCDataRef p_settings);
	virtual const char *DoFetchName(void);
	virtual void DoFetchSettings(void *&r_buffer, uint4 &r_length);
	virtual void DoResync(void);
	virtual MCPrinterDialogResult DoPrinterSetup(bool p_window_modal, Window p_owner);
	virtual MCPrinterDialogResult DoPageSetup(bool p_window_modal, Window p_owner);
	virtual MCPrinterResult DoBeginPrint(MCStringRef p_document, MCPrinterDevice *&r_device);
	virtual MCPrinterResult DoEndPrint(MCPrinterDevice *p_device);

private:
	void ResetPaper(void);

	char *m_name;
	MCArrayRef m_pdf_info;
};

MCEmscriptenPrinter::MCEmscriptenPrinter(MCStringRef p_name, MCArrayRef p_pdf_info)
	: m_name(nullptr), m_pdf_info(nil)
{
	/* UNCHECKED */ MCStringConvertToCString(p_name, m_name);
	if (p_pdf_info != nil)
	{
		m_pdf_info = MCValueRetain(p_pdf_info);
	}
}

MCEmscriptenPrinter::~MCEmscriptenPrinter(void)
{
	/* The printer of open printing to pdf lasts as long as its print loop
	 * (exec-printing.cpp); finalizing twice does no harm */
	Finalize();
	MCValueRelease(m_pdf_info);
	MCMemoryDeleteArray(m_name);
}

/* The paper is the browser's language's country's, as on the desktop it
 * is the default printer's: US Letter, which the printer starts with, in
 * the countries that use it, or else A4 */
void
MCEmscriptenPrinter::ResetPaper(void)
{
	if (MCEmscriptenPrinterUsesLetter())
	{
		SetPageSize(PRINTER_DEFAULT_PAGE_WIDTH, PRINTER_DEFAULT_PAGE_HEIGHT);
	}
	else
	{
		SetPageSize(kMCEmscriptenPrintA4Width, kMCEmscriptenPrintA4Height);
	}
}

void
MCEmscriptenPrinter::DoInitialize(void)
{
	if (m_pdf_info == nil && (m_name == nullptr || *m_name == '\0'))
	{
		ResetPaper();
	}
}

void
MCEmscriptenPrinter::DoFinalize(void)
{
}

/* The browser's printer is the only one: setting the printerName to empty
 * resets it, and any other name is unknown */
bool
MCEmscriptenPrinter::DoReset(MCStringRef p_name)
{
	if (p_name != nil && !MCStringIsEmpty(p_name))
	{
		return m_name != nullptr && MCStringIsEqualToCString(p_name, m_name, kMCCompareCaseless);
	}
	ResetPaper();
	return true;
}

/* It has no settings of its own (the printerSettings is empty) */
bool
MCEmscriptenPrinter::DoResetSettings(MCDataRef p_settings)
{
	return MCDataIsEmpty(p_settings);
}

const char *
MCEmscriptenPrinter::DoFetchName(void)
{
	return m_name != nullptr ? m_name : "";
}

void
MCEmscriptenPrinter::DoFetchSettings(void *&r_buffer, uint4 &r_length)
{
	r_buffer = nullptr;
	r_length = 0;
}

/* It prints the whole page, in colour: the copies, collating and two sides
 * are the browser dialog's to choose */
void
MCEmscriptenPrinter::DoResync(void)
{
	SetDeviceRectangle(GetPageRectangle());
	SetDeviceFeatures(PRINTER_FEATURE_COLOR);
	m_resync = false;
}

/* The browser's print dialog opens when the pages print */
MCPrinterDialogResult
MCEmscriptenPrinter::DoPrinterSetup(bool p_window_modal, Window p_owner)
{
	return PRINTER_DIALOG_RESULT_OKAY;
}

MCPrinterDialogResult
MCEmscriptenPrinter::DoPageSetup(bool p_window_modal, Window p_owner)
{
	return PRINTER_DIALOG_RESULT_OKAY;
}

MCPrinterResult
MCEmscriptenPrinter::DoBeginPrint(MCStringRef p_document, MCPrinterDevice *&r_device)
{
	MCEmscriptenPrinterDevice *t_device = new (nothrow) MCEmscriptenPrinterDevice(this);
	if (t_device == nullptr)
	{
		return PRINTER_RESULT_ERROR;
	}
	r_device = t_device;

	/* The printerOutput "file:<path>" (or open printing to pdf) writes a
	 * PDF; "device" and "preview" print, as the browser's dialog previews
	 * the pages */
	MCAutoStringRef t_path;
	if (GetDeviceOutputType() == PRINTER_OUTPUT_FILE)
	{
		const char *t_location = GetDeviceOutputLocation();
		if (t_location == nullptr || *t_location == '\0' ||
		    !MCStringCreateWithBytes(reinterpret_cast<const byte_t *>(t_location), strlen(t_location),
		                             kMCStringEncodingUTF8, false, &t_path))
		{
			return PRINTER_RESULT_ERROR;
		}
	}

	return t_device->Start(p_document, *t_path, m_pdf_info);
}

MCPrinterResult
MCEmscriptenPrinter::DoEndPrint(MCPrinterDevice *p_device)
{
	MCEmscriptenPrinterDevice *t_device = static_cast<MCEmscriptenPrinterDevice *>(p_device);
	MCPrinterResult t_result = t_device->Finish();
	delete t_device;
	return t_result;
}

/* ================================================================
 * Creating the printers
 * ================================================================ */

MCPrinter *
MCEmscriptenPrinterCreate(void)
{
	return new (nothrow) MCEmscriptenPrinter(kMCEmptyString, nil);
}

/* As MCCustomPrinterCreate() makes the desktop's (customprinter.cpp) */
bool
MCEmscriptenPDFPrinterCreate(MCStringRef p_filename, MCArrayRef p_options, MCPrinter *&r_printer)
{
	if (p_filename == nil || MCStringIsEmpty(p_filename))
	{
		return false;
	}

	MCAutoArrayRef t_options;
	if (p_options != nil)
	{
		t_options = MCValueRetain(p_options);
	}
	else
	{
		t_options = MCValueRetain(kMCEmptyArray);
	}

	MCEmscriptenPrinter *t_printer = new (nothrow) MCEmscriptenPrinter(MCSTR("pdf"), *t_options);
	if (t_printer == nullptr)
	{
		return false;
	}

	t_printer->Initialize();
	t_printer->SetDeviceOutput(PRINTER_OUTPUT_FILE, p_filename);
	t_printer->SetPageSize(MCprinter->GetPageWidth(), MCprinter->GetPageHeight());
	t_printer->SetPageOrientation(MCprinter->GetPageOrientation());
	t_printer->SetPageMargins(MCprinter->GetPageLeftMargin(), MCprinter->GetPageTopMargin(),
	                          MCprinter->GetPageRightMargin(), MCprinter->GetPageBottomMargin());
	t_printer->SetPageScale(MCprinter->GetPageScale());
	t_printer->SetLayoutShowBorders(MCprinter->GetLayoutShowBorders());
	t_printer->SetLayoutSpacing(MCprinter->GetLayoutRowSpacing(), MCprinter->GetLayoutColumnSpacing());
	t_printer->SetLayoutRowsFirst(MCprinter->GetLayoutRowsFirst());
	t_printer->SetLayoutScale(MCprinter->GetLayoutScale());
	t_printer->SetDeviceRectangle(t_printer->GetPageRectangle());

	r_printer = t_printer;
	return true;
}
