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

// The browser's clipboard and the engine's (em-clipboard.cpp).
//
// What the engine copies goes to the browser's clipboard: in the copy
// or cut event that follows the key that copied it (Ctrl+C, or Cmd+C on
// a Mac), which needs no permission, and else with the asynchronous
// Clipboard API, which browsers allow in a secure page (https) while
// they answer a click or a key.
//
// A page cannot read the browser's clipboard when it likes, so what the
// user pastes (Ctrl+V, Cmd+V or the browser's Paste) is put on the
// engine's clipboard in the paste event, before the engine gets the key
// (em-event.js holds the key back until then).

mergeInto(LibraryManager.library, {

	$LiveCodeClipboard__deps: ['$LiveCodeAsync', 'malloc', 'free'],
	$LiveCodeClipboard: {

		// The engine's clipboard types (enum MCRawClipboardKnownType)
		kUTF8: 0,
		kHTML: 6,
		kPNG: 7,
		kGIF: 8,
		kJPEG: 9,

		// What the engine last copied: {'text', 'html', 'png'}, each null
		// if it has none
		_copied: null,

		// True from a copy by the engine to the copy or cut event of the
		// key that copied
		_pending: false,

		// The engine copied (em-clipboard.cpp)
		set: function(text, html, png) {
			LiveCodeClipboard._copied = {'text': text, 'html': html, 'png': png};
			LiveCodeClipboard._pending = true;

			// And with the asynchronous API, for a copy with no copy event
			// (the copy command in a mouseUp handler, ...)
			LiveCodeClipboard._write(text, html, png);
		},

		_write: function(text, html, png) {
			var clipboard = navigator.clipboard;
			if (!clipboard || !window.isSecureContext) {
				return;
			}
			try {
				var promise = null;
				if (typeof ClipboardItem != 'undefined' && clipboard.write &&
					(html !== null || png !== null)) {
					var items = {};
					if (text !== null) {
						items['text/plain'] = new Blob([text], {'type': 'text/plain'});
					}
					if (html !== null) {
						items['text/html'] = new Blob([html], {'type': 'text/html'});
					}
					if (png !== null) {
						items['image/png'] = new Blob([png], {'type': 'image/png'});
					}
					promise = clipboard.write([new ClipboardItem(items)]);
				} else if (text !== null && clipboard.writeText) {
					promise = clipboard.writeText(text);
				}
				if (promise) {
					// Refused without a click or a key, or without focus:
					// the copy event (if any) has done it
					promise['catch'](function() {});
				}
			} catch (e) {
			}
		},

		// A key that may copy is going to the engine: a copy event after
		// it takes only what the engine copies in answer to it
		beginKey: function() {
			LiveCodeClipboard._pending = false;
		},

		// The copy and cut events of the field that has the keyboard
		handleCopy: function(e) {
			var copied = LiveCodeClipboard._copied;
			if (!LiveCodeClipboard._pending || !copied || !e.clipboardData) {
				return;
			}
			LiveCodeClipboard._pending = false;
			if (copied.text === null && copied.html === null) {
				return;
			}
			if (copied.text !== null) {
				e.clipboardData.setData('text/plain', copied.text);
			}
			if (copied.html !== null) {
				e.clipboardData.setData('text/html', copied.html);
			}
			e.preventDefault();
		},

		// The paste event of the field that has the keyboard: puts what
		// is pasted on the engine's clipboard, then calls deliver(), which
		// gives the engine the key that pastes
		handlePaste: function(e, deliver) {
			var data = e.clipboardData;
			if (!data) {
				deliver();
				return;
			}
			e.preventDefault();

			var text = data.getData('text/plain');
			var html = data.getData('text/html');
			var image = null;
			var imageType = 0;
			var types = {'image/png': LiveCodeClipboard.kPNG,
						 'image/gif': LiveCodeClipboard.kGIF,
						 'image/jpeg': LiveCodeClipboard.kJPEG};
			var items = data.items || [];
			for (var i = 0; i < items.length; i++) {
				if (items[i].kind == 'file' && types[items[i].type] !== undefined) {
					image = items[i].getAsFile();
					imageType = types[items[i].type];
					break;
				}
			}

			// What the engine copied, coming back: the engine's own data
			// (styled text, objects) is better than the browser's
			var copied = LiveCodeClipboard._copied;
			if (copied && copied.text !== null && text === copied.text && image === null) {
				deliver();
				return;
			}
			if (text === '' && html === '' && image === null) {
				deliver();
				return;
			}

			var store = function(bytes) {
				LiveCodeAsync.delay(function() {
					Module.ccall('MCEmscriptenClipboardBeginExternal', null, [], []);
					var encoder = new TextEncoder();
					if (text !== '') {
						LiveCodeClipboard._add(LiveCodeClipboard.kUTF8, encoder.encode(text));
					}
					if (html !== '') {
						LiveCodeClipboard._add(LiveCodeClipboard.kHTML, encoder.encode(html));
					}
					if (bytes !== null) {
						LiveCodeClipboard._add(imageType, bytes);
					}
				});
				LiveCodeClipboard._copied = null;
				deliver();
			};
			if (image !== null && image.arrayBuffer) {
				image.arrayBuffer().then(function(buffer) {
					store(new Uint8Array(buffer));
				}, function() {
					store(null);
				});
			} else {
				store(null);
			}
		},

		_add: function(type, bytes) {
			var buffer = _malloc(Math.max(bytes.length, 1));
			HEAPU8.set(bytes, buffer);
			Module.ccall('MCEmscriptenClipboardAddExternal', 'number',
						 ['number', 'number', 'number'],
						 [type, buffer, bytes.length]);
			_free(buffer);
		},
	},

	// Gives the browser's clipboard what the engine copied: UTF-8 text,
	// UTF-8 HTML and a PNG image (each null if absent)
	MCEmscriptenClipboardSetSystem__deps: ['$LiveCodeClipboard'],
	MCEmscriptenClipboardSetSystem: function(text, text_length, html, html_length, png, png_length) {
		var decoder = new TextDecoder('utf-8');
		LiveCodeClipboard.set(text ? decoder.decode(HEAPU8.slice(text, text + text_length)) : null,
							  html ? decoder.decode(HEAPU8.slice(html, html + html_length)) : null,
							  png ? HEAPU8.slice(png, png + png_length) : null);
	},
});

/*
 * Local Variables:
 * tab-width: 4
 * indent-tabs-mode: t
 * End:
 */
