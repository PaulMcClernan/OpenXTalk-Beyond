/*                                                              -*-Javascript-*-
 
 Copyright (C) 2017 LiveCode Ltd.
 
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

mergeInto(LibraryManager.library, {
	$LiveCodeDC__deps: ['$LiveCodeEvents', '$LiveCodeUtil', '$LiveCodeAsync'],
	$LiveCodeDC: {
		// true if ensureInit() has ever been run
		_initialised: false,

		initialize: function() {
			// Make sure this only ever gets run once
			if (LiveCodeDC._initialised) {
				return;
			}
			
			LiveCodeDC._windowList = this.containerCreate(document.body, 1);
			LiveCodeDC._assignedMainWindow = false;

			LiveCodeDC._initialised = true;
		},

		finalize: function() {
			if (!LiveCodeDC._initialised) {
				return;
			}

			LiveCodeDC._initialised = false;
		},

		containerCreate: function(containerElement, maxZIndex) {
			return {'element':containerElement, 'maxZIndex':maxZIndex, 'contents':[]};
		},
		
		containerAddElement: function(container, element) {
			// OXT-Beyond: an element already in the container stays where
			// it is (the engine can attach a native layer twice, and moving
			// a frame in the page reloads it)
			if (container['contents'].indexOf(element) != -1) {
				return;
			}
			element.style.position = 'absolute';
			element.style.zIndex = container['maxZIndex'];
			container['maxZIndex']++;
			container['element'].appendChild(element);
			container['contents'].push(element);
		},
		
		containerRemoveElement: function(container, element) {
			// OXT-Beyond: an element that is not in the container stays out
			if (element.parentNode !== container['element']) {
				return;
			}
			this.containerRaiseElement(container, element);
			container['element'].removeChild(element);
			container['maxZIndex']--;
			var index = container['contents'].indexOf(element);
			if (index !== -1) {
				container['contents'].splice(index, 1);
			}
		},
		
		containerRaiseElement: function(container, element) {
			// OXT-Beyond: compared as numbers (style values are strings)
			var zIndex = Number(element.style.zIndex);
			for (var i = 0, l = container['contents'].length; i < l; i++)
			{
				var otherElement = container['contents'][i];
				if (Number(otherElement.style.zIndex) > zIndex)
				{
					otherElement.style.zIndex--;
				}
			}
			element.style.zIndex = container['maxZIndex'] - 1;
		},
		
		// Windows are backed by an html canvas within a floating div
		createWindow: function() {
			var windowElement;
			var canvas;
			var rect;
			var mainWindow = false;
			if (!LiveCodeDC._assignedMainWindow)
			{
				mainWindow = true;
				canvas = Module['canvas'];
				rect = canvas.getBoundingClientRect();
				LiveCodeDC._assignedMainWindow = true;
				windowElement = canvas.parentElement;
				windowElement.style.setProperty('position', 'relative');
				windowElement.style.setProperty('width', rect['right'] - rect['left']);
				windowElement.style.setProperty('height', rect['bottom'] - rect['top']);
				canvas.style.setProperty('position', 'absolute');
				canvas.style.setProperty('left', '0px');
				canvas.style.setProperty('right', '0px');
				canvas.style.setProperty('width', '100%');
				canvas.style.setProperty('height', '100%');
			}
			else
			{
				windowElement = document.createElement('div');
				windowElement.style.display = 'none';
				windowElement.style.position = 'fixed';
				canvas = document.createElement('canvas');
				canvas.style.setProperty('position', 'absolute');
				canvas.style.setProperty('left', '0px');
				canvas.style.setProperty('right', '0px');
				canvas.style.setProperty('width', '100%');
				canvas.style.setProperty('height', '100%');
				windowElement.appendChild(canvas);
				this.containerAddElement(this._windowList, windowElement);
		  
				rect = {'left':0, 'top':0, 'right':0, 'bottom':0};
			}
			
			var tWindowID = LiveCodeUtil.storeObject({
				'mainWindow': mainWindow,
				'element': windowElement,
				'canvas': canvas,
				'container': this.containerCreate(windowElement, 1),
				'rect': rect,
				'visible':false,
			});
			
			canvas.dataset.lcWindowId = tWindowID;
			LiveCodeEvents.addEventListeners(canvas);
			LiveCodeDC._monitorResize(canvas, function() {
				LiveCodeEvents.postWindowReshape(tWindowID);
			});
			
			return tWindowID;
		},
		
		destroyWindow: function(pID) {
			var window = LiveCodeUtil.fetchObject(pID);
			if (window)
			{
				LiveCodeDC._removeResizeMonitor(window.canvas);
				LiveCodeDC.setWindowVisible(pID, false);
				
				if (window.mainWindow)
				{
					// TODO - handle cleanup of embedded canvas
					LiveCodeDC._assignedMainWindow = false;
				}
				else
				{
					this.containerRemoveElement(this._windowList, window.element);
				}
				LiveCodeUtil.releaseObject(pID);
			}
		},
		
		raiseWindow: function(pID) {
			var window = LiveCodeUtil.fetchObject(pID);
			if (window && !window.mainWindow)
			{
				this.containerRaiseElement(this._windowList, window.element);
			}
		},
		
		setWindowRect: function(pID, pLeft, pTop, pRight, pBottom) {
			var window = LiveCodeUtil.fetchObject(pID);
			if (window)
			{
				var width = pRight - pLeft;
				var height = pBottom - pTop;
				window.rect = {'left':pLeft, 'top':pTop, 'right':pRight, 'bottom':pBottom};
				if (!window.mainWindow)
				{
					window.element.style.setProperty('left', pLeft + 'px', 'important');
					window.element.style.setProperty('top', pTop + 'px', 'important');
				}
				window.element.style.setProperty('width', width + 'px', 'important');
				window.element.style.setProperty('height', height + 'px', 'important');
			}
		},
		
		getWindowRect: function(pID) {
			var window = LiveCodeUtil.fetchObject(pID);
			if (window)
				return window.canvas.getBoundingClientRect();
		  
			return null;
		},
		
		setWindowVisible: function(pID, pVisible) {
			var window = LiveCodeUtil.fetchObject(pID);
			if (window)
			{
				window.visible = pVisible;
				if (!window.mainWindow)
				{
					if (pVisible)
						window.element.style.display = 'block';
					else
						window.element.style.display = 'none';
				}
				else
				{
					if (pVisible)
						window.element.style.visibility = 'visible';
					else
						window.element.style.visibility = 'hidden';
				}
			}
		},
		
		getWindowVisible: function(pID) {
			var window = LiveCodeUtil.fetchObject(pID);
			if (window)
			{
				return window.visible;
			}
			
			return false;
		},
		
		getWindowCanvas: function(pID) {
			var window = LiveCodeUtil.fetchObject(pID);
			if (window)
			{
				return window.canvas;
			}
			
			return null;
		},
		
		getWindowIDForCanvas: function(pCanvas) {
			if (pCanvas && pCanvas.dataset && pCanvas.dataset.lcWindowId)
				return Number(pCanvas.dataset.lcWindowId);
			return 0;
		},
		
		// The screen is the browser's viewport: the part of the page that
		// it shows, without its scrollbars
		getDisplayRect: function() {
			var root = document.documentElement;
			return {'left':0, 'top':0,
					'right':root.clientWidth || window.innerWidth,
					'bottom':root.clientHeight || window.innerHeight};
		},

		/*** Cursors ***/

		// The CSS cursor of each cursor, by id: a standard cursor's name,
		// or an image's url()
		_cursors: {},
		_nextCursor: 1,

		// The CSS cursors of the engine's standard cursors, in the order of
		// enum Pixmap_ids (parsedef.h): none, arrow, brush, spray, eraser,
		// bucket, busy, cross, hand, ibeam, lr, pencil, dropper, plus,
		// watch, help, busy1 to busy8, dragtext, dragclone, dragrefuse,
		// sizev, sizeh. The last is a hand: the constant hand is 28
		// (lextable.cpp), which is sizeh's place, and the cursor image 28
		// that the desktop shows there is a hand.
		_standardCursors: ['none', 'default', 'crosshair', 'crosshair', 'crosshair', 'crosshair',
			'wait', 'crosshair', 'pointer', 'text', 'ew-resize', 'crosshair', 'crosshair',
			'cell', 'wait', 'help', 'wait', 'wait', 'wait', 'wait', 'wait', 'wait', 'wait', 'wait',
			'grabbing', 'copy', 'no-drop', 'ns-resize', 'pointer'],

		createStandardCursor: function(index) {
			var id = LiveCodeDC._nextCursor++;
			LiveCodeDC._cursors[id] = LiveCodeDC._standardCursors[index] || 'default';
			return id;
		},

		// A cursor from an image: <pixels> is premultiplied RGBA, <stride>
		// bytes a row
		createCustomCursor: function(pixels, width, height, stride, xhot, yhot) {
			var canvas = LiveCodeDC.canvasFromPixels(pixels, width, height, stride);
			if (!canvas) {
				return LiveCodeDC.createStandardCursor(1);
			}
			var id = LiveCodeDC._nextCursor++;
			LiveCodeDC._cursors[id] = 'url("' + canvas.toDataURL('image/png') + '") ' +
				Math.max(0, Math.min(xhot, width - 1)) + ' ' +
				Math.max(0, Math.min(yhot, height - 1)) + ', auto';
			return id;
		},

		// A canvas that shows an image (a cursor's, or a drag's): <pixels>
		// is premultiplied RGBA, <stride> bytes a row. Null if there is no
		// image.
		canvasFromPixels: function(pixels, width, height, stride) {
			var canvas = document.createElement('canvas');
			canvas.width = width;
			canvas.height = height;
			var context = canvas.getContext('2d');
			if (!context || width == 0 || height == 0) {
				return null;
			}
			var image = context.createImageData(width, height);
			var data = image.data;
			for (var y = 0; y < height; y++) {
				for (var x = 0; x < width; x++) {
					var from = pixels + y * stride + x * 4;
					var to = (y * width + x) * 4;
					var alpha = HEAPU8[from + 3];
					if (alpha == 0) {
						continue;
					}
					data[to] = Math.min(255, Math.round(HEAPU8[from] * 255 / alpha));
					data[to + 1] = Math.min(255, Math.round(HEAPU8[from + 1] * 255 / alpha));
					data[to + 2] = Math.min(255, Math.round(HEAPU8[from + 2] * 255 / alpha));
					data[to + 3] = alpha;
				}
			}
			context.putImageData(image, 0, 0);
			return canvas;
		},

		freeCursor: function(id) {
			delete LiveCodeDC._cursors[id];
		},

		setWindowCursor: function(pID, id) {
			var canvas = LiveCodeDC.getWindowCanvas(pID);
			if (canvas) {
				canvas.style.cursor = LiveCodeDC._cursors[id] || 'default';
			}
		},

		/*** Native Layer API ***/
		nativeElementSetRect: function(pElementID, pLeft, pTop, pRight, pBottom) {
			var tElement = LiveCodeUtil.fetchObject(pElementID);
			if (tElement)
			{
				tElement.style.setProperty('left', pLeft + 'px', 'important');
				tElement.style.setProperty('top', pTop + 'px', 'important');
				tElement.style.setProperty('width', pRight - pLeft + 'px', 'important');
				tElement.style.setProperty('height', pBottom - pTop + 'px', 'important');
			}
		},
		
		nativeElementSetClip: function(pElementID, pLeft, pTop, pRight, pBottom) {
			var tElement = LiveCodeUtil.fetchObject(pElementID);
			if (tElement)
			{
				tElement.style.setProperty('clip', 'rect(' + pTop + 'px,' + pRight + 'px,' + pBottom + 'px,' + pLeft + 'px)', 'important');
			}
		},
		
		nativeElementSetVisible: function(pElementID, pVisible) {
			var tElement = LiveCodeUtil.fetchObject(pElementID);
			if (tElement)
			{
				if (pVisible)
					tElement.style.display = 'block';
				else
					tElement.style.display = 'none';
			}
		},
		
		nativeElementAddToWindow: function(pElementID, pWindowID) {
			var tWindow = LiveCodeUtil.fetchObject(pWindowID);
			var tElement = LiveCodeUtil.fetchObject(pElementID);
			if (tWindow && tElement)
			{
				this.containerAddElement(tWindow.container, tElement);
				// OXT-Beyond: a drag over the element is over its window
				// (LiveCodeEvents.dragTarget())
				tElement.dataset.lcLayerWindowId = pWindowID;
			}
		},

		nativeElementRemoveFromWindow: function(pElementID, pWindowID) {
			var tWindow = LiveCodeUtil.fetchObject(pWindowID);
			var tElement = LiveCodeUtil.fetchObject(pElementID);
			if (tWindow && tElement)
			{
				this.containerRemoveElement(tWindow.container, tElement);
				delete tElement.dataset.lcLayerWindowId;
			}
		},
		
		nativeElementPlaceAbove: function(pElementID, pAboveElementID, pWindowID) {
			var tWindow = LiveCodeUtil.fetchObject(pWindowID);
			var tElement = LiveCodeUtil.fetchObject(pElementID);
			var tAboveElement = pAboveElementID ? LiveCodeUtil.fetchObject(pAboveElementID) : null;
			// OXT-Beyond: put the element just above the given one (or at the
			// bottom when there is none) by renumbering the stacking order of
			// the window's elements. The elements stay where they are in the
			// page, because moving a frame in the page reloads it.
			if (!tWindow || !tElement)
			{
				return;
			}
			var tContents = tWindow.container['contents'];
			if (tContents.indexOf(tElement) == -1)
			{
				return;
			}
			var tOrdered = tContents.slice().sort(function(a, b) {
				return Number(a.style.zIndex) - Number(b.style.zIndex);
			});
			tOrdered.splice(tOrdered.indexOf(tElement), 1);
			var tIndex = tAboveElement ? tOrdered.indexOf(tAboveElement) + 1 : 0;
			tOrdered.splice(tIndex, 0, tElement);
			for (var i = 0; i < tOrdered.length; i++)
			{
				tOrdered[i].style.zIndex = i + 1;
			}
		},
		
		_monitorResize: function(element, callback) {
			// initial setup on first call
			if (!LiveCodeDC._monitorResize.watched) {
				LiveCodeDC._monitorResize.watched = [];
		  
				var resizeCheck = function() {
					LiveCodeDC._monitorResize.watched.forEach(function(data) {
						var rect = data.element.getBoundingClientRect();
						if (rect.left != data.rect.left || rect.top != data.rect.top || rect.right != data.rect.right || rect.bottom != data.rect.bottom) {
							data.rect = rect;
							data.callback();
						}
					});
				};

				// Listen to the window's size changes
				window.addEventListener('resize', resizeCheck);
		  
				// Listen to changes on the elements in the page that affect layout
				var observer = new MutationObserver(resizeCheck);
				observer.observe(document.body, {
					attributes: true,
					childList: true,
					characterData: true,
					subtree: true
				});
			}
			
			LiveCodeDC._monitorResize.watched.push({'element':element, 'callback':callback, 'rect':element.getBoundingClientRect()});
		},
		
		_removeResizeMonitor: function(element) {
			if (LiveCodeDC._monitorResize.watched) {
				var index = 0;
				while (index < LiveCodeDC._monitorResize.watched.length)
				{
					if (LiveCodeDC._monitorResize.watched[index].element === element)
						LiveCodeDC._monitorResize.watched.splice(index, 1);
					else
						index++;
				}
			}
		},

		/*** Snapshots of the screen ***/

		// OXT-Beyond: what the screen (the browser's viewport) shows in
		// the rectangle <left>, <top>, <width>, <height>, drawn at
		// <outWidth> x <outHeight> into <pixels> (RGBA, 4 bytes a pixel,
		// all opaque): the stacks' windows, from the back, over the page's
		// background colour. What a page cannot draw into a canvas (the
		// rest of the page, the browser widget's frames and the players'
		// movies) is that colour. False if the browser cannot draw it.
		snapshot: function(left, top, width, height, outWidth, outHeight, pixels) {
			var out = document.createElement('canvas');
			out.width = outWidth;
			out.height = outHeight;
			var context = out.getContext('2d');
			if (!context || width <= 0 || height <= 0) {
				return false;
			}

			var background = '#ffffff';
			[document.body, document.documentElement].some(function(element) {
				var colour = element ? getComputedStyle(element).backgroundColor : '';
				if (colour && colour != 'transparent' && !/^rgba\(.*,\s*0\)$/.test(colour)) {
					background = colour;
					return true;
				}
				return false;
			});
			context.fillStyle = background;
			context.fillRect(0, 0, outWidth, outHeight);

			// The main stack's window is under the others, which are in
			// the order of their z-index
			var canvases = [];
			if (LiveCodeDC._assignedMainWindow && Module['canvas']) {
				canvases.push(Module['canvas']);
			}
			LiveCodeDC._windowList['contents'].slice().sort(function(a, b) {
				return Number(a.style.zIndex) - Number(b.style.zIndex);
			}).forEach(function(element) {
				var canvas = element.querySelector('canvas');
				if (canvas) {
					canvases.push(canvas);
				}
			});

			var scaleX = outWidth / width;
			var scaleY = outHeight / height;
			canvases.forEach(function(canvas) {
				var window = LiveCodeUtil.fetchObject(LiveCodeDC.getWindowIDForCanvas(canvas));
				var rect = canvas.getBoundingClientRect();
				if (!window || !window.visible || canvas.width == 0 || canvas.height == 0 ||
					rect.width == 0 || rect.height == 0) {
					return;
				}
				context.drawImage(canvas, 0, 0, canvas.width, canvas.height,
								  (rect.left - left) * scaleX, (rect.top - top) * scaleY,
								  rect.width * scaleX, rect.height * scaleY);
			});

			var data = context.getImageData(0, 0, outWidth, outHeight).data;
			HEAPU8.set(data, pixels);
			return true;
		},

		// OXT-Beyond: the rectangle that the user is dragging out for a
		// snapshot (import snapshot with no rect): null when there is none,
		// else its state, 'pending' until the button goes up ('done') or
		// Escape cancels it ('cancelled')
		_snapshotSelection: null,

		// The user drags out a rectangle on the page, as on the desktop:
		// the cursor is a crosshair over the whole page, which takes no
		// other mouse events meanwhile
		snapshotSelectBegin: function() {
			var overlay = document.createElement('div');
			overlay.className = 'oxt-snapshot-select';
			overlay.style.cssText = 'position: fixed; left: 0; top: 0; right: 0; bottom: 0; ' +
				'z-index: 2147483647; cursor: crosshair; touch-action: none;';
			var box = document.createElement('div');
			box.style.cssText = 'position: fixed; display: none; pointer-events: none; ' +
				'border: 1px dashed #000000; outline: 1px dashed #ffffff;';
			overlay.appendChild(box);
			document.body.appendChild(overlay);

			var selection = {'state': 'pending', 'rect': [0, 0, 0, 0]};
			LiveCodeDC._snapshotSelection = selection;
			var start = null;

			var place = function(e) {
				var x = Math.round(e.clientX), y = Math.round(e.clientY);
				var rect = [Math.min(start[0], x), Math.min(start[1], y),
							Math.max(start[0], x), Math.max(start[1], y)];
				selection.rect = rect;
				box.style.display = 'block';
				box.style.left = rect[0] + 'px';
				box.style.top = rect[1] + 'px';
				box.style.width = (rect[2] - rect[0]) + 'px';
				box.style.height = (rect[3] - rect[1]) + 'px';
			};
			var finish = function(state) {
				if (selection.state != 'pending') {
					return;
				}
				selection.state = state;
				document.removeEventListener('keydown', key, true);
				if (overlay.parentNode) {
					overlay.parentNode.removeChild(overlay);
				}

				// A click, not a drag, takes the stack's window under it,
				// or else the whole screen, as on Linux
				var rect = selection.rect;
				if (state == 'done' && rect[2] - rect[0] < 4 && rect[3] - rect[1] < 4) {
					var under = document.elementFromPoint(rect[0], rect[1]);
					var bounds = under && LiveCodeDC.getWindowIDForCanvas(under) != 0 ?
						under.getBoundingClientRect() : null;
					var display = LiveCodeDC.getDisplayRect();
					selection.rect = bounds ?
						[Math.round(bounds.left), Math.round(bounds.top),
						 Math.round(bounds.right), Math.round(bounds.bottom)] :
						[display.left, display.top, display.right, display.bottom];
				}
				LiveCodeAsync.resume();
			};
			selection.cancel = function() {
				finish('cancelled');
			};
			var key = function(e) {
				if (e.key == 'Escape') {
					finish('cancelled');
				}
				e.preventDefault();
				e.stopPropagation();
			};

			overlay.addEventListener('pointerdown', function(e) {
				start = [Math.round(e.clientX), Math.round(e.clientY)];
				overlay.setPointerCapture(e.pointerId);
				place(e);
				e.preventDefault();
			});
			overlay.addEventListener('pointermove', function(e) {
				if (start) {
					place(e);
				}
				e.preventDefault();
			});
			overlay.addEventListener('pointerup', function(e) {
				if (start) {
					place(e);
					finish('done');
				}
				e.preventDefault();
			});
			overlay.addEventListener('pointercancel', function() {
				finish('cancelled');
			});
			document.addEventListener('keydown', key, true);
		},

		// The selection's state: 0 while the user drags, 1 when it is done
		// (its rect is in <r>: left, top, right, bottom), 2 when it was
		// cancelled, as it is first if <cancel>. The selection is over once
		// it is not 0.
		snapshotSelectState: function(r, cancel) {
			var selection = LiveCodeDC._snapshotSelection;
			if (!selection) {
				return 2;
			}
			if (cancel) {
				selection.cancel();
			}
			if (selection.state == 'pending') {
				return 0;
			}
			LiveCodeDC._snapshotSelection = null;
			for (var i = 0; i < 4; i++) {
				HEAP32[(r >> 2) + i] = selection.rect[i];
			}
			return selection.state == 'done' ? 1 : 2;
		},
	},
	
	// OXT-Beyond: snapshots of the screen (MCScreenDC::snapshot(),
	// em-dc.cpp)
	MCEmscriptenSnapshot__deps: ['$LiveCodeDC'],
	MCEmscriptenSnapshot: function(pLeft, pTop, pWidth, pHeight, pOutWidth, pOutHeight, pPixels) {
		return LiveCodeDC.snapshot(pLeft, pTop, pWidth, pHeight, pOutWidth, pOutHeight, pPixels);
	},

	MCEmscriptenSnapshotSelectBegin__deps: ['$LiveCodeDC'],
	MCEmscriptenSnapshotSelectBegin: function() {
		LiveCodeDC.snapshotSelectBegin();
	},

	MCEmscriptenSnapshotSelectState__deps: ['$LiveCodeDC'],
	MCEmscriptenSnapshotSelectState: function(rRect, pCancel) {
		return LiveCodeDC.snapshotSelectState(rRect, pCancel);
	},

	MCEmscriptenDCInitializeJS__deps: ['$LiveCodeDC'],
	MCEmscriptenDCInitializeJS: function() {
		LiveCodeDC.initialize();
		return true;
	},

	MCEmscriptenDCFinalizeJS__deps: ['$LiveCodeDC'],
	MCEmscriptenDCFinalizeJS: function() {
		LiveCodeDC.finalize();
	},

	MCEmscriptenCreateWindow__deps: ['$LiveCodeDC'],
	MCEmscriptenCreateWindow: function() {
		return LiveCodeDC.createWindow();
	},
	
	MCEmscriptenDestroyWindow__deps: ['$LiveCodeDC'],
	MCEmscriptenDestroyWindow: function(pWindowID) {
		LiveCodeDC.destroyWindow(pWindowID);
	},
	
	MCEmscriptenRaiseWindow__deps: ['$LiveCodeDC'],
	MCEmscriptenRaiseWindow: function(pWindowID) {
		LiveCodeDC.raiseWindow(pWindowID);
	},
	
	MCEmscriptenSetWindowRect__deps: ['$LiveCodeDC'],
	MCEmscriptenSetWindowRect: function(pWindowID, pLeft, pTop, pRight, pBottom) {
		LiveCodeDC.setWindowRect(pWindowID, pLeft, pTop, pRight, pBottom);
	},

	MCEmscriptenGetWindowRect__deps: ['$LiveCodeDC'],
	MCEmscriptenGetWindowRect: function(pWindowID, rLeft, rTop, rRight, rBottom) {
		var rect = LiveCodeDC.getWindowRect(pWindowID);
		{{{ makeSetValue('rLeft', '0', 'rect.left', 'i32') }}};
		{{{ makeSetValue('rTop', '0', 'rect.top', 'i32') }}};
		{{{ makeSetValue('rRight', '0', 'rect.right', 'i32') }}};
		{{{ makeSetValue('rBottom', '0', 'rect.bottom', 'i32') }}};
	},
	
	MCEmscriptenSetWindowVisible__deps: ['$LiveCodeDC'],
	MCEmscriptenSetWindowVisible: function(pWindowID, pVisible) {
		LiveCodeDC.setWindowVisible(pWindowID, pVisible);
	},
	
	MCEmscriptenGetWindowVisible__deps: ['$LiveCodeDC'],
	MCEmscriptenGetWindowVisible: function(pWindowID) {
		return LiveCodeDC.getWindowVisible(pWindowID);
	},
	
	MCEmscriptenGetDisplayRect__deps: ['$LiveCodeDC'],
	MCEmscriptenGetDisplayRect: function(rLeft, rTop, rRight, rBottom) {
		var rect = LiveCodeDC.getDisplayRect();
		{{{ makeSetValue('rLeft', '0', 'rect.left', 'i32') }}};
		{{{ makeSetValue('rTop', '0', 'rect.top', 'i32') }}};
		{{{ makeSetValue('rRight', '0', 'rect.right', 'i32') }}};
		{{{ makeSetValue('rBottom', '0', 'rect.bottom', 'i32') }}};
	},
	
	MCEmscriptenSyncCanvasSize__deps: ['$LiveCodeDC'],
	MCEmscriptenSyncCanvasSize: function(p_window_id, p_width, p_height)
	{
		var canvas = LiveCodeDC.getWindowCanvas(p_window_id);
		if (!canvas)
			return;
		
		if (canvas.width != p_width || canvas.height != p_height)
		{
			canvas.width = p_width;
			canvas.height = p_height;
		}
	},
	MCEmscriptenElementSetRect__deps: ['$LiveCodeDC'],
	MCEmscriptenElementSetRect: function(p_element, p_left, p_top, p_right, p_bottom) {
		LiveCodeDC.nativeElementSetRect(p_element, p_left, p_top, p_right, p_bottom);
	},
	MCEmscriptenElementSetClip__deps: ['$LiveCodeDC'],
	MCEmscriptenElementSetClip: function(p_element, p_left, p_top, p_right, p_bottom) {
		LiveCodeDC.nativeElementSetClip(p_element, p_left, p_top, p_right, p_bottom);
	},
	MCEmscriptenElementSetVisible__deps: ['$LiveCodeDC'],
	MCEmscriptenElementSetVisible: function(p_element, p_visible) {
		LiveCodeDC.nativeElementSetVisible(p_element, p_visible);
	},
	MCEmscriptenElementAddToWindow__deps: ['$LiveCodeDC'],
	MCEmscriptenElementAddToWindow: function(p_element, p_container) {
		LiveCodeDC.nativeElementAddToWindow(p_element, p_container);
	},
	MCEmscriptenElementRemoveFromWindow__deps: ['$LiveCodeDC'],
	MCEmscriptenElementRemoveFromWindow: function(p_element, p_container) {
		LiveCodeDC.nativeElementRemoveFromWindow(p_element, p_container);
	},
	MCEmscriptenElementPlaceAbove__deps: ['$LiveCodeDC'],
	MCEmscriptenElementPlaceAbove: function(p_element, p_above, p_container) {
		LiveCodeDC.nativeElementPlaceAbove(p_element, p_above, p_container);
	},

	MCEmscriptenCreateStandardCursor__deps: ['$LiveCodeDC'],
	MCEmscriptenCreateStandardCursor: function(p_index) {
		return LiveCodeDC.createStandardCursor(p_index);
	},

	MCEmscriptenCreateCustomCursor__deps: ['$LiveCodeDC'],
	MCEmscriptenCreateCustomCursor: function(p_pixels, p_width, p_height, p_stride, p_xhot, p_yhot) {
		return LiveCodeDC.createCustomCursor(p_pixels, p_width, p_height, p_stride, p_xhot, p_yhot);
	},

	MCEmscriptenFreeCursor__deps: ['$LiveCodeDC'],
	MCEmscriptenFreeCursor: function(p_cursor) {
		LiveCodeDC.freeCursor(p_cursor);
	},

	MCEmscriptenSetWindowCursor__deps: ['$LiveCodeDC'],
	MCEmscriptenSetWindowCursor: function(p_window_id, p_cursor) {
		LiveCodeDC.setWindowCursor(p_window_id, p_cursor);
	},

});
