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
#include "mcio.h"

#include "sysdefs.h"
#include "osspec.h"
#include "globals.h"
#include "util.h"
#include "variable.h"
#include "socket.h"

/* ================================================================
 * Socket handling
 *
 * A web page cannot open sockets, so the web engine never has one:
 * opening a socket fails, and name lookups find nothing, as they do
 * on the desktop when sockets cannot be initialised.  (LiveCode's HTML5
 * engine was linked without most of these functions, and stopped when
 * a script reached one.)
 * ================================================================ */

MCSocket *
MCS_accept(uint16_t p_port,
           MCObject *p_object,
           MCNameRef p_message,
           Boolean p_datagram,
           Boolean p_secure,
           Boolean p_sslverify,
           MCStringRef p_sslcertfile)
{
	MCEmscriptenNotImplemented();
	return nil;
}

bool
MCS_ha(MCSocket *p_socket,
       MCStringRef & r_address)
{
	MCEmscriptenNotImplemented();
	return false;
}

MCSocket *
MCS_open_socket(MCNameRef p_name,
                MCNameRef p_from,
                Boolean p_datagram,
                MCObject *p_object,
                MCNameRef p_message,
                Boolean p_secure,
                Boolean p_sslverify,
                MCStringRef p_sslcertfile,
                MCNameRef p_end_hostname)
{
	MCresult->sets("not supported");
	return nil;
}

/* No socket is ever made, so the functions below that take one, and
 * the socket list functions, are never called; the engine's shared
 * code refers to them. */

void
MCS_close_socket(MCSocket *p_socket)
{
	p_socket->closing = True;
}

MCDataRef
MCS_read_socket(MCSocket *p_socket,
                MCExecContext & ctxt,
                uint4 p_length,
                const char *p_until,
                MCNameRef p_message)
{
	return nil;
}

void
MCS_write_socket(const MCStringRef p_data,
                 MCSocket *p_socket,
                 MCObject *p_object,
                 MCNameRef p_message)
{
}

void
MCS_secure_socket(MCSocket *p_socket,
                  Boolean p_sslverify,
                  MCNameRef p_end_hostname)
{
}

bool
MCS_pa(MCSocket *p_socket,
       MCStringRef & r_address)
{
	r_address = MCValueRetain(kMCEmptyString);
	return false;
}

void
MCSocketsAppendToSocketList(MCSocket *p_socket)
{
	MCU_realloc((char **)&MCsockets, MCnsockets, MCnsockets + 1,
	            sizeof(MCSocket *));
	MCsockets[MCnsockets++] = p_socket;
}

void
MCSocketsRemoveFromSocketList(uint32_t p_socket_no)
{
	delete MCsockets[p_socket_no];
	for (uint32_t i = p_socket_no + 1; i < MCnsockets; ++i)
	{
		MCsockets[i - 1] = MCsockets[i];
	}
	MCnsockets--;
}

MCSocket::~MCSocket()
{
}

void
MCSocket::doclose()
{
}

/* ================================================================
 * Host names and addresses
 * ================================================================ */

bool
MCS_hn(MCStringRef & r_name)
{
	r_name = MCValueRetain(kMCEmptyString);
	return true;
}

bool
MCS_aton(MCStringRef p_address,
         MCStringRef & r_name)
{
	r_name = MCValueRetain(kMCEmptyString);
	return true;
}

bool
MCS_ntoa(MCStringRef p_hostname,
         MCObject *p_target,
         MCNameRef p_message,
         MCListRef & r_addresses)
{
	r_addresses = MCValueRetain(kMCEmptyList);
	return true;
}

bool
MCS_dnsresolve(MCStringRef p_hostname,
               MCStringRef & r_address)
{
	return false;
}

bool
MCS_hostaddress(MCStringRef & r_address)
{
	return false;
}
