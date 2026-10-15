/*                                                              -*-Javascript-*-

 Copyright (C) 2026 OXT-Beyond contributors.

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

// Printing in a web standalone (em-printer.cpp).
//
// The engine draws each page that a stack prints as a picture, which
// addPage() copies into a canvas, and the browser makes the canvas into a
// PNG file meanwhile. When printing closes, end() puts the pictures into a
// frame of the page, out of sight, each on a page of the paper's size (a
// CSS page size, with no margins), and prints the frame: the browser's
// print dialog opens, where the user prints the pages or saves them as a
// PDF. The engine waits until the frame has printed, or could not.

mergeInto(LibraryManager.library, {

	$LiveCodePrinter__deps: ['$LiveCodeAsync'],
	$LiveCodePrinter: {
		// The jobs, by id: {title, pages, printing, failed, released,
		// forgotten, frame}. A page is {url, widthPt, heightPt, made}: made
		// is a promise of its PNG file, whose object URL is url.
		_jobs: {},
		_nextId: 1,

		// The frames that print the jobs' pages: {element, urls, printed}
		_frames: [],

		// How long the frame has to load and decode its pictures
		kFrameTimeout: 60000,

		// The regions whose paper is US Letter (the Unicode CLDR's paper
		// sizes); every other region's is A4
		_letterRegions: ['BZ', 'CA', 'CL', 'CO', 'CR', 'GT', 'MX', 'NI', 'PA', 'PH', 'PR', 'SV', 'US', 'VE'],

		// Whether the browser's language is of a region whose paper is US
		// Letter: "en-US" and "es-MX" are, and so is "en" (whose likely
		// region is the US), and "en-GB" and "fr" are not
		usesLetter: function() {
			var region;
			try {
				var locale = new Intl.Locale(navigator.language || 'en-US');
				region = locale.region || locale.maximize().region;
			} catch (error) {
				return true;
			}
			return !region || LiveCodePrinter._letterRegions.indexOf(region.toUpperCase()) >= 0;
		},

		begin: function(title) {
			var id = LiveCodePrinter._nextId++;
			LiveCodePrinter._jobs[id] = {
				title: title,
				pages: [],
				printing: false,
				failed: false,
				released: false,
				forgotten: false,
				frame: null,
			};
			return id;
		},

		// Copies the picture of a page (RGBA, opaque) into a canvas; the
		// browser makes its PNG file while the engine goes on
		addPage: function(id, rgba, width, height, widthPt, heightPt) {
			var job = LiveCodePrinter._jobs[id];
			if (!job) {
				return false;
			}
			var canvas = document.createElement('canvas');
			canvas.width = width;
			canvas.height = height;
			var context = canvas.getContext('2d');
			if (!context) {
				return false;
			}
			var pixels = new Uint8ClampedArray(HEAPU8.buffer, rgba, width * height * 4);
			context.putImageData(new ImageData(pixels, width, height), 0, 0);

			var page = {url: null, widthPt: widthPt, heightPt: heightPt};
			page.made = new Promise(function(resolve) {
				canvas.toBlob(function(blob) {
					if (blob && !job.forgotten) {
						page.url = URL.createObjectURL(blob);
					}
					// The canvas has done its work
					canvas.width = 0;
					canvas.height = 0;
					resolve();
				}, 'image/png');
			});
			job.pages.push(page);
			return true;
		},

		// Prints the job's pages once they are made: the engine waits
		// until it has (isPrinting()). A job with no pages prints nothing.
		end: function(id) {
			var job = LiveCodePrinter._jobs[id];
			if (!job || job.pages.length == 0) {
				return;
			}
			job.printing = true;
			Promise.all(job.pages.map(function(page) {
				return page.made;
			})).then(function() {
				return LiveCodePrinter._print(job);
			}).catch(function(error) {
				job.failed = true;
				if (job.frame) {
					LiveCodePrinter._removeFrame(job.frame);
				}
			}).then(function() {
				job.printing = false;
				if (job.released) {
					LiveCodePrinter._forget(id);
				}
				LiveCodeAsync.resume();
			});
		},

		isPrinting: function(id) {
			var job = LiveCodePrinter._jobs[id];
			return !!(job && job.printing);
		},

		failed: function(id) {
			var job = LiveCodePrinter._jobs[id];
			return !!(job && job.failed);
		},

		// The engine is done with the job (or cancelled it): it goes, once
		// it has printed
		release: function(id) {
			var job = LiveCodePrinter._jobs[id];
			if (!job) {
				return;
			}
			job.released = true;
			if (!job.printing) {
				LiveCodePrinter._forget(id);
			}
		},

		_forget: function(id) {
			var job = LiveCodePrinter._jobs[id];
			delete LiveCodePrinter._jobs[id];
			job.forgotten = true;
			// The files that no frame has
			job.pages.forEach(function(page) {
				if (page.url) {
					URL.revokeObjectURL(page.url);
					page.url = null;
				}
			});
		},

		_escape: function(text) {
			return String(text).replace(/[&<>"]/g, function(c) {
				return {'&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;'}[c];
			});
		},

		// The frame's document: a page for each picture, on a CSS page of
		// its size. A page whose size differs from the first's has a
		// named CSS page.
		//
		// The size is the picture's, not its page box's: Chrome lays out a
		// box of a fixed height on the previous page's paper (a taller
		// page went onto two of the first page's size), but a picture,
		// which cannot break, on its own.
		_document: function(job, urls) {
			var sizes = [];
			var body = '';
			job.pages.forEach(function(page, index) {
				var size = page.widthPt + 'pt ' + page.heightPt + 'pt';
				var paper = sizes.indexOf(size);
				if (paper < 0) {
					paper = sizes.length;
					sizes.push(size);
				}
				body += '<div class="oxt-page" style="page: oxt-paper-' + paper + '"><img src="' +
					urls[index] + '" alt="" style="width: ' + page.widthPt + 'pt; height: ' +
					page.heightPt + 'pt"></div>';
			});
			var style = '@page { size: ' + sizes[0] + '; margin: 0; }\n';
			sizes.forEach(function(size, paper) {
				style += '@page oxt-paper-' + paper + ' { size: ' + size + '; margin: 0; }\n';
			});
			style += 'html, body { margin: 0; padding: 0; }\n' +
				'.oxt-page { break-after: page; page-break-after: always; }\n' +
				'.oxt-page:last-child { break-after: auto; page-break-after: auto; }\n' +
				'.oxt-page img { display: block; }\n';
			return '<!DOCTYPE html><html><head><meta charset="utf-8"><title>' +
				LiveCodePrinter._escape(job.title) + '</title><style>' + style +
				'</style></head><body>' + body + '</body></html>';
		},

		// Prints the job's pages in a frame of their own: a promise that
		// is kept once the frame has printed them
		_print: function(job) {
			// The frames of the jobs that printed before go now
			LiveCodePrinter._frames.slice().forEach(function(frame) {
				if (frame.printed) {
					LiveCodePrinter._removeFrame(frame);
				}
			});

			var urls = job.pages.map(function(page) {
				return page.url;
			});
			if (urls.indexOf(null) >= 0) {
				throw new Error('a page has no picture');
			}

			var element = document.createElement('iframe');
			element.className = 'oxt-print-frame';
			element.setAttribute('aria-hidden', 'true');
			element.tabIndex = -1;
			element.style.cssText = 'position: fixed; right: 0; bottom: 0; width: 0; height: 0; border: 0;';
			var frame = {element: element, urls: urls, printed: false};
			LiveCodePrinter._frames.push(frame);
			job.frame = frame;
			// The files are the frame's now
			job.pages.forEach(function(page) {
				page.url = null;
			});

			var printed = new Promise(function(resolve, reject) {
				element.addEventListener('load', function() {
					var images = Array.prototype.slice.call(element.contentDocument.images);
					Promise.all(images.map(function(image) {
						return image.decode();
					})).then(function() {
						var view = element.contentWindow;
						view.addEventListener('afterprint', function() {
							setTimeout(function() {
								LiveCodePrinter._removeFrame(frame);
							}, 0);
						});
						frame.printed = true;
						view.focus();
						view.print();
						resolve();
					}).catch(reject);
				}, {once: true});
				element.srcdoc = LiveCodePrinter._document(job, urls);
				document.body.appendChild(element);
			});
			var timer;
			var timeout = new Promise(function(resolve, reject) {
				timer = setTimeout(function() {
					reject(new Error('the pages did not load'));
				}, LiveCodePrinter.kFrameTimeout);
			});
			return Promise.race([printed, timeout]).finally(function() {
				clearTimeout(timer);
			});
		},

		_removeFrame: function(frame) {
			var index = LiveCodePrinter._frames.indexOf(frame);
			if (index < 0) {
				return;
			}
			LiveCodePrinter._frames.splice(index, 1);
			if (frame.element.parentNode) {
				frame.element.parentNode.removeChild(frame.element);
			}
			frame.urls.forEach(function(url) {
				URL.revokeObjectURL(url);
			});
		},
	},

	MCEmscriptenPrinterUsesLetter__deps: ['$LiveCodePrinter'],
	MCEmscriptenPrinterUsesLetter: function() {
		return LiveCodePrinter.usesLetter();
	},

	MCEmscriptenPrintJobBegin__deps: ['$LiveCodePrinter', '$LiveCodeUtil'],
	MCEmscriptenPrintJobBegin: function(title, titleLength) {
		return LiveCodePrinter.begin(LiveCodeUtil.stringFromUTF16(title, titleLength));
	},

	MCEmscriptenPrintJobAddPage__deps: ['$LiveCodePrinter'],
	MCEmscriptenPrintJobAddPage: function(id, rgba, width, height, widthPt, heightPt) {
		return LiveCodePrinter.addPage(id, rgba, width, height, widthPt, heightPt);
	},

	MCEmscriptenPrintJobEnd__deps: ['$LiveCodePrinter'],
	MCEmscriptenPrintJobEnd: function(id) {
		LiveCodePrinter.end(id);
	},

	MCEmscriptenPrintJobIsPrinting__deps: ['$LiveCodePrinter'],
	MCEmscriptenPrintJobIsPrinting: function(id) {
		return LiveCodePrinter.isPrinting(id);
	},

	MCEmscriptenPrintJobFailed__deps: ['$LiveCodePrinter'],
	MCEmscriptenPrintJobFailed: function(id) {
		return LiveCodePrinter.failed(id);
	},

	MCEmscriptenPrintJobRelease__deps: ['$LiveCodePrinter'],
	MCEmscriptenPrintJobRelease: function(id) {
		LiveCodePrinter.release(id);
	},

});
