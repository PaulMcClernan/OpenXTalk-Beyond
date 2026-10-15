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

// The web engine's players (em-player.cpp): each is a <video> element of
// the page, which the engine places over the stack's canvas as the
// player's native layer. It plays what the browser plays (MP4 with H.264
// and AAC, WebM, Ogg, MP3, WAV, ...).
//
// The element's events reach the engine as the player's own: its end
// (playStopped), and what the user does with the browser's controls
// (playStarted, playPaused, currentTimeChanged). While it plays, the
// player watches its callbacks and the end of its selection, and tells
// the engine of its time as the Mac and Windows players do (the engine
// sends currentTimeChanged, one at a time).

mergeInto(LibraryManager.library, {

	$LiveCodePlayer__deps: ['$LiveCodeUtil', '$LiveCodeAsync', '$FS'],
	$LiveCodePlayer: {

		// The players, by the engine's id for them
		_players: {},

		// The events the engine hears of (enum MCEmscriptenPlayerEvent,
		// em-player.cpp); a callback's is kCallback plus its index
		kReady: 1,
		kEnded: 2,
		kPlayed: 3,
		kPaused: 4,
		kSeeked: 5,
		kFailed: 6,
		kTimeChanged: 7,
		kCallback: 100,

		// How often a playing player tells the engine of its time (ms),
		// as often as the Windows player does
		_timeInterval: 100,

		// The media types of files the engine gives the browser, by
		// extension: a type the browser can play from a blob
		_types: {
			'mp4': 'video/mp4', 'm4v': 'video/mp4', 'mov': 'video/mp4',
			'webm': 'video/webm', 'ogv': 'video/ogg', 'ogg': 'audio/ogg',
			'oga': 'audio/ogg', 'mp3': 'audio/mpeg', 'm4a': 'audio/mp4',
			'aac': 'audio/aac', 'wav': 'audio/wav', 'flac': 'audio/flac',
			'opus': 'audio/ogg',
		},

		// Makes the element of player <id>, and returns its object id
		// (LiveCodeUtil.storeObject), for the engine's native layer
		create: function(id) {
			var media = document.createElement('video');
			media.setAttribute('playsinline', '');
			media.preload = 'auto';
			media.style.objectFit = 'fill';
			media.style.pointerEvents = 'none';

			var player = {
				'id': id,
				'media': media,
				'url': null,        // an object URL to revoke
				'state': 0,         // 0 loading, 1 ready, -1 failed
				'playing': false,   // the engine wants it playing
				'seekTo': null,     // a seek the engine made
				'start': -1,        // the selection, in seconds
				'end': -1,
				'onlySelection': false,
				'callbacks': [],    // their times, in seconds
				'last': 0,          // the time when callbacks were last checked
				'told': 0,          // when the engine last heard of the time
				'frame': 0,
				'listeners': {},
			};

			var listen = function(type, handler) {
				player.listeners[type] = handler;
				media.addEventListener(type, handler);
			};
			listen('loadedmetadata', function() {
				player.state = 1;
				LiveCodePlayer._notify(player, LiveCodePlayer.kReady);
			});
			listen('error', function() {
				if (player.state == 0 || media.error) {
					player.state = -1;
					LiveCodePlayer._notify(player, LiveCodePlayer.kFailed);
				}
			});
			listen('ended', function() {
				player.playing = false;
				LiveCodePlayer._stopWatching(player);
				LiveCodePlayer._notify(player, LiveCodePlayer.kEnded);
			});
			listen('play', function() {
				LiveCodePlayer._watch(player);
				if (!player.playing) {
					// The user pressed play in the browser's controls
					player.playing = true;
					LiveCodePlayer._notify(player, LiveCodePlayer.kPlayed);
				}
			});
			listen('pause', function() {
				LiveCodePlayer._stopWatching(player);
				// At the end, the element pauses, then ends
				if (player.playing && !media.ended) {
					player.playing = false;
					LiveCodePlayer._notify(player, LiveCodePlayer.kPaused);
				}
			});
			listen('seeked', function() {
				player.last = media.currentTime;
				if (player.seekTo !== null) {
					player.seekTo = null;
					return;
				}
				// The user moved the browser's controls
				LiveCodePlayer._notify(player, LiveCodePlayer.kSeeked);
			});

			LiveCodePlayer._players[id] = player;
			return LiveCodeUtil.storeObject(media);
		},

		destroy: function(id) {
			var player = LiveCodePlayer._players[id];
			if (!player) {
				return;
			}
			delete LiveCodePlayer._players[id];
			LiveCodePlayer._stopWatching(player);
			var media = player.media;
			for (var type in player.listeners) {
				media.removeEventListener(type, player.listeners[type]);
			}
			try {
				media.pause();
				media.removeAttribute('src');
				media.load();
			} catch (e) {
			}
			LiveCodePlayer._revoke(player);
		},

		_revoke: function(player) {
			if (player.url) {
				URL.revokeObjectURL(player.url);
				player.url = null;
			}
		},

		// Tells the engine of an event of the player, and wakes it
		_notify: function(player, event) {
			var id = player.id;
			LiveCodeAsync.resume(function() {
				Module.ccall('MCEmscriptenPlayerHandleEvent', null,
				             ['number', 'number'], [id, event]);
			});
		},

		// Gives the player the file or URL at <path>: an http(s), blob or
		// data URL is the browser's, and a file of the engine's file
		// system (a path, or a file: URL) is given to the browser as a
		// blob. A relative path that is not a file is a URL relative to
		// the page, so a stack's movies can be beside its page on the web
		// server. Returns false if the file cannot be read.
		setSource: function(id, path) {
			var player = LiveCodePlayer._players[id];
			if (!player) {
				return false;
			}
			var media = player.media;
			var url = null;
			if (/^(https?|blob|data):/i.test(path)) {
				url = path;
			} else {
				var file = path;
				if (/^file:/i.test(file)) {
					try {
						file = decodeURIComponent(file.replace(/^file:(\/\/[^\/]*)?/i, ''));
					} catch (e) {
						return false;
					}
				}
				var data = null;
				try {
					if (FS.isFile(FS.stat(file).mode)) {
						data = FS.readFile(file);
					}
				} catch (e) {
				}
				if (data) {
					var dot = file.lastIndexOf('.');
					var type = dot < 0 ? '' : LiveCodePlayer._types[file.substring(dot + 1).toLowerCase()] || '';
					LiveCodePlayer._revoke(player);
					url = URL.createObjectURL(new Blob([data], {'type': type}));
					player.url = url;
				} else if (file.charAt(0) != '/' && file == path) {
					try {
						url = new URL(path, document.baseURI).href;
					} catch (e) {
						return false;
					}
				} else {
					return false;
				}
			}
			player.state = 0;
			player.playing = false;
			player.seekTo = null;
			media.src = url;
			media.load();
			return true;
		},

		state: function(id) {
			var player = LiveCodePlayer._players[id];
			return player ? player.state : -1;
		},

		play: function(id) {
			var player = LiveCodePlayer._players[id];
			if (!player) {
				return;
			}
			var media = player.media;
			player.playing = true;
			// From the start of the selection, when it plays alone
			if (player.onlySelection && player.start >= 0 &&
			    (media.currentTime < player.start || media.currentTime >= player.end)) {
				LiveCodePlayer.setTime(id, player.start);
			} else if (media.ended) {
				LiveCodePlayer.setTime(id, 0);
			}
			LiveCodePlayer._start(player);
		},

		_start: function(player) {
			var media = player.media;
			var started;
			try {
				started = media.play();
			} catch (e) {
				return;
			}
			if (!started || !started.catch) {
				return;
			}
			started.catch(function(error) {
				// Browsers start a movie with sound once the user has
				// clicked or typed in the page: until then it waits
				if (!error || error.name != 'NotAllowedError') {
					return;
				}
				var events = ['pointerdown', 'mousedown', 'touchend', 'keydown'];
				var unlock = function() {
					events.forEach(function(type) {
						document.removeEventListener(type, unlock, true);
					});
					if (player.playing && media.paused && LiveCodePlayer._players[player.id] === player) {
						LiveCodePlayer._start(player);
					}
				};
				events.forEach(function(type) {
					document.addEventListener(type, unlock, true);
				});
			});
		},

		pause: function(id) {
			var player = LiveCodePlayer._players[id];
			if (!player) {
				return;
			}
			player.playing = false;
			player.media.pause();
		},

		// The volume, 0 to 100 (0 when muted)
		getVolume: function(id) {
			var player = LiveCodePlayer._players[id];
			if (!player) {
				return 100;
			}
			return player.media.muted ? 0 : Math.round(player.media.volume * 100);
		},

		isPaused: function(id) {
			var player = LiveCodePlayer._players[id];
			return !player || !player.playing;
		},

		// Times are in seconds
		getTime: function(id) {
			var player = LiveCodePlayer._players[id];
			return player ? player.media.currentTime : 0;
		},

		setTime: function(id, time) {
			var player = LiveCodePlayer._players[id];
			if (!player) {
				return;
			}
			var media = player.media;
			if (media.currentTime == time) {
				return;
			}
			player.seekTo = time;
			player.last = time;
			try {
				media.currentTime = time;
			} catch (e) {
				player.seekTo = null;
			}
		},

		// The duration, or 0 while it is not known (or for a stream that
		// does not end)
		getDuration: function(id) {
			var player = LiveCodePlayer._players[id];
			if (!player || !isFinite(player.media.duration)) {
				return 0;
			}
			return player.media.duration;
		},

		// How much of the movie the browser has, from its start
		getLoaded: function(id) {
			var player = LiveCodePlayer._players[id];
			if (!player) {
				return 0;
			}
			var buffered = player.media.buffered;
			for (var i = 0; i < buffered.length; i++) {
				if (buffered.start(i) <= 0.1) {
					return buffered.end(i);
				}
			}
			return 0;
		},

		getVideoSize: function(id, rWidth, rHeight) {
			var player = LiveCodePlayer._players[id];
			var width = player ? player.media.videoWidth : 0;
			var height = player ? player.media.videoHeight : 0;
			{{{ makeSetValue('rWidth', '0', 'width', 'i32') }}};
			{{{ makeSetValue('rHeight', '0', 'height', 'i32') }}};
		},

		setLooping: function(id, looping) {
			var player = LiveCodePlayer._players[id];
			if (player) {
				player.media.loop = !!looping;
			}
		},

		setRate: function(id, rate) {
			var player = LiveCodePlayer._players[id];
			if (player && rate > 0) {
				try {
					player.media.playbackRate = rate;
				} catch (e) {
				}
			}
		},

		// A playLoudness of 0 mutes the movie, and a browser plays a muted
		// movie before the user has clicked in the page
		setVolume: function(id, volume) {
			var player = LiveCodePlayer._players[id];
			if (player) {
				player.media.volume = Math.max(0, Math.min(volume, 100)) / 100;
				player.media.muted = volume <= 0;
			}
		},

		// The browser's controls; without them, clicks go to the stack
		setControls: function(id, show) {
			var player = LiveCodePlayer._players[id];
			if (player) {
				player.media.controls = !!show;
				player.media.style.pointerEvents = show ? 'auto' : 'none';
			}
		},

		// The selection, in seconds (-1: none), and whether only it plays
		setSelection: function(id, start, end, only) {
			var player = LiveCodePlayer._players[id];
			if (player) {
				player.start = start;
				player.end = end;
				player.onlySelection = !!only && start >= 0 && end > start;
			}
		},

		// The times of the callbacks, in seconds
		setCallbacks: function(id, times, count) {
			var player = LiveCodePlayer._players[id];
			if (!player) {
				return;
			}
			player.callbacks = [];
			for (var i = 0; i < count; i++) {
				player.callbacks.push({{{ makeGetValue('times', 'i * 8', 'double') }}});
			}
			player.last = player.media.currentTime;
		},

		// While it plays, the callbacks whose times it passes, and the end
		// of the selection when only that plays, every frame
		_watch: function(player) {
			if (player.frame) {
				return;
			}
			player.last = player.media.currentTime;
			var tick = function() {
				player.frame = 0;
				if (LiveCodePlayer._players[player.id] !== player || player.media.paused) {
					return;
				}
				LiveCodePlayer._check(player);
				var now = performance.now();
				if (player.playing && now - player.told >= LiveCodePlayer._timeInterval) {
					player.told = now;
					LiveCodePlayer._notify(player, LiveCodePlayer.kTimeChanged);
				}
				player.frame = requestAnimationFrame(tick);
			};
			player.frame = requestAnimationFrame(tick);
		},

		_stopWatching: function(player) {
			if (player.frame) {
				cancelAnimationFrame(player.frame);
				player.frame = 0;
			}
			if (LiveCodePlayer._players[player.id] === player) {
				LiveCodePlayer._check(player);
			}
		},

		_check: function(player) {
			var media = player.media;
			var now = media.currentTime;
			var last = player.last;
			player.last = now;
			// Looping, the time went back to the start: the callbacks
			// after the last time, then those before the new one
			var passed = function(time) {
				return now >= last ? (time > last && time <= now) : (time > last || time <= now);
			};
			if (now != last) {
				for (var i = 0; i < player.callbacks.length; i++) {
					if (passed(player.callbacks[i])) {
						LiveCodePlayer._notify(player, LiveCodePlayer.kCallback + i);
					}
				}
			}
			if (player.onlySelection && player.playing && now >= player.end) {
				if (media.loop) {
					LiveCodePlayer.setTime(player.id, player.start);
				} else {
					player.playing = false;
					media.pause();
					LiveCodePlayer.setTime(player.id, player.end);
					LiveCodePlayer._notify(player, LiveCodePlayer.kEnded);
				}
			}
		},
	},

	MCEmscriptenPlayerCreate__deps: ['$LiveCodePlayer'],
	MCEmscriptenPlayerCreate: function(p_id) {
		return LiveCodePlayer.create(p_id);
	},

	MCEmscriptenPlayerDestroy__deps: ['$LiveCodePlayer'],
	MCEmscriptenPlayerDestroy: function(p_id) {
		LiveCodePlayer.destroy(p_id);
	},

	MCEmscriptenPlayerSetSource__deps: ['$LiveCodePlayer', '$LiveCodeUtil'],
	MCEmscriptenPlayerSetSource: function(p_id, p_path, p_length) {
		return LiveCodePlayer.setSource(p_id, LiveCodeUtil.stringFromUTF16(p_path, p_length));
	},

	MCEmscriptenPlayerGetState__deps: ['$LiveCodePlayer'],
	MCEmscriptenPlayerGetState: function(p_id) {
		return LiveCodePlayer.state(p_id);
	},

	MCEmscriptenPlayerPlay__deps: ['$LiveCodePlayer'],
	MCEmscriptenPlayerPlay: function(p_id) {
		LiveCodePlayer.play(p_id);
	},

	MCEmscriptenPlayerPause__deps: ['$LiveCodePlayer'],
	MCEmscriptenPlayerPause: function(p_id) {
		LiveCodePlayer.pause(p_id);
	},

	MCEmscriptenPlayerIsPaused__deps: ['$LiveCodePlayer'],
	MCEmscriptenPlayerIsPaused: function(p_id) {
		return LiveCodePlayer.isPaused(p_id);
	},

	MCEmscriptenPlayerGetTime__deps: ['$LiveCodePlayer'],
	MCEmscriptenPlayerGetTime: function(p_id) {
		return LiveCodePlayer.getTime(p_id);
	},

	MCEmscriptenPlayerSetTime__deps: ['$LiveCodePlayer'],
	MCEmscriptenPlayerSetTime: function(p_id, p_time) {
		LiveCodePlayer.setTime(p_id, p_time);
	},

	MCEmscriptenPlayerGetDuration__deps: ['$LiveCodePlayer'],
	MCEmscriptenPlayerGetDuration: function(p_id) {
		return LiveCodePlayer.getDuration(p_id);
	},

	MCEmscriptenPlayerGetLoaded__deps: ['$LiveCodePlayer'],
	MCEmscriptenPlayerGetLoaded: function(p_id) {
		return LiveCodePlayer.getLoaded(p_id);
	},

	MCEmscriptenPlayerGetVideoSize__deps: ['$LiveCodePlayer'],
	MCEmscriptenPlayerGetVideoSize: function(p_id, r_width, r_height) {
		LiveCodePlayer.getVideoSize(p_id, r_width, r_height);
	},

	MCEmscriptenPlayerSetLooping__deps: ['$LiveCodePlayer'],
	MCEmscriptenPlayerSetLooping: function(p_id, p_looping) {
		LiveCodePlayer.setLooping(p_id, p_looping);
	},

	MCEmscriptenPlayerSetRate__deps: ['$LiveCodePlayer'],
	MCEmscriptenPlayerSetRate: function(p_id, p_rate) {
		LiveCodePlayer.setRate(p_id, p_rate);
	},

	MCEmscriptenPlayerSetVolume__deps: ['$LiveCodePlayer'],
	MCEmscriptenPlayerSetVolume: function(p_id, p_volume) {
		LiveCodePlayer.setVolume(p_id, p_volume);
	},

	MCEmscriptenPlayerGetVolume__deps: ['$LiveCodePlayer'],
	MCEmscriptenPlayerGetVolume: function(p_id) {
		return LiveCodePlayer.getVolume(p_id);
	},

	MCEmscriptenPlayerSetControls__deps: ['$LiveCodePlayer'],
	MCEmscriptenPlayerSetControls: function(p_id, p_show) {
		LiveCodePlayer.setControls(p_id, p_show);
	},

	MCEmscriptenPlayerSetSelection__deps: ['$LiveCodePlayer'],
	MCEmscriptenPlayerSetSelection: function(p_id, p_start, p_end, p_only) {
		LiveCodePlayer.setSelection(p_id, p_start, p_end, p_only);
	},

	MCEmscriptenPlayerSetCallbacks__deps: ['$LiveCodePlayer'],
	MCEmscriptenPlayerSetCallbacks: function(p_id, p_times, p_count) {
		LiveCodePlayer.setCallbacks(p_id, p_times, p_count);
	},
});
