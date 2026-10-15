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

#include "em-util.h"

#include "globdefs.h"
#include "filedefs.h"
#include "objdefs.h"
#include "parsedef.h"
#include "exec.h"
#include "stack.h"
#include "object.h"
#include "param.h"
#include "sysdefs.h"
#include "osspec.h"
#include "globals.h"
#include "notify.h"
#include "ans.h"

/* ================================================================
 * Locales
 * ================================================================ */

MCLocaleRef
MCS_getsystemlocale()
{
	/* Emscripten locale is basically C.UTF-8.  There's no standard
	 * way to get the user's desired locale from ECMAScript,
	 * either. */
	MCLocaleRef t_locale;
	/* UNCHECKED */ MCLocaleCreateWithName(MCSTR("C"), t_locale);
	return t_locale;
}


bool
MCS_put(MCExecContext &ctxt, MCSPutKind p_kind, MCStringRef p_string)
{
	bool t_success;
	switch (p_kind)
	{
	case kMCSPutBeforeMessage:
        // SN-2014-04-11 [[ FasterVariable ]] parameter updated to use the new 'set' operation on variables
        t_success = MCmb -> set(ctxt, p_string, kMCVariableSetBefore);
        break;
    case kMCSPutOutput:
    case kMCSPutIntoMessage:
		t_success = MCmb -> set(ctxt, p_string);
		break;
	case kMCSPutAfterMessage:
		// SN-2014-04-11 [[ FasterVariable ]] parameter updated to use the new 'set' operation on variables
		t_success = MCmb -> set(ctxt, p_string, kMCVariableSetAfter);
		break;
	default:
		t_success = false;
		break;
	}

	// MW-2012-02-23: [[ PutUnicode ]] If we don't understand the kind
	//   then return false (caller can then throw an error).
	return t_success;
}

/* As on mobile, there is no binary output. */
bool
MCS_put_binary(MCExecContext & ctxt,
               MCSPutKind p_kind,
               MCDataRef p_data)
{
	return false;
}

/* ================================================================
 * Server properties
 *
 * The errorMode, the outputTextEncoding, the outputLineEndings and
 * the session properties belong to the server engine; as on mobile,
 * setting them does nothing.
 * ================================================================ */

void
MCS_set_errormode(MCSErrorMode p_mode)
{
}

MCSErrorMode
MCS_get_errormode()
{
	return kMCSErrorModeNone;
}

void
MCS_set_outputtextencoding(MCSOutputTextEncoding p_encoding)
{
}

MCSOutputTextEncoding
MCS_get_outputtextencoding()
{
	return kMCSOutputTextEncodingNative;
}

void
MCS_set_outputlineendings(MCSOutputLineEndings p_ending)
{
}

MCSOutputLineEndings
MCS_get_outputlineendings()
{
	return kMCSOutputLineEndingsNative;
}

bool
MCS_set_session_save_path(MCStringRef p_path)
{
	return true;
}

bool
MCS_get_session_save_path(MCStringRef & r_path)
{
	r_path = MCValueRetain(kMCEmptyString);
	return true;
}

bool
MCS_set_session_lifetime(uint32_t p_lifetime)
{
	return true;
}

uint32_t
MCS_get_session_lifetime()
{
	return 0;
}

bool
MCS_set_session_name(MCStringRef p_name)
{
	return true;
}

bool
MCS_get_session_name(MCStringRef & r_name)
{
	r_name = MCValueRetain(kMCEmptyString);
	return true;
}

bool
MCS_set_session_id(MCStringRef p_id)
{
	return true;
}

bool
MCS_get_session_id(MCStringRef & r_id)
{
	r_id = MCValueRetain(kMCEmptyString);
	return true;
}

/* ================================================================
 * Notifications
 * ================================================================ */

/* Other threads post their callbacks to the main thread with
 * MCNotifyPush() (notify.cpp).  The web engine has one thread, so
 * nothing can post one; the engine's shared code refers to it. */
bool
MCNotifyPush(void (*p_callback)(void *),
             void *p_state,
             bool p_block,
             bool p_safe,
             bool p_required)
{
	return false;
}

/* ================================================================
 * System dialogs
 *
 * The web engine has no system file, folder or color dialogs (its
 * screen does not report those features), so the engine uses its own
 * dialogs instead and never calls these.
 * ================================================================ */

int
MCA_file(MCStringRef p_title,
         MCStringRef p_prompt,
         MCStringRef p_filter,
         MCStringRef p_initial,
         unsigned int p_options,
         MCStringRef & r_value,
         MCStringRef & r_result)
{
	return 0;
}

int
MCA_ask_file(MCStringRef p_title,
             MCStringRef p_prompt,
             MCStringRef p_filter,
             MCStringRef p_initial,
             unsigned int p_options,
             MCStringRef & r_value,
             MCStringRef & r_result)
{
	return 0;
}

int
MCA_file_with_types(MCStringRef p_title,
                    MCStringRef p_prompt,
                    MCStringRef *p_types,
                    uint4 p_type_count,
                    MCStringRef p_initial,
                    unsigned int p_options,
                    MCStringRef & r_value,
                    MCStringRef & r_result)
{
	return 0;
}

int
MCA_ask_file_with_types(MCStringRef p_title,
                        MCStringRef p_prompt,
                        MCStringRef *p_types,
                        uint4 p_type_count,
                        MCStringRef p_initial,
                        unsigned int p_options,
                        MCStringRef & r_value,
                        MCStringRef & r_result)
{
	return 0;
}

int
MCA_folder(MCStringRef p_title,
           MCStringRef p_prompt,
           MCStringRef p_initial,
           unsigned int p_options,
           MCStringRef & r_value,
           MCStringRef & r_result)
{
	return 0;
}

bool
MCA_color(MCStringRef p_title,
          MCColor p_initial_color,
          bool p_as_sheet,
          bool & r_chosen,
          MCColor & r_chosen_color)
{
	r_chosen = false;
	return true;
}

void
MCA_setcolordialogcolors(MCColor *p_colors,
                         uindex_t p_count)
{
}

void
MCA_getcolordialogcolors(MCColor *& r_colors,
                         uindex_t & r_count)
{
	r_colors = nil;
	r_count = 0;
}
