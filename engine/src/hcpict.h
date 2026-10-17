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

// A decoder for QuickDraw pictures (PICT resources and files), for the
// HyperCard importer: the engine has no PICT support of its own
// (MCGraphicsContext::drawpict is a stub on every platform). It depends on
// nothing in the engine, so that it can be tested alone.

#ifndef __HCPICT_H
#define __HCPICT_H

#include <stdint.h>

// What a picture used that the decoder does not draw (r_skipped)
enum
{
	kHCPictSkippedText = 1 << 0,
	kHCPictSkippedQuickTime = 1 << 1,
	kHCPictSkippedUnknown = 1 << 2,
	kHCPictSkippedPattern = 1 << 3,
};

// Decode a PICT (version 1 or 2; p_data starts at the picture's size
// word, as a PICT resource does; a PICT file's 512-byte header must be
// skipped first) into r_width x r_height pixels, each 0xAARRGGBB, opaque,
// on a white ground, freed with delete[]. False if the data is not a
// picture this decoder can read; what it read but could not draw is in
// r_skipped.
bool MCHcPictDecode(const uint8_t *p_data, uint32_t p_size,
                    uint32_t *&r_pixels, uint32_t &r_width, uint32_t &r_height,
                    uint32_t &r_skipped);

#endif
