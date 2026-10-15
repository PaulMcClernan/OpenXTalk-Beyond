/*                                                                     -*-c++-*-

Copyright (C) 2003-2015 LiveCode Ltd.

This file is part of LiveCode.

LiveCode is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License v3 as published by the Free
Software Foundation.

LiveCode is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with LiveCode.  If not see <http://www.gnu.org/licenses/>.  */

#include "prefix.h"

#include "objdefs.h"
#include "font.h"
#include "platform.h"
#include "mctheme.h"
#include "context.h"

MCTheme *
MCThemeCreateNative()
{
	return nil;
}

/* There is no native theme, so the engine draws its controls itself;
 * as on the server, drawing a native part fails. */
bool
MCThemeDraw(MCGContextRef p_context,
            MCThemeDrawType p_type,
            MCThemeDrawInfo *p_info)
{
	return false;
}


/* ================================================================
 * Platform theming
 * ================================================================ */

/* FIXME not yet implemented */

bool
MCPlatformGetControlThemePropColor(MCPlatformControlType p_type,
                                   MCPlatformControlPart p_part,
                                   MCPlatformControlState p_state,
                                   MCPlatformThemeProperty p_prop,
                                   MCColor& r_color)
{
	return false;
}

bool
MCPlatformGetControlThemePropFont(MCPlatformControlType p_type,
                                  MCPlatformControlPart p_part,
                                  MCPlatformControlState p_state,
                                  MCPlatformThemeProperty p_prop,
                                  MCFontRef& r_font)
{
	/* For now, ask for the compiled-in default font name and size*/
	return MCFontCreate(MCNAME(DEFAULT_TEXT_FONT), 0,
	                    DEFAULT_TEXT_SIZE, r_font);
}
