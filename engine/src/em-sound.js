/*                                                              -*-Javascript-*-

 Copyright (C) 2026 OXT-Beyond contributors.

 This file is part of OXT-Beyond.

 OXT-Beyond is free software; you can redistribute it and/or modify it
 under the terms of the GNU General Public License v3 as published by the
 Free Software Foundation.

 OXT-Beyond is distributed in the hope that it will be useful, but
 WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with OXT-Beyond.  If not see <http://www.gnu.org/licenses/>.  */

// The web engine's sounds: the beep (em-dc.cpp) and audio clips, which
// play does with their samples (aclip.cpp), through the browser's Web
// Audio.
//
// Browsers let a page make a sound once the user has clicked or typed in
// it. Until then the browser holds the sounds back: they start with the
// user's first click or key, unless they would have ended by then. A
// looping audio clip waits for it; a beep or an audio clip that does not
// loop, held back for longer than it lasts, has played as far as the
// stack can tell (the sound is done, and playStopped is sent, as on the
// desktop) and is not heard after.

mergeInto(LibraryManager.library, {

	$LiveCodeSound: {

		// The page's audio context, made when it is first needed, and the
		// gain that the playLoudness sets
		_context: null,
		_master: null,
		_volume: 1,

		// The audio clips playing, by id: {source, ended}
		_sounds: {},
		_nextSound: 1,

		// The audio context, or null if the browser has none
		context: function() {
			if (LiveCodeSound._context) {
				return LiveCodeSound._context;
			}
			var AudioContext = window.AudioContext || window.webkitAudioContext;
			if (!AudioContext) {
				return null;
			}
			try {
				var context = new AudioContext();
				var master = context.createGain();
				master.gain.value = LiveCodeSound._volume;
				master.connect(context.destination);
				LiveCodeSound._context = context;
				LiveCodeSound._master = master;
			} catch (e) {
				return null;
			}
			// The sounds start with the user's first click or key
			var events = ['pointerdown', 'mousedown', 'touchend', 'keydown'];
			var unlock = function() {
				if (LiveCodeSound._context.state != 'suspended') {
					events.forEach(function(type) {
						document.removeEventListener(type, unlock, true);
					});
					return;
				}
				LiveCodeSound._resume();
			};
			events.forEach(function(type) {
				document.addEventListener(type, unlock, true);
			});
			LiveCodeSound._resume();
			return LiveCodeSound._context;
		},

		_resume: function() {
			var context = LiveCodeSound._context;
			if (!context || context.state != 'suspended') {
				return;
			}
			// Before the user's first click or key, the browser refuses
			// (and says so in the console)
			var activation = navigator.userActivation;
			if (activation && !activation.hasBeenActive) {
				return;
			}
			try {
				var resumed = context.resume();
				if (resumed && resumed.catch) {
					resumed.catch(function() {});
				}
			} catch (e) {
			}
		},

		// Whether the browser is playing the page's sounds, rather than
		// holding them back
		_running: function() {
			return LiveCodeSound._context != null && LiveCodeSound._context.state == 'running';
		},

		// The playLoudness, from 0 to 100
		setVolume: function(loudness) {
			LiveCodeSound._volume = Math.max(0, Math.min(loudness, 100)) / 100;
			if (LiveCodeSound._master) {
				LiveCodeSound._master.gain.value = LiveCodeSound._volume;
			}
		},

		// A tone of <pitch> Hz for <duration> ms, at <loudness> percent
		beep: function(pitch, duration, loudness) {
			if (duration <= 0 || loudness <= 0 || pitch <= 0) {
				return;
			}
			var audio = LiveCodeSound.context();
			if (!audio) {
				return;
			}
			try {
				LiveCodeSound._resume();
				var start = audio.currentTime;
				var length = duration / 1000;
				var fade = Math.min(0.005, length / 4);
				var level = 0.25 * Math.min(loudness, 100) / 100;
				var oscillator = audio.createOscillator();
				var gain = audio.createGain();
				oscillator.type = 'sine';
				oscillator.frequency.value = Math.min(pitch, 20000);
				gain.gain.setValueAtTime(0, start);
				gain.gain.linearRampToValueAtTime(level, start + fade);
				gain.gain.setValueAtTime(level, start + length - fade);
				gain.gain.linearRampToValueAtTime(0, start + length);
				oscillator.connect(gain);
				gain.connect(audio.destination);
				oscillator.start(start);
				oscillator.stop(start + length);
				// Not heard after the user's first click or key, if the
				// browser holds it back for longer than it lasts
				if (!LiveCodeSound._running()) {
					setTimeout(function() {
						if (!LiveCodeSound._running()) {
							gain.disconnect();
						}
					}, duration);
				}
			} catch (e) {
			}
		},

		// A mu-law byte as a 16-bit sample (G.711)
		_mulaw: function(byte) {
			var u = ~byte & 0xff;
			var magnitude = ((((u & 0x0f) << 3) + 0x84) << ((u >> 4) & 7)) - 0x84;
			return (u & 0x80) ? -magnitude : magnitude;
		},

		// The samples of an audio clip as the browser's: one array of
		// numbers from -1 to 1 for each channel. <format> is the clip's
		// (enum Audio_format, aclip.h): 0 linear and signed, big-endian
		// when a sample is more than a byte (from an AU or AIFF file); 1
		// mu-law; 2 linear, unsigned when a sample is a byte, else signed
		// and little-endian (from a WAV file).
		_decode: function(bytes, format, width, channels) {
			var frame = width * channels;
			var frames = Math.floor(bytes.length / frame);
			var data = [];
			for (var c = 0; c < channels; c++) {
				data.push(new Float32Array(frames));
			}
			var full = Math.pow(2, width * 8);
			var half = full / 2;
			for (var i = 0; i < frames; i++) {
				for (c = 0; c < channels; c++) {
					var at = i * frame + c * width;
					var value;
					if (format == 1) {
						value = LiveCodeSound._mulaw(bytes[at]) / 32768;
					} else if (width == 1) {
						value = format == 2 ? (bytes[at] - 128) / 128 : ((bytes[at] << 24) >> 24) / 128;
					} else {
						var sample = 0;
						var k;
						if (format == 2) {
							for (k = width - 1; k >= 0; k--) {
								sample = sample * 256 + bytes[at + k];
							}
						} else {
							for (k = 0; k < width; k++) {
								sample = sample * 256 + bytes[at + k];
							}
						}
						if (sample >= half) {
							sample -= full;
						}
						value = sample / half;
					}
					data[c][i] = value;
				}
			}
			return data;
		},

		// Plays <size> bytes of samples at <pointer>; returns the sound's
		// id, or 0 if the browser cannot play it
		play: function(pointer, size, format, width, channels, rate, loudness, looping) {
			var audio = LiveCodeSound.context();
			if (!audio || size == 0 || width < 1 || width > 4 || channels < 1 || rate < 1) {
				return 0;
			}
			try {
				var data = LiveCodeSound._decode(HEAPU8.subarray(pointer, pointer + size),
				                                 format, format == 1 ? 1 : width, channels);
				if (data[0].length == 0) {
					return 0;
				}
				var buffer = LiveCodeSound._buffer(audio, data, rate);
				var source = audio.createBufferSource();
				source.buffer = buffer;
				source.loop = !!looping;
				var gain = audio.createGain();
				gain.gain.value = Math.max(0, Math.min(loudness, 100)) / 100;
				source.connect(gain);
				gain.connect(LiveCodeSound._master);

				// Until when it would play, if the browser holds it back
				var id = LiveCodeSound._nextSound++;
				var sound = {'source': source,
				             'ended': false,
				             'until': looping ? 0 : performance.now() + buffer.duration * 1000};
				source.onended = function() {
					sound.ended = true;
				};
				LiveCodeSound._sounds[id] = sound;
				LiveCodeSound._resume();
				source.start();
				return id;
			} catch (e) {
				return 0;
			}
		},

		// The browser's buffer of the samples: at their rate, or at the
		// browser's if it takes no other (older browsers take none below
		// 22050 Hz)
		_buffer: function(audio, data, rate) {
			var channels = data.length;
			var frames = data[0].length;
			var buffer = null;
			var c;
			try {
				buffer = audio.createBuffer(channels, frames, rate);
			} catch (e) {
			}
			if (buffer == null) {
				var ratio = rate / audio.sampleRate;
				var length = Math.max(1, Math.floor(frames / ratio));
				buffer = audio.createBuffer(channels, length, audio.sampleRate);
				for (c = 0; c < channels; c++) {
					var from = data[c];
					var to = new Float32Array(length);
					for (var i = 0; i < length; i++) {
						var at = i * ratio;
						var before = Math.floor(at);
						var after = Math.min(before + 1, frames - 1);
						to[i] = from[before] + (from[after] - from[before]) * (at - before);
					}
					data[c] = to;
				}
			}
			for (c = 0; c < channels; c++) {
				buffer.getChannelData(c).set(data[c]);
			}
			return buffer;
		},

		isPlaying: function(id) {
			var sound = LiveCodeSound._sounds[id];
			if (!sound || sound.ended) {
				return false;
			}
			// Held back by the browser for longer than it lasts
			if (sound.until != 0 && !LiveCodeSound._running() && performance.now() > sound.until) {
				return false;
			}
			return true;
		},

		stop: function(id) {
			var sound = LiveCodeSound._sounds[id];
			if (!sound) {
				return;
			}
			delete LiveCodeSound._sounds[id];
			sound.source.onended = null;
			try {
				sound.source.stop();
			} catch (e) {
			}
			sound.source.disconnect();
		},
	},

	MCEmscriptenBeep__deps: ['$LiveCodeSound'],
	MCEmscriptenBeep: function(p_pitch, p_duration, p_loudness) {
		LiveCodeSound.beep(p_pitch, p_duration, p_loudness);
	},

	MCEmscriptenSoundPlay__deps: ['$LiveCodeSound'],
	MCEmscriptenSoundPlay: function(p_samples, p_size, p_format, p_width, p_channels, p_rate, p_loudness, p_looping) {
		return LiveCodeSound.play(p_samples, p_size, p_format, p_width, p_channels, p_rate, p_loudness, p_looping);
	},

	MCEmscriptenSoundIsPlaying__deps: ['$LiveCodeSound'],
	MCEmscriptenSoundIsPlaying: function(p_sound) {
		return LiveCodeSound.isPlaying(p_sound);
	},

	MCEmscriptenSoundStop__deps: ['$LiveCodeSound'],
	MCEmscriptenSoundStop: function(p_sound) {
		LiveCodeSound.stop(p_sound);
	},

	MCEmscriptenSoundSetVolume__deps: ['$LiveCodeSound'],
	MCEmscriptenSoundSetVolume: function(p_loudness) {
		LiveCodeSound.setVolume(p_loudness);
	},
});
