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

/* The web engine's browser: an <iframe> of the page (engine/src/em-browser.js),
 * which the browser widget places over the stack's canvas as its native
 * layer, as the player places its <video> (engine/src/em-player.cpp).
 *
 * The frame shows what a page can frame: the pages of the stack's own site,
 * the widget's htmlText, files of the engine's file system, and the pages of
 * other sites that let other sites frame them (many do not). A page of the
 * stack's site is the stack's to script, as every page is on the desktop:
 * the engine reads its URL and HTML text, runs JavaScript in it (do ... in
 * widget), and gives it the liveCode object of the javascriptHandlers. A
 * page of another site is the browser's alone: the engine knows only the
 * URL it gave the frame, and the page reaches the javascriptHandlers through
 * postMessage (see em-browser.js).
 */

#include <core.h>

#include "libbrowser_internal.h"

#include <stdlib.h>

////////////////////////////////////////////////////////////////////////////////

// The engine's (engine/src/em-javascript.cpp and libfoundation): the frame
// as the value that the engine's native layers take, and its release
extern "C" void *MCEmscriptenJSObjectFromID(uintptr_t p_id);
extern "C" void MCValueRelease(void *p_value);

// em-browser.js. The strings these return are the caller's, allocated with
// malloc, or nil.
extern "C" uintptr_t MCEmscriptenBrowserCreate(uint32_t p_id);
extern "C" void MCEmscriptenBrowserDestroy(uint32_t p_id);
extern "C" bool MCEmscriptenBrowserGoToURL(uint32_t p_id, const char *p_url);
extern "C" bool MCEmscriptenBrowserLoadHTMLText(uint32_t p_id, const char *p_html);
extern "C" void MCEmscriptenBrowserGoBack(uint32_t p_id);
extern "C" void MCEmscriptenBrowserGoForward(uint32_t p_id);
extern "C" void MCEmscriptenBrowserReload(uint32_t p_id);
extern "C" void MCEmscriptenBrowserStop(uint32_t p_id);
extern "C" char *MCEmscriptenBrowserEvaluate(uint32_t p_id, const char *p_script);
extern "C" bool MCEmscriptenBrowserGetBoolean(uint32_t p_id, uint32_t p_property);
extern "C" void MCEmscriptenBrowserSetBoolean(uint32_t p_id, uint32_t p_property, bool p_value);
extern "C" char *MCEmscriptenBrowserGetString(uint32_t p_id, uint32_t p_property);
extern "C" void MCEmscriptenBrowserSetString(uint32_t p_id, uint32_t p_property, const char *p_value);

// The properties that em-browser.js keeps (LiveCodeBrowser.kVScrollbar, ...)
enum MCEmscriptenBrowserProperty
{
	kMCEmscriptenBrowserPropertyNone = 0,
	kMCEmscriptenBrowserPropertyVScrollbar = 1,
	kMCEmscriptenBrowserPropertyHScrollbar = 2,
	kMCEmscriptenBrowserPropertyAllowUserInteraction = 3,
	kMCEmscriptenBrowserPropertyIsSecure = 4,
	kMCEmscriptenBrowserPropertyURL = 5,
	kMCEmscriptenBrowserPropertyHTMLText = 6,
	kMCEmscriptenBrowserPropertyUserAgent = 7,
	kMCEmscriptenBrowserPropertyJavaScriptHandlers = 8,
	kMCEmscriptenBrowserPropertyCanGoBack = 9,
	kMCEmscriptenBrowserPropertyCanGoForward = 10,
};

// The events that em-browser.js tells the engine of
// (LiveCodeBrowser.kNavigateBegin, ...)
enum MCEmscriptenBrowserEvent
{
	kMCEmscriptenBrowserEventNavigateBegin = 1,
	kMCEmscriptenBrowserEventNavigateComplete = 2,
	kMCEmscriptenBrowserEventNavigateFailed = 3,
	kMCEmscriptenBrowserEventDocumentLoadBegin = 4,
	kMCEmscriptenBrowserEventDocumentLoadComplete = 5,
	kMCEmscriptenBrowserEventDocumentLoadFailed = 6,
	kMCEmscriptenBrowserEventUnhandled = 7,
	kMCEmscriptenBrowserEventProgress = 8,
};

static uint32_t MCEmscriptenBrowserPropertyFor(MCBrowserProperty p_property)
{
	switch (p_property)
	{
		case kMCBrowserVerticalScrollbarEnabled:
			return kMCEmscriptenBrowserPropertyVScrollbar;
		case kMCBrowserHorizontalScrollbarEnabled:
			return kMCEmscriptenBrowserPropertyHScrollbar;
		case kMCBrowserAllowUserInteraction:
			return kMCEmscriptenBrowserPropertyAllowUserInteraction;
		case kMCBrowserIsSecure:
			return kMCEmscriptenBrowserPropertyIsSecure;
		case kMCBrowserURL:
			return kMCEmscriptenBrowserPropertyURL;
		case kMCBrowserHTMLText:
			return kMCEmscriptenBrowserPropertyHTMLText;
		case kMCBrowserUserAgent:
			return kMCEmscriptenBrowserPropertyUserAgent;
		case kMCBrowserJavaScriptHandlers:
			return kMCEmscriptenBrowserPropertyJavaScriptHandlers;
		case kMCBrowserCanGoBack:
			return kMCEmscriptenBrowserPropertyCanGoBack;
		case kMCBrowserCanGoForward:
			return kMCEmscriptenBrowserPropertyCanGoForward;
		default:
			// The other platforms' own (data detectors, the iOS
			// properties, new windows and the context menu): the frame
			// has none of them
			return kMCEmscriptenBrowserPropertyNone;
	}
}

////////////////////////////////////////////////////////////////////////////////

class MCEmscriptenBrowser : public MCBrowserBase
{
public:
	MCEmscriptenBrowser() : m_id(++s_last_id), m_element(nil)
	{
		MCBrowserBase::BrowserListAdd(this);
	}

	~MCEmscriptenBrowser()
	{
		MCBrowserBase::BrowserListRemove(this);

		MCEmscriptenBrowserDestroy(m_id);
		if (m_element != nil)
			MCValueRelease(m_element);
	}

	bool Init()
	{
		uintptr_t t_element_id;
		t_element_id = MCEmscriptenBrowserCreate(m_id);
		if (t_element_id == 0)
			return false;

		m_element = MCEmscriptenJSObjectFromID(t_element_id);
		return m_element != nil;
	}

	uint32_t GetId()
	{
		return m_id;
	}

	virtual void *GetNativeLayer()
	{
		return m_element;
	}

	// The native layer places the frame
	virtual bool GetRect(MCBrowserRect &r_rect)
	{
		return false;
	}

	virtual bool SetRect(const MCBrowserRect &p_rect)
	{
		return false;
	}

	virtual bool GetBoolProperty(MCBrowserProperty p_property, bool &r_value)
	{
		uint32_t t_property;
		t_property = MCEmscriptenBrowserPropertyFor(p_property);

		r_value = t_property != kMCEmscriptenBrowserPropertyNone &&
			MCEmscriptenBrowserGetBoolean(m_id, t_property);
		return true;
	}

	virtual bool SetBoolProperty(MCBrowserProperty p_property, bool p_value)
	{
		uint32_t t_property;
		t_property = MCEmscriptenBrowserPropertyFor(p_property);

		if (t_property != kMCEmscriptenBrowserPropertyNone)
			MCEmscriptenBrowserSetBoolean(m_id, t_property, p_value);
		return true;
	}

	virtual bool GetStringProperty(MCBrowserProperty p_property, char *&r_utf8_string)
	{
		uint32_t t_property;
		t_property = MCEmscriptenBrowserPropertyFor(p_property);

		char *t_value;
		t_value = nil;
		if (t_property != kMCEmscriptenBrowserPropertyNone)
			t_value = MCEmscriptenBrowserGetString(m_id, t_property);

		if (t_value == nil)
			return MCCStringClone("", r_utf8_string);

		r_utf8_string = t_value;
		return true;
	}

	virtual bool SetStringProperty(MCBrowserProperty p_property, const char *p_utf8_string)
	{
		if (p_property == kMCBrowserHTMLText)
			return LoadHTMLText(p_utf8_string, nil);

		uint32_t t_property;
		t_property = MCEmscriptenBrowserPropertyFor(p_property);

		if (t_property != kMCEmscriptenBrowserPropertyNone)
			MCEmscriptenBrowserSetString(m_id, t_property, p_utf8_string != nil ? p_utf8_string : "");
		return true;
	}

	virtual bool GetIntegerProperty(MCBrowserProperty p_property, int32_t &r_value)
	{
		r_value = 0;
		return true;
	}

	virtual bool SetIntegerProperty(MCBrowserProperty p_property, int32_t p_value)
	{
		return true;
	}

	virtual bool GoBack()
	{
		MCEmscriptenBrowserGoBack(m_id);
		return true;
	}

	virtual bool GoForward()
	{
		MCEmscriptenBrowserGoForward(m_id);
		return true;
	}

	virtual bool GoToURL(const char *p_url)
	{
		return MCEmscriptenBrowserGoToURL(m_id, p_url != nil ? p_url : "");
	}

	// The page's base URL is the stack's page: the text's relative URLs
	// are of the stack's site
	virtual bool LoadHTMLText(const char *p_htmltext, const char *p_base_url)
	{
		return MCEmscriptenBrowserLoadHTMLText(m_id, p_htmltext != nil ? p_htmltext : "");
	}

	virtual bool StopLoading()
	{
		MCEmscriptenBrowserStop(m_id);
		return true;
	}

	virtual bool Reload()
	{
		MCEmscriptenBrowserReload(m_id);
		return true;
	}

	// Fails for a page of another site, which the engine cannot script
	virtual bool EvaluateJavaScript(const char *p_script, char *&r_result)
	{
		char *t_result;
		t_result = MCEmscriptenBrowserEvaluate(m_id, p_script != nil ? p_script : "");
		if (t_result == nil)
			return false;

		r_result = t_result;
		return true;
	}

private:
	static uint32_t s_last_id;

	uint32_t m_id;
	void *m_element;
};

uint32_t MCEmscriptenBrowser::s_last_id = 0;

////////////////////////////////////////////////////////////////////////////////

struct MCEmscriptenBrowserFindContext
{
	uint32_t id;
	MCEmscriptenBrowser *browser;
};

static bool MCEmscriptenBrowserFindCallback(MCBrowser *p_browser, void *p_context)
{
	MCEmscriptenBrowserFindContext *t_context;
	t_context = static_cast<MCEmscriptenBrowserFindContext *>(p_context);

	MCEmscriptenBrowser *t_browser;
	t_browser = static_cast<MCEmscriptenBrowser *>(p_browser);
	if (t_browser->GetId() != t_context->id)
		return true;

	t_context->browser = t_browser;
	return false;
}

// The browser with <p_id>, if it has not been released
static MCEmscriptenBrowser *MCEmscriptenBrowserFind(uint32_t p_id)
{
	MCEmscriptenBrowserFindContext t_context;
	t_context.id = p_id;
	t_context.browser = nil;
	MCBrowserBase::BrowserListIterate(MCEmscriptenBrowserFindCallback, &t_context);
	return t_context.browser;
}

// em-browser.js tells the engine of what the frame does: the widget sends
// its messages (browserNavigateBegin, ...). The frame's page is its main
// frame's.
extern "C" MC_BROWSER_DLLEXPORT_DEF
void MCEmscriptenBrowserHandleEvent(uint32_t p_id, uint32_t p_event, const char *p_url, const char *p_error, uint32_t p_progress)
{
	MCEmscriptenBrowser *t_browser;
	t_browser = MCEmscriptenBrowserFind(p_id);
	if (t_browser == nil)
		return;

	if (p_url == nil)
		p_url = "";
	if (p_error == nil)
		p_error = "";

	// The widget may release the browser in its handlers
	t_browser->Retain();
	switch (p_event)
	{
		case kMCEmscriptenBrowserEventNavigateBegin:
			t_browser->OnNavigationBegin(false, p_url);
			break;
		case kMCEmscriptenBrowserEventNavigateComplete:
			t_browser->OnNavigationComplete(false, p_url);
			break;
		case kMCEmscriptenBrowserEventNavigateFailed:
			t_browser->OnNavigationFailed(false, p_url, p_error);
			break;
		case kMCEmscriptenBrowserEventDocumentLoadBegin:
			t_browser->OnDocumentLoadBegin(false, p_url);
			break;
		case kMCEmscriptenBrowserEventDocumentLoadComplete:
			t_browser->OnDocumentLoadComplete(false, p_url);
			break;
		case kMCEmscriptenBrowserEventDocumentLoadFailed:
			t_browser->OnDocumentLoadFailed(false, p_url, p_error);
			break;
		case kMCEmscriptenBrowserEventUnhandled:
			t_browser->OnNavigationRequestUnhandled(false, p_url);
			break;
		case kMCEmscriptenBrowserEventProgress:
			t_browser->OnProgressChanged(p_url, p_progress);
			break;
		default:
			break;
	}
	t_browser->Release();
}

// The page called one of the javascriptHandlers, with <p_params>
extern "C" MC_BROWSER_DLLEXPORT_DEF
void MCEmscriptenBrowserHandleJavaScriptCall(uint32_t p_id, const char *p_handler, MCBrowserListRef p_params)
{
	MCEmscriptenBrowser *t_browser;
	t_browser = MCEmscriptenBrowserFind(p_id);
	if (t_browser == nil || p_handler == nil || p_params == nil)
		return;

	t_browser->Retain();
	t_browser->OnJavaScriptCall(p_handler, p_params);
	t_browser->Release();
}

// The parameters of a call, as em-browser.js makes them: a list of values,
// each a boolean, an integer, a number, a string, a list or a dictionary
// (MCBrowserValueType), as the desktop's browsers convert JavaScript's
// values. A list or dictionary given to another is retained by it.

extern "C" MC_BROWSER_DLLEXPORT_DEF
MCBrowserListRef MCEmscriptenBrowserListCreate(void)
{
	MCBrowserListRef t_list;
	if (!MCBrowserListCreate(t_list))
		return nil;
	return t_list;
}

extern "C" MC_BROWSER_DLLEXPORT_DEF
MCBrowserDictionaryRef MCEmscriptenBrowserDictionaryCreate(void)
{
	MCBrowserDictionaryRef t_dict;
	if (!MCBrowserDictionaryCreate(t_dict))
		return nil;
	return t_dict;
}

extern "C" MC_BROWSER_DLLEXPORT_DEF
void MCEmscriptenBrowserValueRelease(uint32_t p_type, void *p_value)
{
	if (p_value == nil)
		return;
	if (p_type == kMCBrowserValueTypeList)
		MCBrowserListRelease(static_cast<MCBrowserListRef>(p_value));
	else if (p_type == kMCBrowserValueTypeDictionary)
		MCBrowserDictionaryRelease(static_cast<MCBrowserDictionaryRef>(p_value));
}

extern "C" MC_BROWSER_DLLEXPORT_DEF
bool MCEmscriptenBrowserListAppend(MCBrowserListRef p_list, uint32_t p_type, double p_number, const char *p_string, void *p_value)
{
	switch (p_type)
	{
		case kMCBrowserValueTypeBoolean:
			return MCBrowserListAppendBoolean(p_list, p_number != 0);
		case kMCBrowserValueTypeInteger:
			return MCBrowserListAppendInteger(p_list, int32_t(p_number));
		case kMCBrowserValueTypeDouble:
			return MCBrowserListAppendDouble(p_list, p_number);
		case kMCBrowserValueTypeUTF8String:
			return MCBrowserListAppendUTF8String(p_list, p_string != nil ? p_string : "");
		case kMCBrowserValueTypeList:
			return MCBrowserListAppendList(p_list, static_cast<MCBrowserListRef>(p_value));
		case kMCBrowserValueTypeDictionary:
			return MCBrowserListAppendDictionary(p_list, static_cast<MCBrowserDictionaryRef>(p_value));
		default:
			return false;
	}
}

extern "C" MC_BROWSER_DLLEXPORT_DEF
bool MCEmscriptenBrowserDictionarySet(MCBrowserDictionaryRef p_dict, const char *p_key, uint32_t p_type, double p_number, const char *p_string, void *p_value)
{
	if (p_key == nil)
		return false;

	switch (p_type)
	{
		case kMCBrowserValueTypeBoolean:
			return MCBrowserDictionarySetBoolean(p_dict, p_key, p_number != 0);
		case kMCBrowserValueTypeInteger:
			return MCBrowserDictionarySetInteger(p_dict, p_key, int32_t(p_number));
		case kMCBrowserValueTypeDouble:
			return MCBrowserDictionarySetDouble(p_dict, p_key, p_number);
		case kMCBrowserValueTypeUTF8String:
			return MCBrowserDictionarySetUTF8String(p_dict, p_key, p_string != nil ? p_string : "");
		case kMCBrowserValueTypeList:
			return MCBrowserDictionarySetList(p_dict, p_key, static_cast<MCBrowserListRef>(p_value));
		case kMCBrowserValueTypeDictionary:
			return MCBrowserDictionarySetDictionary(p_dict, p_key, static_cast<MCBrowserDictionaryRef>(p_value));
		default:
			return false;
	}
}

////////////////////////////////////////////////////////////////////////////////

class MCEmscriptenBrowserFactory : public MCBrowserFactory
{
	virtual bool CreateBrowser(void *p_display, void *p_parent_view, MCBrowser *&r_browser)
	{
		MCEmscriptenBrowser *t_browser;
		t_browser = new (nothrow) MCEmscriptenBrowser();

		if (t_browser == nil)
			return false;

		if (!t_browser->Init())
		{
			delete t_browser;
			return false;
		}

		r_browser = t_browser;

		return true;
	}
};

bool MCEmscriptenBrowserFactoryCreate(MCBrowserFactoryRef &r_factory)
{
	MCBrowserFactory *t_factory = new (nothrow) MCEmscriptenBrowserFactory();

	if (t_factory == nil)
		return false;

	r_factory = t_factory;
	return true;
}

////////////////////////////////////////////////////////////////////////////////
