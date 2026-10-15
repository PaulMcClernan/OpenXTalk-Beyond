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

#include <core.h>

#include "libbrowser_internal.h"

// The web engine's browser is a frame of the page (libbrowser_em.cpp)
extern bool MCEmscriptenBrowserFactoryCreate(MCBrowserFactoryRef &r_factory);

MCBrowserFactoryMap kMCBrowserFactoryMap[] =
{
	{ "iframe", nil, MCEmscriptenBrowserFactoryCreate },
	{ nil, nil, nil },
};

MCBrowserFactoryMap* s_factory_list = kMCBrowserFactoryMap;
