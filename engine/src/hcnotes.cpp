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

// HyperCard's notes, as its Script Language Guide describes `play`: each
// note is a name (a to g, or r for a rest) with an optional accidental
// (# sharp, b flat), an optional octave (middle C is c4) and an optional
// duration (w whole, h half, q quarter, e eighth, s sixteenth, t thirty-
// second, x sixty-fourth), dotted (.) or a triplet (3); or a MIDI note
// number (60 is middle C) with an optional duration. A note without an
// octave or a duration takes the last one given; the first defaults to
// octave 4 and a quarter note. The tempo is taken to be quarter notes a
// minute, and it is 100 when left out ("If you don't specify a tempo,
// tempo 100 is assumed", Apple's HyperTalk Beginner's Guide, 1989, p. 41);
// neither has been checked against HyperCard itself.

#include "hcnotes.h"

#include <math.h>
#include <string.h>
#include <new>

// MSVC's math.h defines M_PI only under _USE_MATH_DEFINES
#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

namespace
{

const char *const kInstrumentNames[kHCInstrumentCount] = {"boing", "harpsichord", "flute"};

// The instruments' pitch and rate: middle C at 22.05 kHz, the rate of
// HyperCard's own sounds
const double kMiddleC = 261.6255653;
const uint32_t kSynthRate = 22050;

// No melody longer than ten minutes is rendered
const double kMaxSeconds = 600.0;

// A reproducible noise for the harpsichord's pluck and the flute's breath
struct Noise
{
	uint32_t state;
	explicit Noise(uint32_t p_seed) : state(p_seed) {}
	double next()
	{
		state = state * 1664525u + 1013904223u;
		return (double)(state >> 8) / (double)(1u << 24) * 2.0 - 1.0;
	}
};

char lower(char c)
{
	return (c >= 'A' && c <= 'Z') ? (char)(c + 32) : c;
}

bool is_word_char(char c)
{
	c = lower(c);
	return (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '_';
}

// Scale p_values to a peak of p_peak of full scale as 16-bit samples
int16_t *to_samples(const double *p_values, uint32_t p_count, double p_peak)
{
	double t_max = 0.0;
	for (uint32_t i = 0; i < p_count; i++)
		if (fabs(p_values[i]) > t_max)
			t_max = fabs(p_values[i]);
	int16_t *t_samples = new (std::nothrow) int16_t[p_count];
	if (t_samples == NULL)
		return NULL;
	double t_scale = t_max > 0.0 ? p_peak * 32767.0 / t_max : 0.0;
	for (uint32_t i = 0; i < p_count; i++)
		t_samples[i] = (int16_t)lrint(p_values[i] * t_scale);
	return t_samples;
}

// A plucked string (Karplus and Strong's): a burst of noise one period
// long, fed back through a two-point average that takes the highs first
void synth_harpsichord(double *p_out, uint32_t p_count)
{
	const uint32_t t_period = (uint32_t)lrint(kSynthRate / kMiddleC);
	double t_line[128];
	Noise t_noise(0x48435044);
	for (uint32_t i = 0; i < t_period; i++)
		t_line[i] = t_noise.next();
	uint32_t t_at = 0;
	for (uint32_t i = 0; i < p_count; i++)
	{
		uint32_t t_next = (t_at + 1) % t_period;
		double t_value = t_line[t_at];
		t_line[t_at] = 0.996 * 0.5 * (t_line[t_at] + t_line[t_next]);
		t_at = t_next;
		p_out[i] = t_value;
	}
}

// A flute: a sine with a little of its second and third harmonics, a slow
// vibrato and some breath, swelling in and dying away
void synth_flute(double *p_out, uint32_t p_count)
{
	Noise t_noise(0x464c5554);
	double t_phase = 0.0, t_breath = 0.0;
	double t_attack = 0.08 * kSynthRate, t_release = 0.15 * kSynthRate;
	for (uint32_t i = 0; i < p_count; i++)
	{
		double t = (double)i / kSynthRate;
		double t_freq = kMiddleC * (1.0 + 0.004 * sin(2.0 * M_PI * 5.0 * t));
		t_phase += 2.0 * M_PI * t_freq / kSynthRate;
		t_breath = 0.9 * t_breath + 0.1 * t_noise.next();
		double t_env = 1.0;
		if (i < t_attack)
			t_env = i / t_attack;
		else if (p_count - i < t_release)
			t_env = (p_count - i) / t_release;
		p_out[i] = t_env * (sin(t_phase) + 0.3 * sin(2.0 * t_phase) + 0.1 * sin(3.0 * t_phase) + 0.15 * t_breath);
	}
}

// A boing: a tone whose pitch wobbles widely and settles while it dies
void synth_boing(double *p_out, uint32_t p_count)
{
	double t_phase = 0.0;
	for (uint32_t i = 0; i < p_count; i++)
	{
		double t = (double)i / kSynthRate;
		double t_freq = kMiddleC * (1.0 + 0.5 * exp(-4.0 * t) * sin(2.0 * M_PI * 9.0 * t));
		t_phase += 2.0 * M_PI * t_freq / kSynthRate;
		double t_env = exp(-3.5 * t) * (i < 64 ? i / 64.0 : 1.0);
		p_out[i] = t_env * (sin(t_phase) + 0.3 * sin(2.0 * t_phase));
	}
}

// One parsed note: its MIDI number (-1 a rest) and its length in quarters
struct Note
{
	int number;
	double quarters;
};

// Parse the note starting at p_text[p_at], updating the octave and the
// duration carried from note to note. False if it is not a note; p_at is
// then past the word, which is skipped.
bool parse_note(const char *p_text, size_t &p_at, int &x_octave, double &x_quarters, Note &r_note)
{
	size_t t_start = p_at;
	size_t t_end = p_at;
	while (p_text[t_end] != '\0' && p_text[t_end] != ' ' && p_text[t_end] != '\t' &&
	       p_text[t_end] != '\r' && p_text[t_end] != '\n' && p_text[t_end] != ',')
		t_end++;
	p_at = t_end;

	size_t i = t_start;
	int t_number;
	char c = lower(p_text[i]);
	if (c >= '0' && c <= '9')
	{
		t_number = 0;
		while (i < t_end && p_text[i] >= '0' && p_text[i] <= '9' && t_number < 1000)
			t_number = t_number * 10 + (p_text[i++] - '0');
		if (t_number > 127)
			return false;
	}
	else
	{
		static const int kSemitones[7] = {9, 11, 0, 2, 4, 5, 7}; // a to g
		bool t_rest = c == 'r';
		if (!t_rest && (c < 'a' || c > 'g'))
			return false;
		i++;
		int t_semitone = t_rest ? 0 : kSemitones[c - 'a'];
		if (!t_rest && i < t_end && p_text[i] == '#')
			t_semitone++, i++;
		else if (!t_rest && i < t_end && p_text[i] == 'b')
			t_semitone--, i++;
		if (i < t_end && p_text[i] >= '0' && p_text[i] <= '9')
			x_octave = p_text[i++] - '0';
		t_number = t_rest ? -1 : (x_octave + 1) * 12 + t_semitone;
		if (t_number > 127)
			return false;
	}

	if (i < t_end)
	{
		switch (lower(p_text[i]))
		{
		case 'w': x_quarters = 4.0; i++; break;
		case 'h': x_quarters = 2.0; i++; break;
		case 'q': x_quarters = 1.0; i++; break;
		case 'e': x_quarters = 0.5; i++; break;
		case 's': x_quarters = 0.25; i++; break;
		case 't': x_quarters = 0.125; i++; break;
		case 'x': x_quarters = 0.0625; i++; break;
		default: break;
		}
	}
	double t_quarters = x_quarters;
	for (; i < t_end; i++)
	{
		if (p_text[i] == '.')
			t_quarters *= 1.5;
		else if (p_text[i] == '3')
			t_quarters *= 2.0 / 3.0;
		else
			return false;
	}
	r_note.number = t_number;
	r_note.quarters = t_quarters;
	return true;
}

} // namespace

const char *MCHcInstrumentName(int p_index)
{
	if (p_index < 0 || p_index >= kHCInstrumentCount)
		return NULL;
	return kInstrumentNames[p_index];
}

int MCHcInstrumentIndex(const char *p_word, size_t p_length)
{
	for (int i = 0; i < kHCInstrumentCount; i++)
	{
		const char *t_name = kInstrumentNames[i];
		if (strlen(t_name) != p_length)
			continue;
		size_t j = 0;
		while (j < p_length && lower(p_word[j]) == t_name[j])
			j++;
		if (j == p_length)
			return i;
	}
	return -1;
}

uint32_t MCHcInstrumentsNamedIn(const char *p_script)
{
	uint32_t t_found = 0;
	if (p_script == NULL)
		return 0;
	const char *p = p_script;
	while (*p != '\0')
	{
		if (!is_word_char(*p))
		{
			p++;
			continue;
		}
		const char *t_word = p;
		while (*p != '\0' && is_word_char(*p))
			p++;
		int t_index = MCHcInstrumentIndex(t_word, (size_t)(p - t_word));
		if (t_index >= 0)
			t_found |= 1u << t_index;
	}
	return t_found;
}

bool MCHcSynthInstrument(int p_index, int16_t *&r_samples, uint32_t &r_count, uint32_t &r_rate)
{
	static const double kSeconds[kHCInstrumentCount] = {0.8, 1.5, 1.2};
	if (p_index < 0 || p_index >= kHCInstrumentCount)
		return false;
	uint32_t t_count = (uint32_t)(kSeconds[p_index] * kSynthRate);
	double *t_values = new (std::nothrow) double[t_count];
	if (t_values == NULL)
		return false;
	switch (p_index)
	{
	case kHCInstrumentBoing: synth_boing(t_values, t_count); break;
	case kHCInstrumentHarpsichord: synth_harpsichord(t_values, t_count); break;
	default: synth_flute(t_values, t_count); break;
	}
	r_samples = to_samples(t_values, t_count, 0.8);
	delete[] t_values;
	if (r_samples == NULL)
		return false;
	r_count = t_count;
	r_rate = kSynthRate;
	return true;
}

bool MCHcRenderNotes(const int16_t *p_source, uint32_t p_count, uint32_t p_rate,
                     const char *p_notes, double p_tempo,
                     int16_t *&r_samples, uint32_t &r_count)
{
	if (p_notes == NULL || p_rate == 0)
		return false;
	if (!(p_tempo > 0.0))
		p_tempo = 100.0;
	if (p_tempo > 2000.0)
		p_tempo = 2000.0;
	double t_quarter = 60.0 / p_tempo * p_rate;

	// Parse once to measure, again to render
	size_t t_note_count = 0;
	double t_total = 0.0;
	Note *t_notes = NULL;
	for (int t_pass = 0; t_pass < 2; t_pass++)
	{
		int t_octave = 4;
		double t_quarters = 1.0;
		size_t t_at = 0, t_index = 0;
		while (p_notes[t_at] != '\0')
		{
			char c = p_notes[t_at];
			if (c == ' ' || c == '\t' || c == '\r' || c == '\n' || c == ',')
			{
				t_at++;
				continue;
			}
			Note t_note;
			if (!parse_note(p_notes, t_at, t_octave, t_quarters, t_note))
				continue;
			if (t_pass == 0)
			{
				t_note_count++;
				t_total += (double)(uint32_t)lrint(t_note.quarters * t_quarter);
			}
			else
				t_notes[t_index++] = t_note;
		}
		if (t_pass == 0)
		{
			if (t_note_count == 0 || t_total > kMaxSeconds * p_rate)
				return false;
			t_notes = new (std::nothrow) Note[t_note_count];
			if (t_notes == NULL)
				return false;
		}
	}

	uint32_t t_length = (uint32_t)t_total;
	int16_t *t_out = new (std::nothrow) int16_t[t_length > 0 ? t_length : 1];
	if (t_out == NULL)
	{
		delete[] t_notes;
		return false;
	}
	memset(t_out, 0, sizeof(int16_t) * (t_length > 0 ? t_length : 1));

	uint32_t t_pos = 0;
	for (size_t n = 0; n < t_note_count; n++)
	{
		uint32_t t_samples = (uint32_t)lrint(t_notes[n].quarters * t_quarter);
		if (t_notes[n].number >= 0 && p_count > 1)
		{
			// Read the sound faster or slower: a semitone is 2^(1/12)
			double t_step = pow(2.0, (t_notes[n].number - 60) / 12.0);
			double t_read = 0.0;
			uint32_t t_sounded = 0;
			while (t_sounded < t_samples && t_read < (double)(p_count - 1))
			{
				uint32_t t_whole = (uint32_t)t_read;
				double t_part = t_read - t_whole;
				double t_value = p_source[t_whole] * (1.0 - t_part) + p_source[t_whole + 1] * t_part;
				t_out[t_pos + t_sounded++] = (int16_t)lrint(t_value);
				t_read += t_step;
			}
			// A sound cut off by the next note fades over 3 ms, not clicks
			if (t_sounded == t_samples)
			{
				uint32_t t_fade = p_rate * 3 / 1000;
				if (t_fade > t_sounded)
					t_fade = t_sounded;
				for (uint32_t k = 0; k < t_fade; k++)
				{
					int16_t &t_sample = t_out[t_pos + t_sounded - 1 - k];
					t_sample = (int16_t)(t_sample * (double)k / t_fade);
				}
			}
		}
		t_pos += t_samples;
	}
	delete[] t_notes;
	r_samples = t_out;
	r_count = t_length;
	return true;
}
