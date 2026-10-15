/* Copyright (C) 2026 OpenXTalk Contributors.

This file is part of OpenXTalk.

OpenXTalk is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License v3 as published by the Free
Software Foundation.

OpenXTalk is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with OpenXTalk.  If not see <http://www.gnu.org/licenses/>.  */

#include <core.h>

#include "libbrowser_internal.h"

// A web page has no browser control to put in a stack, so the web engine
// has no browser factory: creating a browser fails.
MCBrowserFactoryMap kMCBrowserFactoryMap[] =
{
	{ nil, nil, nil },
};

MCBrowserFactoryMap* s_factory_list = kMCBrowserFactoryMap;
