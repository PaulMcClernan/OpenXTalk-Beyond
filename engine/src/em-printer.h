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

#ifndef __MC_EMSCRIPTEN_PRINTER_H__
#define __MC_EMSCRIPTEN_PRINTER_H__

#include "printer.h"

/* The printer of a web standalone (em-printer.cpp): the browser prints
 * its pages, or with the printerOutput set to "file:<path>", it writes
 * them to that file as a PDF */
MCPrinter *MCEmscriptenPrinterCreate(void);

/* The printer that open printing to pdf uses: it writes the pages to
 * <p_filename> as a PDF, whose document information has the entries of
 * <p_options>, with the page settings of the printer it replaces
 * (MCprinter) */
bool MCEmscriptenPDFPrinterCreate(MCStringRef p_filename, MCArrayRef p_options, MCPrinter *&r_printer);

#endif /* ! __MC_EMSCRIPTEN_PRINTER_H__ */
