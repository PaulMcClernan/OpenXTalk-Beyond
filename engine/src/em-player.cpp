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

/* The web engine's player (player-legacy.cpp calls these): a <video>
 * element of the page (em-player.js), placed over the stack's canvas as
 * the player's native layer, as a widget's element is.
 *
 * Times are in milliseconds, so the timeScale is 1000, as on Linux. The
 * page loads a movie while the engine runs on, so preparing one waits
 * (as the desktop's players do) until the browser knows its duration
 * and size, or that it cannot play it. */

#include "prefix.h"

#include "globdefs.h"
#include "filedefs.h"
#include "objdefs.h"
#include "parsedef.h"
#include "mcio.h"

#include "util.h"
#include "stack.h"
#include "card.h"
#include "param.h"
#include "globals.h"
#include "osspec.h"
#include "player.h"
#include "graphics_util.h"

#include "em-async.h"
#include "jsobject.h"

////////////////////////////////////////////////////////////////////////////////

extern "C" uintptr_t MCEmscriptenPlayerCreate(uint32_t p_id);
extern "C" void MCEmscriptenPlayerDestroy(uint32_t p_id);
extern "C" bool MCEmscriptenPlayerSetSource(uint32_t p_id, const unichar_t *p_path, uint32_t p_length);
extern "C" int32_t MCEmscriptenPlayerGetState(uint32_t p_id);
extern "C" void MCEmscriptenPlayerPlay(uint32_t p_id);
extern "C" void MCEmscriptenPlayerPause(uint32_t p_id);
extern "C" bool MCEmscriptenPlayerIsPaused(uint32_t p_id);
extern "C" double MCEmscriptenPlayerGetTime(uint32_t p_id);
extern "C" void MCEmscriptenPlayerSetTime(uint32_t p_id, double p_time);
extern "C" double MCEmscriptenPlayerGetDuration(uint32_t p_id);
extern "C" double MCEmscriptenPlayerGetLoaded(uint32_t p_id);
extern "C" void MCEmscriptenPlayerGetVideoSize(uint32_t p_id, int32_t *r_width, int32_t *r_height);
extern "C" void MCEmscriptenPlayerSetLooping(uint32_t p_id, bool p_looping);
extern "C" void MCEmscriptenPlayerSetRate(uint32_t p_id, double p_rate);
extern "C" void MCEmscriptenPlayerSetVolume(uint32_t p_id, uint32_t p_volume);
extern "C" uint32_t MCEmscriptenPlayerGetVolume(uint32_t p_id);
extern "C" void MCEmscriptenPlayerSetControls(uint32_t p_id, bool p_show);
extern "C" void MCEmscriptenPlayerSetSelection(uint32_t p_id, double p_start, double p_end, bool p_only);
extern "C" void MCEmscriptenPlayerSetCallbacks(uint32_t p_id, const double *p_times, uint32_t p_count);

extern "C" MCJSObjectRef MCEmscriptenJSObjectFromID(MCJSObjectID p_id);

/* The events of a player's element (LiveCodePlayer.kReady ...); a
 * callback's is kMCEmscriptenPlayerEventCallback plus its index */
enum MCEmscriptenPlayerEvent
{
	kMCEmscriptenPlayerEventReady = 1,
	kMCEmscriptenPlayerEventEnded = 2,
	kMCEmscriptenPlayerEventPlayed = 3,
	kMCEmscriptenPlayerEventPaused = 4,
	kMCEmscriptenPlayerEventSeeked = 5,
	kMCEmscriptenPlayerEventFailed = 6,
	kMCEmscriptenPlayerEventTimeChanged = 7,
	kMCEmscriptenPlayerEventCallback = 100,
};

/* The time scale: milliseconds */
static const double kMCWebPlayerTimeScale = 1000.0;

/* How long preparing a movie waits for the browser to load it (seconds) */
static const real64_t kMCWebPlayerLoadTimeout = 15.0;

/* A callback of the player: at <time> (in the time scale), send <message>
 * with <parameter> */
struct MCWebPlayerCallback
{
	double time;
	MCNameRef message;
	MCStringRef parameter;
};

struct MCWebPlayer
{
	uint32_t id;
	MCJSObjectRef element;
	MCWebPlayerCallback *callbacks;
	uindex_t callback_count;
};

static uint32_t s_web_player_next_id = 1;

////////////////////////////////////////////////////////////////////////////////

static double
web_seconds(MCPlayerDuration p_time)
{
	return p_time / kMCWebPlayerTimeScale;
}

static MCPlayerDuration
web_duration(double p_seconds)
{
	if (!(p_seconds > 0))
		return 0;
	return (MCPlayerDuration)(p_seconds * kMCWebPlayerTimeScale + 0.5);
}

static void
web_freecallbacks(MCWebPlayer *p_web)
{
	for (uindex_t i = 0; i < p_web->callback_count; i++)
	{
		MCValueRelease(p_web->callbacks[i].message);
		MCValueRelease(p_web->callbacks[i].parameter);
	}
	delete[] p_web->callbacks;
	p_web->callbacks = nil;
	p_web->callback_count = 0;
}

MCPlayer *
MCPlayer::web_find(uint32_t p_id)
{
	for (MCPlayerHandle t_player = MCplayers; t_player.IsValid(); t_player = t_player->getnextplayer())
	{
		if (t_player->m_web != nil && t_player->m_web->id == p_id)
			return t_player;
	}
	return nil;
}

bool
MCPlayer::web_haselement(void)
{
	return m_web != nil && m_web->element != nil;
}

/* Makes the player's element, and puts it over the stack's canvas */
bool
MCPlayer::web_create(void)
{
	if (m_web == nil)
	{
		m_web = new (nothrow) MCWebPlayer;
		if (m_web == nil)
			return false;
		m_web->id = 0;
		m_web->element = nil;
		m_web->callbacks = nil;
		m_web->callback_count = 0;
	}

	if (m_web->element != nil)
		return true;

	m_web->id = s_web_player_next_id++;
	MCJSObjectRef t_element;
	t_element = MCEmscriptenJSObjectFromID(MCEmscriptenPlayerCreate(m_web->id));
	if (t_element == nil)
	{
		MCEmscriptenPlayerDestroy(m_web->id);
		return false;
	}
	m_web->element = t_element;

	SetNativeView(t_element);
	return true;
}

/* Removes the player's element from the page, and forgets it */
void
MCPlayer::web_release(void)
{
	if (m_web == nil)
		return;

	if (m_web->element != nil)
	{
		SetNativeView(nil);
		MCEmscriptenPlayerDestroy(m_web->id);
		MCValueRelease(m_web->element);
		m_web->element = nil;
	}

	web_freecallbacks(m_web);
	delete m_web;
	m_web = nil;
}

Boolean
MCPlayer::web_prepare(void)
{
	MCAutoStringRef t_path;
	if (!resolveplayerfilename(filename, &t_path))
		t_path = filename;

	if (!web_create())
		return False;

	MCAutoStringRefAsUTF16String t_path_u16;
	if (!t_path_u16.Lock(*t_path) ||
	    !MCEmscriptenPlayerSetSource(m_web->id, t_path_u16.Ptr(), t_path_u16.Size()))
	{
		web_release();
		MCresult->sets("could not create movie reference");
		return False;
	}

	MCEmscriptenPlayerSetLooping(m_web->id, getflag(F_LOOPING));
	MCEmscriptenPlayerSetVolume(m_web->id, loudness);
	MCEmscriptenPlayerSetControls(m_web->id, getflag(F_SHOW_CONTROLLER) && getflag(F_VISIBLE));
	if (rate > 0)
		MCEmscriptenPlayerSetRate(m_web->id, rate);
	web_setselection();
	web_synccallbacks();

	/* Waits until the browser knows the movie's duration and size, as
	 * the desktop's players do, unless the engine cannot wait (in a
	 * handler that the page called) */
	if (MCEmscriptenAsyncCanYield())
	{
		real64_t t_deadline = MCS_time() + kMCWebPlayerLoadTimeout;
		while (!MCquit && m_web != nil &&
		       MCEmscriptenPlayerGetState(m_web->id) == 0 &&
		       MCS_time() < t_deadline)
		{
			MCscreen->wait(0.1, False, True);
		}

		if (m_web == nil || MCEmscriptenPlayerGetState(m_web->id) < 0)
		{
			web_release();
			MCresult->sets("could not create movie reference");
			return False;
		}
	}

	if (lasttime != 0)
		MCEmscriptenPlayerSetTime(m_web->id, web_seconds(lasttime));

	web_fitmovie();
	MCresult->clear(False);
	return True;
}

/* A player that play videoClip made, at a point, takes the movie's size */
void
MCPlayer::web_fitmovie(void)
{
	if (!disposable || rect.width > 1 || rect.height > 1)
		return;

	MCRectangle t_movie;
	t_movie = web_getpreferredrect();
	if (t_movie.width == 0 || t_movie.height == 0)
		return;

	MCRectangle t_rect;
	t_rect.width = t_movie.width;
	t_rect.height = t_movie.height;
	t_rect.x = rect.x - t_movie.width / 2;
	t_rect.y = rect.y - t_movie.height / 2;
	setrect(t_rect);
	layer_redrawall();
}

Boolean
MCPlayer::web_playpause(Boolean on)
{
	if (!web_haselement())
		return False;

	if (on)
		MCEmscriptenPlayerPause(m_web->id);
	else
		MCEmscriptenPlayerPlay(m_web->id);
	return True;
}

/* A step is about a frame */
void
MCPlayer::web_playstep(int p_direction)
{
	if (!web_haselement())
		return;

	if (!MCEmscriptenPlayerIsPaused(m_web->id))
	{
		MCEmscriptenPlayerPause(m_web->id);
		state |= CS_PAUSED;
	}

	double t_time;
	t_time = MCEmscriptenPlayerGetTime(m_web->id) + p_direction / 30.0;
	t_time = MCClamp(t_time, 0.0, MCEmscriptenPlayerGetDuration(m_web->id));
	MCEmscriptenPlayerSetTime(m_web->id, t_time);
}

void
MCPlayer::web_playstop(void)
{
	web_release();
}

MCPlayerDuration
MCPlayer::web_getduration(void)
{
	if (!web_haselement())
		return 0;
	return web_duration(MCEmscriptenPlayerGetDuration(m_web->id));
}

MCPlayerDuration
MCPlayer::web_gettimescale(void)
{
	if (!web_haselement())
		return 0;
	return (MCPlayerDuration)kMCWebPlayerTimeScale;
}

MCPlayerDuration
MCPlayer::web_getmoviecurtime(void)
{
	if (!web_haselement())
		return lasttime;
	return web_duration(MCEmscriptenPlayerGetTime(m_web->id));
}

MCPlayerDuration
MCPlayer::web_getloadedtime(void)
{
	if (!web_haselement())
		return 0;
	return web_duration(MCEmscriptenPlayerGetLoaded(m_web->id));
}

void
MCPlayer::web_setcurtime(MCPlayerDuration p_time)
{
	if (web_haselement())
		MCEmscriptenPlayerSetTime(m_web->id, web_seconds(p_time));
}

/* The selection, and whether only it plays */
void
MCPlayer::web_setselection(void)
{
	if (!web_haselement())
		return;

	bool t_has_selection;
	t_has_selection = starttime != MAXUINT4 && endtime != MAXUINT4 && endtime > starttime;
	MCEmscriptenPlayerSetSelection(m_web->id,
	                               t_has_selection ? web_seconds(starttime) : -1.0,
	                               t_has_selection ? web_seconds(endtime) : -1.0,
	                               t_has_selection && getflag(F_PLAY_SELECTION));
}

void
MCPlayer::web_setlooping(Boolean p_loop)
{
	if (web_haselement())
		MCEmscriptenPlayerSetLooping(m_web->id, p_loop == True);
}

/* A playRate above zero plays at that rate (browsers play no rate below
 * zero), and zero pauses */
void
MCPlayer::web_setplayrate(void)
{
	if (!web_haselement())
		return;

	if (rate > 0)
	{
		MCEmscriptenPlayerSetRate(m_web->id, rate);
		if (MCEmscriptenPlayerIsPaused(m_web->id))
			MCEmscriptenPlayerPlay(m_web->id);
	}
	else
		MCEmscriptenPlayerPause(m_web->id);
}

Boolean
MCPlayer::web_ispaused(void)
{
	if (!web_haselement())
		return True;
	return MCEmscriptenPlayerIsPaused(m_web->id);
}

void
MCPlayer::web_showcontroller(Boolean p_show)
{
	if (web_haselement())
		MCEmscriptenPlayerSetControls(m_web->id, p_show == True);
}

void
MCPlayer::web_setloudness(uint2 p_loudness)
{
	if (web_haselement())
		MCEmscriptenPlayerSetVolume(m_web->id, p_loudness);
}

/* The volume, as the user may have set it with the browser's controls */
uint2
MCPlayer::web_getloudness(void)
{
	if (!web_haselement())
		return loudness;
	return MCMin(MCEmscriptenPlayerGetVolume(m_web->id), 100U);
}

MCRectangle
MCPlayer::web_getpreferredrect(void)
{
	int32_t t_width = 0, t_height = 0;
	if (web_haselement())
		MCEmscriptenPlayerGetVideoSize(m_web->id, &t_width, &t_height);
	return MCRectangleMake(0, 0, MCMax(t_width, 0), MCMax(t_height, 0));
}

/* The callbacks property: lines of a time and a message, with an optional
 * parameter after the message (by default, the time) */
void
MCPlayer::web_synccallbacks(void)
{
	if (m_web == nil)
		return;

	web_freecallbacks(m_web);

	uindex_t t_count = 0;
	MCAutoProperListRef t_list;
	if (!MCStringIsEmpty(userCallbackStr) &&
	    MCStringSplitByDelimiter(userCallbackStr, kMCLineEndString, kMCStringOptionCompareExact, &t_list))
		t_count = MCProperListGetLength(*t_list);

	if (t_count > 0)
		m_web->callbacks = new (nothrow) MCWebPlayerCallback[t_count];
	if (m_web->callbacks == nil)
		t_count = 0;

	uindex_t t_used = 0;
	for (uindex_t i = 0; i < t_count; i++)
	{
		MCStringRef t_line;
		t_line = static_cast<MCStringRef>(MCProperListFetchElementAtIndex(*t_list, i));

		uindex_t t_comma;
		if (!MCStringFirstIndexOfChar(t_line, ',', 0, kMCStringOptionCompareExact, t_comma))
			continue;

		MCAutoStringRef t_time_string, t_rest;
		MCAutoNumberRef t_time;
		if (!MCStringCopySubstring(t_line, MCRangeMake(0, t_comma), &t_time_string) ||
		    !MCStringCopySubstring(t_line, MCRangeMakeMinMax(t_comma + 1, MCStringGetLength(t_line)), &t_rest))
			continue;

		/* The message, then its parameter after a space */
		uindex_t t_start = 0, t_length = MCStringGetLength(*t_rest);
		while (t_start < t_length && isspace(MCStringGetCharAtIndex(*t_rest, t_start)))
			t_start++;
		uindex_t t_space = t_start;
		while (t_space < t_length && !isspace(MCStringGetCharAtIndex(*t_rest, t_space)))
			t_space++;

		MCAutoStringRef t_message, t_parameter;
		MCNewAutoNameRef t_message_name;
		if (!MCStringCopySubstring(*t_rest, MCRangeMakeMinMax(t_start, t_space), &t_message) ||
		    MCStringIsEmpty(*t_message) ||
		    !MCNameCreate(*t_message, &t_message_name))
			continue;
		if (t_space < t_length)
		{
			if (!MCStringCopySubstring(*t_rest, MCRangeMakeMinMax(t_space, t_length), &t_parameter))
				continue;
		}
		else
			t_parameter = *t_time_string;

		MCWebPlayerCallback &t_callback = m_web->callbacks[t_used];
		if (MCNumberParse(*t_time_string, &t_time))
			t_callback.time = MCNumberFetchAsReal(*t_time);
		else
			t_callback.time = 0;
		t_callback.message = MCValueRetain(*t_message_name);
		t_callback.parameter = MCValueRetain(*t_parameter);
		t_used++;
	}
	m_web->callback_count = t_used;

	if (m_web->element == nil)
		return;

	double *t_times = nil;
	if (t_used > 0)
		t_times = new (nothrow) double[t_used];
	if (t_times == nil)
		t_used = 0;
	for (uindex_t i = 0; i < t_used; i++)
		t_times[i] = web_seconds(m_web->callbacks[i].time);
	MCEmscriptenPlayerSetCallbacks(m_web->id, t_times, t_used);
	delete[] t_times;
}

/* The element's video is inside the player's border */
MCRectangle
MCPlayer::GetNativeViewRect(const MCRectangle &p_object_rect)
{
	return MCU_reduce_rect(p_object_rect, getflag(F_SHOW_BORDER) ? borderwidth : 0);
}

/* An event of the player's element: the movie loaded or failed, it
 * ended, the user played, paused or moved it with the browser's controls,
 * or it passed the time of a callback */
void
MCPlayer::web_handleevent(uint32_t p_event)
{
	switch (p_event)
	{
		case kMCEmscriptenPlayerEventReady:
			web_fitmovie();
			layer_redrawall();
			break;

		case kMCEmscriptenPlayerEventFailed:
			if (disposable)
				MCscreen->delaymessage(this, MCM_play_stopped);
			break;

		case kMCEmscriptenPlayerEventEnded:
			state |= CS_PAUSED;
			MCscreen->delaymessage(this, MCM_play_stopped);
			break;

		case kMCEmscriptenPlayerEventPlayed:
			if (getstate(CS_PAUSED))
			{
				state &= ~CS_PAUSED;
				MCscreen->delaymessage(this, MCM_play_started);
			}
			break;

		case kMCEmscriptenPlayerEventPaused:
			if (!getstate(CS_PAUSED))
			{
				state |= CS_PAUSED;
				MCscreen->delaymessage(this, MCM_play_paused);
			}
			break;

		/* As the Mac and Windows players do, one currentTimeChanged at a
		 * time: the message takes the time when it is sent (timer()) */
		case kMCEmscriptenPlayerEventSeeked:
		case kMCEmscriptenPlayerEventTimeChanged:
			if (!getstate(CS_CTC_PENDING))
			{
				MCParameter *t_param = new (nothrow) MCParameter;
				if (t_param != nil)
				{
					state |= CS_CTC_PENDING;
					t_param->setn_argument(web_getmoviecurtime());
					MCscreen->addmessage(this, MCM_current_time_changed, 0, t_param);
				}
			}
			break;

		default:
			if (p_event >= kMCEmscriptenPlayerEventCallback && m_web != nil &&
			    p_event - kMCEmscriptenPlayerEventCallback < m_web->callback_count)
			{
				MCWebPlayerCallback &t_callback = m_web->callbacks[p_event - kMCEmscriptenPlayerEventCallback];
				MCParameter *t_param = new (nothrow) MCParameter;
				if (t_param != nil)
				{
					t_param->setvalueref_argument(t_callback.parameter);
					MCscreen->addmessage(this, t_callback.message, 0, t_param);
				}
			}
			break;
	}
}

/* Called by the page (em-player.js) for each event of a player's
 * element */
extern "C" MC_DLLEXPORT_DEF void
MCEmscriptenPlayerHandleEvent(uint32_t p_id, uint32_t p_event)
{
	MCPlayer *t_player;
	t_player = MCPlayer::web_find(p_id);
	if (t_player != nil)
		t_player->web_handleevent(p_event);
}
