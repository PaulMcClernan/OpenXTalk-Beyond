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

#ifndef __EM_EXTERNALS_H__
#define __EM_EXTERNALS_H__

/* Registers the externals linked into the web engine (revXML, revZip, revDB,
 * revDB's SQLite driver and revSpeech) as libraries that the engine can load
 * by name.
 * Called once, after MCSInitialize() and before the standalone is read. */
void MCEmscriptenRegisterExternals(void);

#endif
