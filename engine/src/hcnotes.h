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

// HyperCard's sounds: the three instruments HyperCard carried in its own
// resource fork (boing, harpsichord and flute), synthesised here because
// Apple's samples cannot ship, and the notes of `play "sound" tempo t
// "notes"`, played by pitching a sound from middle C. Like hcpict.h it
// depends on nothing in the engine, so that it can be tested alone.

#ifndef __HCNOTES_H
#define __HCNOTES_H

#include <stddef.h>
#include <stdint.h>

// The instruments, in the order MCHcInstrumentName gives them
enum
{
	kHCInstrumentBoing,
	kHCInstrumentHarpsichord,
	kHCInstrumentFlute,
	kHCInstrumentCount,
};

// The name of instrument p_index ("boing", "harpsichord" or "flute")
const char *MCHcInstrumentName(int p_index);

// The instrument p_word names (p_length bytes, any case), or -1
int MCHcInstrumentIndex(const char *p_word, size_t p_length);

// The instruments a script names, a bit (1 << index) for each: the words
// of p_script, compared caselessly, so "boing" in a comment counts too
uint32_t MCHcInstrumentsNamedIn(const char *p_script);

// Synthesise instrument p_index at middle C: r_count mono samples at
// r_rate, freed with delete[]. Always the same samples for an instrument.
bool MCHcSynthInstrument(int p_index, int16_t *&r_samples, uint32_t &r_count, uint32_t &r_rate);

// Play p_notes (HyperCard's notation: "c4q d e g#5h. r 60e", see
// hcnotes.cpp) with the sound p_source (p_count mono samples at p_rate,
// taken to sound middle C) at p_tempo quarter notes a minute (HyperCard's
// 120 when p_tempo is not above 0). r_samples (freed with delete[]) holds
// r_count samples at p_rate. False if p_notes holds no note.
bool MCHcRenderNotes(const int16_t *p_source, uint32_t p_count, uint32_t p_rate,
                     const char *p_notes, double p_tempo,
                     int16_t *&r_samples, uint32_t &r_count);

#endif
