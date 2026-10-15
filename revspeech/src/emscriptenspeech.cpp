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

/* revSpeech in a web standalone: the browser's speech synthesis (the Web
 * Speech API), which speaks with the voices of the system it runs on. The
 * web engine links revSpeech into itself, as it does the other externals
 * that can run in a browser (engine/src/em-externals.cpp).
 *
 * The speed, pitch and volume are on the scales they have on Windows
 * (w32sapi5speech.cpp), where a speed or a pitch of 210 is the voice's own
 * and each goes from 30 to 390: a speed of 30 speaks at a third of the
 * voice's own rate and 390 at three times it, as SAPI's rates -10 and 10
 * do; a pitch of 30 is the lowest and 390 the highest the browser has. The
 * volume goes from 0 to 100. They and the voice apply to what is spoken
 * after they are set, and speaking stops what is being spoken first, as on
 * a Mac.
 *
 * The voices' names go to and from the script as UTF-8 (revspeech.cpp
 * declares revSpeechVoices and revSetSpeechVoice so for the web), because
 * a browser's voices have names in any script. A browser gives the names
 * only, so revSpeechVoices with "male" or "female" lists the voices whose
 * names say so. A browser lets a page speak only once the user has clicked
 * or typed in it. */

#include <emscripten.h>

#include <cmath>
#include <cstdlib>
#include <cstring>

#include "revspeech.h"

// The scale of a speed and a pitch, and its middle: the voice's own
#define kNarratorScaleLowest 30
#define kNarratorScaleMiddle 210
#define kNarratorScaleHighest 390

EM_JS_DEPS(revspeech, "$UTF8ToString,$stringToNewUTF8");

// Whether the browser can speak
EM_JS(bool, revspeech_js_available, (void), {
	return typeof speechSynthesis != 'undefined' &&
		typeof SpeechSynthesisUtterance != 'undefined';
});

// Asks for the voices, which some browsers load only once a page asks
EM_JS(void, revspeech_js_load_voices, (void), {
	if (typeof speechSynthesis != 'undefined') {
		speechSynthesis.getVoices();
	}
});

// Speaks <text> (UTF-8) with the voice named <voice> (or the default
// one, if there is no such voice), at <rate>, <pitch> and <volume> (the
// Web Speech API's), after stopping what it was saying
EM_JS(void, revspeech_js_speak, (const char *text, const char *voice, double rate, double pitch, double volume), {
	if (typeof speechSynthesis == 'undefined') {
		return;
	}
	var utterance = new SpeechSynthesisUtterance(UTF8ToString(text));
	var name = UTF8ToString(voice);
	if (name != '') {
		var voices = speechSynthesis.getVoices();
		for (var i = 0; i < voices.length; i++) {
			if (voices[i].name == name) {
				utterance.voice = voices[i];
				break;
			}
		}
	}
	utterance.rate = rate;
	utterance.pitch = pitch;
	utterance.volume = volume;
	speechSynthesis.cancel();
	speechSynthesis.speak(utterance);
});

EM_JS(void, revspeech_js_stop, (void), {
	if (typeof speechSynthesis != 'undefined') {
		speechSynthesis.cancel();
	}
});

EM_JS(bool, revspeech_js_busy, (void), {
	return typeof speechSynthesis != 'undefined' &&
		(speechSynthesis.speaking || speechSynthesis.pending);
});

// The names of the voices (UTF-8, one a line, which the caller frees):
// those whose names have the word <gender> (1 male, 2 female, 3 neuter or
// neutral, as Windows calls it), or with 0, all of them. (A backslash
// outside a JavaScript string here would become a C escape, so no \b.)
EM_JS(char *, revspeech_js_voices, (int gender), {
	var voices = typeof speechSynthesis != 'undefined' ? speechSynthesis.getVoices() : [];
	var says = [[], ['male'], ['female'], ['neuter', 'neutral']][gender] || [];
	var names = [];
	for (var i = 0; i < voices.length; i++) {
		var words = voices[i].name.toLowerCase().split(/[^a-z]+/);
		var said = says.length == 0;
		for (var j = 0; j < says.length; j++) {
			if (words.indexOf(says[j]) >= 0) {
				said = true;
			}
		}
		if (said) {
			names.push(voices[i].name);
		}
	}
	return stringToNewUTF8(names.join('\n'));
});

class EmscriptenNarrator: public INarrator
{
public:
	EmscriptenNarrator(void)
		: m_voice(NULL), m_speed(kNarratorScaleMiddle), m_pitch(kNarratorScaleMiddle), m_volume(100)
	{
	}

	virtual ~EmscriptenNarrator(void)
	{
		free(m_voice);
	}

	virtual bool Initialize(void)
	{
		if (!revspeech_js_available())
			return false;
		revspeech_js_load_voices();
		return true;
	}

	// As on the desktop, a narrator that is finalized says so: revSpeech's
	// revUnloadSpeech then keeps it (revspeech.cpp)
	virtual bool Finalize(void)
	{
		revspeech_js_stop();
		return true;
	}

	virtual bool Start(const char *p_string, bool p_is_utf8)
	{
		char *t_text = p_is_utf8 ? strdup(p_string) : NativeToUTF8(p_string);
		if (t_text == NULL)
			return false;

		// A speed's rate on SAPI's scale is a power of 3, from a third of
		// the voice's own to three times it
		double t_rate = pow(3.0, (m_speed - kNarratorScaleMiddle) / double(kNarratorScaleHighest - kNarratorScaleMiddle));
		double t_pitch = (m_pitch - kNarratorScaleLowest) / double(kNarratorScaleMiddle - kNarratorScaleLowest);
		revspeech_js_speak(t_text, m_voice != NULL ? m_voice : "",
		                   Clamp(t_rate, 0.1, 10.0), Clamp(t_pitch, 0.0, 2.0), m_volume / 100.0);
		free(t_text);
		return true;
	}

	virtual bool Stop(void)
	{
		revspeech_js_stop();
		return true;
	}

	virtual bool Busy(void)
	{
		return revspeech_js_busy();
	}

	virtual bool ListVoices(NarratorGender p_gender, NarratorListVoicesCallback p_callback, void *p_context)
	{
		int t_gender = 0;
		if (p_gender == kNarratorGenderMale)
			t_gender = 1;
		else if (p_gender == kNarratorGenderFemale)
			t_gender = 2;
		else if (p_gender == kNarratorGenderNeuter)
			t_gender = 3;

		char *t_names = revspeech_js_voices(t_gender);
		if (t_names == NULL)
			return false;

		bool t_continue = true;
		for (char *t_name = t_names; t_continue && *t_name != '\0'; )
		{
			char *t_end = strchr(t_name, '\n');
			if (t_end != NULL)
				*t_end = '\0';
			t_continue = p_callback(p_context, p_gender, t_name);
			t_name = t_end != NULL ? t_end + 1 : t_name + strlen(t_name);
		}
		free(t_names);
		return true;
	}

	// The name is UTF-8 (revSetSpeechVoice's web declaration)
	virtual bool SetVoice(const char *p_voice)
	{
		char *t_voice = strdup(p_voice);
		if (t_voice == NULL)
			return false;
		free(m_voice);
		m_voice = t_voice;
		return true;
	}

	virtual bool SetSpeed(int p_speed)
	{
		m_speed = p_speed;
		return true;
	}

	virtual bool GetSpeed(int &r_speed)
	{
		r_speed = m_speed;
		return true;
	}

	virtual bool SetPitch(int p_pitch)
	{
		m_pitch = p_pitch;
		return true;
	}

	virtual bool GetPitch(int &r_pitch)
	{
		r_pitch = m_pitch;
		return true;
	}

	// revSpeech keeps the volume from 0 to 100 (revSpeechSetVolume)
	virtual bool SetVolume(int p_volume)
	{
		m_volume = p_volume;
		return true;
	}

	virtual bool GetVolume(int &r_volume)
	{
		r_volume = m_volume;
		return true;
	}

private:
	static double Clamp(double p_value, double p_lowest, double p_highest)
	{
		return p_value < p_lowest ? p_lowest : (p_value > p_highest ? p_highest : p_value);
	}

	// The engine's native text in a web standalone is ISO-8859-1, whose
	// characters are the first 256 of Unicode
	static char *NativeToUTF8(const char *p_string)
	{
		size_t t_length = strlen(p_string);
		char *t_utf8 = (char *)malloc(t_length * 2 + 1);
		if (t_utf8 == NULL)
			return NULL;
		char *t_out = t_utf8;
		for (const unsigned char *t_in = (const unsigned char *)p_string; *t_in != '\0'; t_in++)
		{
			if (*t_in < 0x80)
				*t_out++ = *t_in;
			else
			{
				*t_out++ = char(0xC0 | (*t_in >> 6));
				*t_out++ = char(0x80 | (*t_in & 0x3F));
			}
		}
		*t_out = '\0';
		return t_utf8;
	}

	char *m_voice;
	int m_speed;
	int m_pitch;
	int m_volume;
};

INarrator *InstantiateNarrator(NarratorProvider p_provider)
{
	return new EmscriptenNarrator();
}

INarrator::~INarrator(void)
{
	// Nothing required.
}
