/* Copyright (C) 2026 OpenXTalk Contributors.

This file is part of LiveCode / OpenXTalk.

LiveCode is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License v3 as published by the Free
Software Foundation.

LiveCode is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with LiveCode.  If not see <http://www.gnu.org/licenses/>.  */

#include "cxml.h"
#include <libxml/parserInternals.h>
#include <limits.h>
#include <stdint.h>

//-----------------------NATIVE TEXT AND ENCODINGS, AS LIBXML2 2.9 READ THEM---------------------

// revXML is a v0 external: the engine passes it text in the native encoding
//   (Windows-1252 on Windows, ISO-8859-1 on Linux, UTF-8 on macOS) and takes
//   native text back. libxml2 2.9 read a document that declared no other
//   encoding as UTF-8 up to the first byte that was not UTF-8, and from there
//   on byte by byte ("Input is not proper UTF-8, indicate encoding !", which
//   refused the document unless bad data was parsed). So the tree of a
//   document in native text held the text's own bytes, and the getters,
//   matching and XPath gave back what the script had put in. libxml2 2.15
//   reads each such byte as U+FFFD.
// To keep 2.9's trees, a byte that is not UTF-8 reaches libxml2 as a
//   "marker", the character U+DFF00 plus the byte (four bytes of UTF-8).
//   Plane 13 is unassigned, but its characters are XML characters and name
//   characters, so the parse goes on as 2.9's did. Afterwards the markers in
//   the tree, in the SAX messages and in the error message become the bytes
//   again. Valid UTF-8 keeps its meaning, as it did in 2.9, and a document
//   in memory that is all UTF-8 (what macOS passes) is parsed as it is.

#define REVXML_MARKER_LENGTH 4

// The name of the encoding that turns a file's bytes into UTF-8 with
//   markers (revxml_find_encoding); no real encoding has it.
static const char kRevXMLNativeEncoding[] = "x-revxml-native";

// The bytes libxml2 2.9 put in one characters message when text was not
//   ASCII (XML_PARSER_BIG_BUFFER_SIZE): it cut such text after at least 300
//   bytes.
#define REVXML_TEXT_CHUNK 300

// Writes the marker for p_byte (0x80 to 0xFF) at r_out.
static void revxml_marker_write(unsigned char p_byte, unsigned char *r_out)
{
	r_out[0] = 0xF3;
	r_out[1] = 0x9F;
	r_out[2] = p_byte < 0xC0 ? 0xBE : 0xBF;
	r_out[3] = 0x80 | (p_byte & 0x3F);
}

// Whether the p_length bytes at p_text start with a marker.
static bool revxml_marker_at(const unsigned char *p_text, size_t p_length)
{
	return p_length >= REVXML_MARKER_LENGTH && p_text[0] == 0xF3 && p_text[1] == 0x9F &&
		(p_text[2] & 0xFE) == 0xBE && (p_text[3] & 0xC0) == 0x80;
}

static unsigned char revxml_marker_byte(const unsigned char *p_marker)
{
	return (unsigned char)(0x80 | ((p_marker[2] & 0x01) << 6) | (p_marker[3] & 0x3F));
}

// The length of the UTF-8 character at p_text if libxml2 2.15 reads it as
//   one (1 to 4), 0 if it does not (a stray continuation byte, an overlong
//   form, a surrogate, a code point past U+10FFFF), or -1 if the p_available
//   bytes there start a character but end before it does.
static int revxml_utf8_check(const unsigned char *p_text, size_t p_available)
{
	unsigned char t_lead;
	int t_length;
	t_lead = p_text[0];
	if (t_lead < 0x80)
		return 1;
	if (t_lead < 0xC2)
		return 0;
	else if (t_lead < 0xE0)
		t_length = 2;
	else if (t_lead < 0xF0)
		t_length = 3;
	else if (t_lead < 0xF5)
		t_length = 4;
	else
		return 0;
	for (int i = 1; i < t_length; i++)
	{
		if ((size_t)i >= p_available)
			return -1;
		if ((p_text[i] & 0xC0) != 0x80)
			return 0;
		// The second byte rules out the overlong forms, the surrogates and
		//   the code points past U+10FFFF.
		if (i == 1 && ((t_lead == 0xE0 && p_text[1] < 0xA0) || (t_lead == 0xED && p_text[1] >= 0xA0) ||
					   (t_lead == 0xF0 && p_text[1] < 0x90) || (t_lead == 0xF4 && p_text[1] >= 0x90)))
			return 0;
	}
	return t_length;
}

// Whether libxml2 2.9 refused the bytes at p_text as UTF-8 (its
//   xmlCurrentChar), where it said "Input is not proper UTF-8". Only asked
//   where 2.15 refuses them too; 2.9 let surrogates and code points past
//   U+10FFFF through as characters.
static bool revxml_utf8_refused_by_29(const unsigned char *p_text, size_t p_available)
{
	unsigned char t_lead;
	unsigned int t_value;
	t_lead = p_text[0];
	if ((t_lead & 0x40) == 0 || t_lead == 0xC0)
		return true;
	if (p_available < 2 || (p_text[1] & 0xC0) != 0x80)
		return true;
	if ((t_lead & 0xE0) != 0xE0)
		return (((t_lead & 0x1F) << 6) | (p_text[1] & 0x3F)) < 0x80;
	if (p_available < 3 || (p_text[2] & 0xC0) != 0x80)
		return true;
	if ((t_lead & 0xF0) != 0xF0)
		return (((t_lead & 0x0F) << 12) | ((p_text[1] & 0x3F) << 6) | (p_text[2] & 0x3F)) < 0x800;
	if ((t_lead & 0xF8) != 0xF0 || p_available < 4 || (p_text[3] & 0xC0) != 0x80)
		return true;
	t_value = ((t_lead & 0x07) << 18) | ((p_text[1] & 0x3F) << 12) | ((p_text[2] & 0x3F) << 6) | (p_text[3] & 0x3F);
	return t_value < 0x10000;
}

// The state of one parse, for the SAX handlers, the error handlers and the
//   native decoder. A script can parse another document from a SAX message,
//   so parses nest: s_revxml_parse is the innermost, and each one keeps the
//   one it interrupted.
struct RevXMLParse
{
	xmlParserCtxtPtr ctxt;
	RevXMLParse *previous;
	// The document was refused unless bad data was parsed (wellformed).
	bool strict;
	// 8-bit text labelled UTF-16, which 2.9 read as UTF-8 ("Document
	//   labelled UTF-16 but has UTF-8 content", a refusal when strict).
	bool label16;
	// Markers stand for bytes that are not UTF-8.
	bool native;
	// When strict, libxml2 2.9 stopped sending SAX messages at its first
	//   error, except for runs of ASCII text and the end of the document.
	bool stopped;
	// Text that reaches the end of libxml2's buffer is held for the text
	//   that follows it: 2.9 had the whole of a document in memory at once.
	bool hold;
	bool error_seen;
	bool error_after_refusal;
	// Where 2.9 first refused a byte as UTF-8, in the text the parser reads
	//   (markers included), and the four bytes there for its message.
	bool refused;
	size_t refused_offset;
	size_t refused_raw;
	unsigned char refused_bytes[4];
	size_t refused_count;
	// The decoder has read a NUL byte, where 2.9 stopped reading.
	bool nul;
	// Bad data is parsed and the parse has passed the byte 2.9 refused:
	//   2.9 read the rest of the document as ISO-8859-1.
	bool passed;
	// What a character reference became (revxml_parse_char_ref).
	xmlChar char_ref[16];
	// How many bytes the native decoder has read and written.
	size_t raw;
	size_t decoded;
	// Text kept back from the SAX handler (kRevXMLText...).
	int text_kind;
	xmlChar *text;
	size_t text_length;
	size_t text_capacity;
	const xmlParserInput *text_input;
	size_t text_end;
};

enum
{
	kRevXMLTextNone,
	// Text up to the end of libxml2's buffer, which more text may follow.
	kRevXMLTextHeld,
	// Native text in the middle of a run, which is cut as 2.9 cut it.
	kRevXMLTextRun,
};

static RevXMLParse *s_revxml_parse = NULL;

// The parse whose parser context p_context is, or NULL.
static RevXMLParse *revxml_parse_for(void *p_context)
{
	if (s_revxml_parse != NULL && p_context != NULL && p_context == (void *)s_revxml_parse->ctxt)
		return s_revxml_parse;
	return NULL;
}

// Where the parser is in the document entity (inputTab[0]), counted in
//   the bytes it reads.
static size_t revxml_parse_position(RevXMLParse *p_parse)
{
	xmlParserCtxtPtr t_ctxt;
	xmlParserInputPtr t_input;
	t_ctxt = p_parse->ctxt;
	if (t_ctxt->inputNr < 1 || t_ctxt->inputTab == NULL || t_ctxt->inputTab[0] == NULL)
		return 0;
	t_input = t_ctxt->inputTab[0];
	return (size_t)t_input->consumed + (size_t)(t_input->cur - t_input->base);
}

// Whether 2.9 still sent SAX messages here: when strict, not once the
//   parser has passed the byte that 2.9 refused.
static bool revxml_parse_sending(RevXMLParse *p_parse)
{
	if (p_parse == NULL)
		return true;
	if (!p_parse->stopped && p_parse->strict && p_parse->refused &&
		revxml_parse_position(p_parse) > p_parse->refused_offset)
		p_parse->stopped = true;
	return !p_parse->stopped;
}

// Notes that 2.9 refused the bytes at p_text, when it is the first such
//   place: the parser reads them at p_offset, and they are at p_raw in the
//   document.
static void revxml_parse_refuse(RevXMLParse *p_parse, size_t p_offset, size_t p_raw, const unsigned char *p_text, size_t p_available)
{
	if (p_parse->refused || p_parse->nul || !revxml_utf8_refused_by_29(p_text, p_available))
		return;
	p_parse->refused = true;
	p_parse->refused_offset = p_offset;
	p_parse->refused_raw = p_raw;
	p_parse->refused_count = p_available < 4 ? p_available : 4;
	memcpy(p_parse->refused_bytes, p_text, p_parse->refused_count);
}

// Copies p_in to r_out, writing a marker for each byte that is not UTF-8.
//   *x_in and *x_out are the lengths of the two on entry, and how much of
//   each was used on return. Unless p_flush, a character that p_in ends in
//   the middle of is left for the next call. Returns false when r_out is
//   full first.
static bool revxml_native_decode(RevXMLParse *p_parse, const unsigned char *p_in, size_t *x_in,
								 unsigned char *r_out, size_t *x_out, bool p_flush)
{
	size_t t_in_length, t_out_length, i, o;
	bool t_complete;
	t_in_length = *x_in;
	t_out_length = *x_out;
	i = 0;
	o = 0;
	t_complete = true;
	// The bytes after the one 2.9 refused, for its message, when the call
	//   that refused it ended before them.
	if (p_parse->refused && p_parse->refused_count < 4)
	{
		size_t t_next;
		t_next = p_parse->refused_raw + p_parse->refused_count - p_parse->raw;
		while (p_parse->refused_count < 4 && t_next < t_in_length)
			p_parse->refused_bytes[p_parse->refused_count++] = p_in[t_next++];
	}
	while (i < t_in_length)
	{
		int t_length;
		t_length = revxml_utf8_check(p_in + i, t_in_length - i);
		if (t_length < 0 && !p_flush)
			break;
		if (t_length > 0)
		{
			if ((size_t)t_length > t_out_length - o)
			{
				t_complete = false;
				break;
			}
			if (p_in[i] == 0)
				p_parse->nul = true;
			memcpy(r_out + o, p_in + i, t_length);
			o += t_length;
			i += t_length;
		}
		else
		{
			if (REVXML_MARKER_LENGTH > t_out_length - o)
			{
				t_complete = false;
				break;
			}
			revxml_parse_refuse(p_parse, p_parse->decoded + o, p_parse->raw + i, p_in + i, t_in_length - i);
			revxml_marker_write(p_in[i], r_out + o);
			o += REVXML_MARKER_LENGTH;
			i += 1;
			p_parse->native = true;
		}
	}
	p_parse->decoded += o;
	p_parse->raw += i;
	*x_in = i;
	*x_out = o;
	return t_complete;
}

// The input function of the native decoder (an xmlCharEncConvFunc).
static xmlCharEncError revxml_native_input(void *p_context, unsigned char *r_out, int *x_out_length,
										   const unsigned char *p_in, int *x_in_length, int p_flush)
{
	size_t t_in, t_out;
	bool t_complete;
	t_in = (size_t)*x_in_length;
	t_out = (size_t)*x_out_length;
	t_complete = revxml_native_decode((RevXMLParse *)p_context, p_in, &t_in, r_out, &t_out, p_flush != 0);
	*x_in_length = (int)t_in;
	*x_out_length = (int)t_out;
	return t_complete ? XML_ENC_ERR_SUCCESS : XML_ENC_ERR_SPACE;
}

// The encodings of a parse (an xmlCharEncConvImpl): the native decoder for
//   kRevXMLNativeEncoding, libxml2's own for any other.
static xmlParserErrors revxml_find_encoding(void *p_context, const char *p_name, xmlCharEncFlags p_flags,
											xmlCharEncodingHandler **r_handler)
{
	if (strcmp(p_name, kRevXMLNativeEncoding) == 0 && (p_flags & XML_ENC_OUTPUT) == 0)
		return xmlCharEncNewCustomHandler(p_name, revxml_native_input, NULL, NULL, p_context, NULL, r_handler);
	return xmlCreateCharEncodingHandler(p_name, p_flags, NULL, NULL, r_handler);
}

// p_text (p_length bytes) with its markers turned back into bytes, in a new
//   buffer (r_length bytes and a NUL), or NULL when it has no markers.
static xmlChar *revxml_unmark(const xmlChar *p_text, size_t p_length, size_t *r_length)
{
	const xmlChar *t_marker;
	xmlChar *t_copy;
	size_t i, o;
	t_marker = NULL;
	for (i = 0; i + REVXML_MARKER_LENGTH <= p_length; i++)
		if (revxml_marker_at(p_text + i, p_length - i))
		{
			t_marker = p_text + i;
			break;
		}
	if (t_marker == NULL)
		return NULL;
	t_copy = (xmlChar *)xmlMalloc(p_length + 1);
	if (t_copy == NULL)
		return NULL;
	o = 0;
	for (i = 0; i < p_length;)
		if (revxml_marker_at(p_text + i, p_length - i))
		{
			t_copy[o++] = revxml_marker_byte(p_text + i);
			i += REVXML_MARKER_LENGTH;
		}
		else
			t_copy[o++] = p_text[i++];
	t_copy[o] = '\0';
	*r_length = o;
	return t_copy;
}

// The string p_string of the tree, with its markers turned back into bytes.
//   A string the document's dictionary owns is shared, so a name (p_name)
//   is looked up in the dictionary and any other text copied; a string of
//   the node's own is changed where it is (it only gets shorter).
static const xmlChar *revxml_unmark_string(xmlDictPtr p_dict, const xmlChar *p_string, bool p_name)
{
	xmlChar *t_copy;
	size_t t_length;
	const xmlChar *t_name;
	if (p_string == NULL)
		return NULL;
	t_copy = revxml_unmark(p_string, strlen((const char *)p_string), &t_length);
	if (t_copy == NULL)
		return p_string;
	if (p_dict != NULL && xmlDictOwns(p_dict, p_string) == 1)
	{
		if (!p_name)
			return t_copy;
		t_name = t_length <= INT_MAX ? xmlDictLookup(p_dict, t_copy, (int)t_length) : NULL;
		xmlFree(t_copy);
		return t_name != NULL ? t_name : p_string;
	}
	memcpy((xmlChar *)p_string, t_copy, t_length + 1);
	xmlFree(t_copy);
	return p_string;
}

static void revxml_unmark_nodes(xmlDocPtr p_doc, xmlNodePtr p_first, xmlNodePtr p_parent);

// The strings of one node of the tree, of an element's attributes and
//   namespace declarations, and of the declarations in a DTD.
static void revxml_unmark_node(xmlDocPtr p_doc, xmlNodePtr p_node)
{
	xmlDictPtr t_dict;
	t_dict = p_doc->dict;
	switch (p_node->type)
	{
	case XML_ELEMENT_NODE:
		p_node->name = revxml_unmark_string(t_dict, p_node->name, true);
		for (xmlAttrPtr t_attr = p_node->properties; t_attr != NULL; t_attr = t_attr->next)
		{
			t_attr->name = revxml_unmark_string(t_dict, t_attr->name, true);
			revxml_unmark_nodes(p_doc, t_attr->children, (xmlNodePtr)t_attr);
		}
		for (xmlNsPtr t_ns = p_node->nsDef; t_ns != NULL; t_ns = t_ns->next)
		{
			t_ns->href = revxml_unmark_string(t_dict, t_ns->href, true);
			t_ns->prefix = revxml_unmark_string(t_dict, t_ns->prefix, true);
		}
		break;
	case XML_PI_NODE:
		p_node->name = revxml_unmark_string(t_dict, p_node->name, true);
		p_node->content = (xmlChar *)revxml_unmark_string(t_dict, p_node->content, false);
		break;
	case XML_TEXT_NODE:
	case XML_CDATA_SECTION_NODE:
	case XML_COMMENT_NODE:
		p_node->content = (xmlChar *)revxml_unmark_string(t_dict, p_node->content, false);
		break;
	case XML_DTD_NODE:
		// The entities' text and the attributes' defaults; the names of
		//   declarations stay as they are, because libxml2 finds the
		//   declarations by name in tables.
		for (xmlNodePtr t_decl = p_node->children; t_decl != NULL; t_decl = t_decl->next)
		{
			if (t_decl->type == XML_ENTITY_DECL)
			{
				xmlEntityPtr t_entity;
				t_entity = (xmlEntityPtr)t_decl;
				t_entity->content = (xmlChar *)revxml_unmark_string(t_dict, t_entity->content, false);
				t_entity->orig = (xmlChar *)revxml_unmark_string(t_dict, t_entity->orig, false);
				if (t_entity->content != NULL)
					t_entity->length = xmlStrlen(t_entity->content);
				revxml_unmark_nodes(p_doc, t_entity->children, t_decl);
			}
			else if (t_decl->type == XML_ATTRIBUTE_DECL)
			{
				xmlAttributePtr t_attribute;
				t_attribute = (xmlAttributePtr)t_decl;
				t_attribute->defaultValue = (xmlChar *)revxml_unmark_string(t_dict, t_attribute->defaultValue, false);
			}
			else if (t_decl->type == XML_COMMENT_NODE || t_decl->type == XML_PI_NODE)
				revxml_unmark_node(p_doc, t_decl);
		}
		break;
	default:
		// An entity reference's children are the entity's, done with the
		//   DTD.
		break;
	}
}

// The nodes from p_first on, and all below them, up to the end of the list
//   of p_parent's children. Iterative, so that a deep tree needs no deep
//   stack.
static void revxml_unmark_nodes(xmlDocPtr p_doc, xmlNodePtr p_first, xmlNodePtr p_parent)
{
	xmlNodePtr t_node;
	t_node = p_first;
	while (t_node != NULL)
	{
		revxml_unmark_node(p_doc, t_node);
		if (t_node->type == XML_ELEMENT_NODE && t_node->children != NULL)
		{
			t_node = t_node->children;
			continue;
		}
		while (t_node != NULL && t_node->next == NULL)
		{
			t_node = t_node->parent;
			if (t_node == p_parent)
				t_node = NULL;
		}
		if (t_node != NULL)
			t_node = t_node->next;
	}
}

// Turns the markers in the NUL-terminated p_text back into bytes, in place.
static void revxml_unmark_in_place(char *p_text)
{
	size_t t_length;
	xmlChar *t_copy;
	t_copy = revxml_unmark((const xmlChar *)p_text, strlen(p_text), &t_length);
	if (t_copy == NULL)
		return;
	memcpy(p_text, t_copy, t_length + 1);
	xmlFree(t_copy);
}

//----

// How a document's first bytes say it is to be read.
enum
{
	// As libxml2 reads it: a declared encoding, or UTF-16 or another
	//   encoding that libxml2 finds from its first bytes.
	kRevXMLHeadDeclared,
	// As UTF-8, with markers for the bytes that are not: no encoding
	//   declaration, UTF-8, or (8-bit text) UTF-16.
	kRevXMLHeadUTF8,
	// An encoding libxml2 cannot read, which 2.9 refused before parsing.
	kRevXMLHeadUnsupported,
};

struct RevXMLHead
{
	int kind;
	// The text is 8-bit and labelled UTF-16.
	bool label16;
	// libxml2 found UTF-16 from the first bytes.
	bool utf16;
	// The declared encoding, or empty.
	char label[64];
};

// The encoding the XML declaration at the start of the p_length bytes at
//   p_text names (r_label), where each character is p_width bytes, the
//   ASCII byte at p_low in it and zeros in the others.
static void revxml_head_label(const unsigned char *p_text, size_t p_length, size_t p_width, size_t p_low, char *r_label, size_t p_size)
{
	char t_decl[256];
	size_t t_decl_length;
	const char *t_cursor, *t_end;
	char t_quote;
	size_t t_label_length;
	r_label[0] = '\0';
	// The declaration as ASCII, up to its "?>".
	t_decl_length = 0;
	for (size_t i = 0; i + p_width <= p_length && t_decl_length < sizeof(t_decl) - 1; i += p_width)
	{
		bool t_ascii;
		t_ascii = p_text[i + p_low] < 0x80;
		for (size_t j = 0; j < p_width; j++)
			if (j != p_low && p_text[i + j] != 0)
				t_ascii = false;
		if (!t_ascii)
			break;
		t_decl[t_decl_length++] = (char)p_text[i + p_low];
		if (t_decl_length >= 2 && t_decl[t_decl_length - 2] == '?' && t_decl[t_decl_length - 1] == '>')
			break;
	}
	t_decl[t_decl_length] = '\0';
	if (t_decl_length < 6 || strncmp(t_decl, "<?xml", 5) != 0 ||
		(t_decl[5] != ' ' && t_decl[5] != '\t' && t_decl[5] != '\r' && t_decl[5] != '\n'))
		return;
	t_end = t_decl + t_decl_length;
	t_cursor = strstr(t_decl, "encoding");
	if (t_cursor == NULL || (t_cursor[-1] != ' ' && t_cursor[-1] != '\t' && t_cursor[-1] != '\r' && t_cursor[-1] != '\n'))
		return;
	t_cursor += 8;
	while (t_cursor < t_end && (*t_cursor == ' ' || *t_cursor == '\t' || *t_cursor == '\r' || *t_cursor == '\n'))
		t_cursor++;
	if (t_cursor >= t_end || *t_cursor != '=')
		return;
	t_cursor++;
	while (t_cursor < t_end && (*t_cursor == ' ' || *t_cursor == '\t' || *t_cursor == '\r' || *t_cursor == '\n'))
		t_cursor++;
	if (t_cursor >= t_end || (*t_cursor != '"' && *t_cursor != '\''))
		return;
	t_quote = *t_cursor++;
	// [81] EncName ::= [A-Za-z] ([A-Za-z0-9._] | '-')*
	t_label_length = 0;
	while (t_cursor + t_label_length < t_end && t_cursor[t_label_length] != t_quote)
	{
		char c;
		c = t_cursor[t_label_length];
		if (!((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') ||
			  (t_label_length > 0 && ((c >= '0' && c <= '9') || c == '.' || c == '_' || c == '-'))))
			return;
		t_label_length++;
	}
	if (t_label_length == 0 || t_cursor + t_label_length >= t_end || t_label_length >= p_size)
		return;
	memcpy(r_label, t_cursor, t_label_length);
	r_label[t_label_length] = '\0';
}

// Whether 2.9 refused the encoding p_label ("Unsupported encoding"), as
//   far as libxml2 2.15 can tell: it cannot read it either, or it reads it
//   as UTF-16 by a name that 2.9 did not know ("Unicode", "csUnicode",
//   "UnicodeFFFE", "UnicodeFEFF"), which made garbage of 8-bit text.
static bool revxml_label_unsupported(const char *p_label)
{
	xmlCharEncoding t_encoding;
	xmlCharEncodingHandlerPtr t_handler;
	t_encoding = xmlParseCharEncoding(p_label);
	if (t_encoding == XML_CHAR_ENCODING_UTF16LE || t_encoding == XML_CHAR_ENCODING_UTF16BE)
		return xmlStrcasecmp((const xmlChar *)p_label, (const xmlChar *)"UTF-16") != 0 &&
			xmlStrcasecmp((const xmlChar *)p_label, (const xmlChar *)"UTF16") != 0 &&
			xmlStrcasecmp((const xmlChar *)p_label, (const xmlChar *)"UTF-16LE") != 0 &&
			xmlStrcasecmp((const xmlChar *)p_label, (const xmlChar *)"UTF-16BE") != 0;
	t_handler = NULL;
	if (xmlCreateCharEncodingHandler(p_label, XML_ENC_INPUT, NULL, NULL, &t_handler) == XML_ERR_UNSUPPORTED_ENCODING)
		return true;
	if (t_handler != NULL)
		xmlCharEncCloseFunc(t_handler);
	return false;
}

// How the document whose first p_length bytes are p_text is to be read
//   (r_head), as libxml2 2.9 read it.
static void revxml_head(const unsigned char *p_text, size_t p_length, RevXMLHead *r_head)
{
	size_t t_bom;
	memset(r_head, 0, sizeof(*r_head));
	r_head->kind = kRevXMLHeadDeclared;
	// UTF-16, UCS-4 and EBCDIC, which libxml2 finds from the first four
	//   bytes (xmlDetectEncoding) and reads as such whatever is declared.
	//   A UTF-16 byte order mark is found in a document of two bytes or
	//   three, as 2.9 found it.
	if (p_length >= 2)
	{
		const unsigned char *b = p_text;
		bool t_four;
		t_four = p_length >= 4;
		if ((b[0] == 0xFF && b[1] == 0xFE) || (t_four && b[0] == 0x3C && b[1] == 0x00 && b[2] == 0x3F && b[3] == 0x00))
		{
			r_head->utf16 = true;
			t_bom = b[0] == 0xFF ? 2 : 0;
			revxml_head_label(p_text + t_bom, p_length - t_bom, 2, 0, r_head->label, sizeof(r_head->label));
			if (r_head->label[0] != '\0' && revxml_label_unsupported(r_head->label))
				r_head->kind = kRevXMLHeadUnsupported;
			return;
		}
		if ((b[0] == 0xFE && b[1] == 0xFF) || (t_four && b[0] == 0x00 && b[1] == 0x3C && b[2] == 0x00 && b[3] == 0x3F))
		{
			r_head->utf16 = true;
			t_bom = b[0] == 0xFE ? 2 : 0;
			revxml_head_label(p_text + t_bom, p_length - t_bom, 2, 1, r_head->label, sizeof(r_head->label));
			if (r_head->label[0] != '\0' && revxml_label_unsupported(r_head->label))
				r_head->kind = kRevXMLHeadUnsupported;
			return;
		}
		if (t_four && ((b[0] == 0x00 && b[1] == 0x00 && b[2] == 0x00 && b[3] == 0x3C) ||
					   (b[0] == 0x3C && b[1] == 0x00 && b[2] == 0x00 && b[3] == 0x00) ||
					   (b[0] == 0x4C && b[1] == 0x6F && b[2] == 0xA7 && b[3] == 0x94)))
			return;
	}
	t_bom = (p_length >= 3 && p_text[0] == 0xEF && p_text[1] == 0xBB && p_text[2] == 0xBF) ? 3 : 0;
	revxml_head_label(p_text + t_bom, p_length - t_bom, 1, 0, r_head->label, sizeof(r_head->label));
	if (r_head->label[0] == '\0' || xmlParseCharEncoding(r_head->label) == XML_CHAR_ENCODING_UTF8)
		r_head->kind = kRevXMLHeadUTF8;
	else if (xmlStrcasecmp((const xmlChar *)r_head->label, (const xmlChar *)"UTF-16") == 0 ||
			 xmlStrcasecmp((const xmlChar *)r_head->label, (const xmlChar *)"UTF16") == 0)
	{
		r_head->kind = kRevXMLHeadUTF8;
		r_head->label16 = true;
	}
	else if (revxml_label_unsupported(r_head->label))
		r_head->kind = kRevXMLHeadUnsupported;
	// After a UTF-8 BOM, libxml2 2.15 reads UTF-8 whatever else is declared.
}

// The first bytes of the file p_filename, read as the parse reads them (a
//   gzip-compressed file uncompressed), for revxml_head. Returns false when
//   there is nothing to look at: the file cannot be read (the parse says
//   why), or it is not a local file.
static bool revxml_file_head(const char *p_filename, RevXMLHead *r_head)
{
	xmlParserInputPtr t_input;
	const char *t_scheme;
	memset(r_head, 0, sizeof(*r_head));
	r_head->kind = kRevXMLHeadDeclared;
	t_scheme = strstr(p_filename, "://");
	if (t_scheme != NULL && !(t_scheme - p_filename == 4 && xmlStrncasecmp((const xmlChar *)p_filename, (const xmlChar *)"file", 4) == 0))
		return false;
	t_input = NULL;
	if (xmlNewInputFromUrl(p_filename, XML_INPUT_UNZIP, &t_input) != XML_ERR_OK || t_input == NULL)
		return false;
	xmlParserInputGrow(t_input, 4000);
	revxml_head(t_input->base, (size_t)(t_input->end - t_input->base), r_head);
	xmlFreeInputStream(t_input);
	return true;
}

// The text p_text (p_length bytes) of a document in memory with a marker
//   for each byte that is not UTF-8, in a new NUL-terminated buffer
//   (r_length bytes); or NULL when it is all UTF-8, or when it holds
//   characters that read as markers (they could not be told apart).
static unsigned char *revxml_native_text(RevXMLParse *p_parse, const unsigned char *p_text, size_t p_length, size_t *r_length)
{
	size_t t_invalid, t_size, t_in, t_out;
	unsigned char *t_decoded;
	t_invalid = 0;
	for (size_t i = 0; i < p_length;)
	{
		int t_char;
		t_char = revxml_utf8_check(p_text + i, p_length - i);
		if (t_char <= 0)
		{
			t_invalid++;
			i++;
		}
		else if (revxml_marker_at(p_text + i, p_length - i))
			return NULL;
		else
			i += t_char;
	}
	if (t_invalid == 0 || t_invalid > (SIZE_MAX - 1 - p_length) / (REVXML_MARKER_LENGTH - 1))
		return NULL;
	t_size = p_length + (REVXML_MARKER_LENGTH - 1) * t_invalid;
	t_decoded = (unsigned char *)malloc(t_size + 1);
	if (t_decoded == NULL)
		return NULL;
	t_in = p_length;
	t_out = t_size;
	revxml_native_decode(p_parse, p_text, &t_in, t_decoded, &t_out, true);
	t_decoded[t_out] = '\0';
	*r_length = t_out;
	return t_decoded;
}

// Sends p_text (p_length bytes) in a revStartXMLData message, its markers
//   turned back into bytes.
static void revxml_text_send(RevXMLParse *p_parse, const xmlChar *p_text, size_t p_length)
{
	xmlChar *t_copy;
	size_t t_length;
	t_copy = NULL;
	if (p_parse != NULL && p_parse->native)
		t_copy = revxml_unmark(p_text, p_length, &t_length);
	if (t_copy != NULL)
	{
		CB_elementData((const char *)t_copy, (int)t_length);
		xmlFree(t_copy);
	}
	else
		CB_elementData((const char *)p_text, (int)p_length);
}

// Keeps p_text (p_length bytes) back with the text kept before it. Returns
//   false when it cannot (no memory, or more than one message can hold).
static bool revxml_text_keep(RevXMLParse *p_parse, const xmlChar *p_text, size_t p_length)
{
	if (p_length > INT_MAX - p_parse->text_length)
		return false;
	if (p_length > p_parse->text_capacity - p_parse->text_length)
	{
		size_t t_capacity;
		xmlChar *t_text;
		t_capacity = p_parse->text_capacity < 1024 ? 1024 : p_parse->text_capacity;
		while (t_capacity < p_parse->text_length + p_length)
			t_capacity *= 2;
		t_text = (xmlChar *)realloc(p_parse->text, t_capacity);
		if (t_text == NULL)
			return false;
		p_parse->text = t_text;
		p_parse->text_capacity = t_capacity;
	}
	memcpy(p_parse->text + p_parse->text_length, p_text, p_length);
	p_parse->text_length += p_length;
	return true;
}

// Sends the native text of a run that is kept back in pieces cut as 2.9
//   cut them: each at least REVXML_TEXT_CHUNK bytes, a native byte counting
//   as one. With p_all, sends the rest of the run too.
static void revxml_text_send_run(RevXMLParse *p_parse, bool p_all)
{
	size_t t_start, t_count, i;
	t_start = 0;
	t_count = 0;
	i = 0;
	while (i < p_parse->text_length)
	{
		const xmlChar *t_char;
		size_t t_available;
		t_char = p_parse->text + i;
		t_available = p_parse->text_length - i;
		if (revxml_marker_at(t_char, t_available))
		{
			i += REVXML_MARKER_LENGTH;
			t_count += 1;
		}
		else
		{
			int t_length;
			t_length = revxml_utf8_check(t_char, t_available);
			i += t_length > 0 ? t_length : 1;
			t_count += t_length > 0 ? t_length : 1;
		}
		if (t_count >= REVXML_TEXT_CHUNK)
		{
			revxml_text_send(p_parse, p_parse->text + t_start, i - t_start);
			t_start = i;
			t_count = 0;
		}
	}
	if (p_all && i > t_start)
	{
		revxml_text_send(p_parse, p_parse->text + t_start, i - t_start);
		t_start = i;
	}
	memmove(p_parse->text, p_parse->text + t_start, p_parse->text_length - t_start);
	p_parse->text_length -= t_start;
}

// Sends the text kept back, before any other message.
static void revxml_text_flush(RevXMLParse *p_parse)
{
	if (p_parse == NULL || p_parse->text_kind == kRevXMLTextNone)
		return;
	if (p_parse->text_kind == kRevXMLTextHeld)
		revxml_text_send(p_parse, p_parse->text, p_parse->text_length);
	else
		revxml_text_send_run(p_parse, true);
	p_parse->text_kind = kRevXMLTextNone;
	p_parse->text_length = 0;
}

// Whether libxml2 cut a run of text that goes on: it cuts a run that is
//   not ASCII after REVXML_TEXT_CHUNK bytes, and the run ends at '<' or '&'.
static bool revxml_text_run_goes_on(RevXMLParse *p_parse, size_t p_length)
{
	xmlParserInputPtr t_input;
	t_input = p_parse->ctxt->input;
	return p_length >= REVXML_TEXT_CHUNK && t_input != NULL && t_input->cur < t_input->end &&
		*t_input->cur != '<' && *t_input->cur != '&';
}

// The text of a characters message (or of a CDATA section, p_cdata), as
//   revStartXMLData messages cut where 2.9 cut them. 2.9 parsed a document
//   in memory all at once, so it cut a run of ASCII text only where the run
//   ended (2.15 reads 4000 bytes at a time, from memory too when it has to
//   decode it), and native text every 300 bytes or so, counting each native
//   byte as one (2.15 counts the four bytes of its marker).
void revxml_sax_text(void *p_context, const xmlChar *p_text, int p_length, bool p_cdata)
{
	RevXMLParse *t_parse;
	xmlParserInputPtr t_input;
	size_t t_length;
	bool t_ascii;
	t_parse = revxml_parse_for(p_context);
	if (t_parse == NULL || p_length < 0)
	{
		CB_elementData((const char *)p_text, p_length);
		return;
	}
	t_length = (size_t)p_length;
	t_input = t_parse->ctxt->input;
	// libxml2 passes a run of ASCII text straight from its buffer, having
	//   moved past it. 2.9 sent such runs even when an error had stopped its
	//   other messages.
	t_ascii = !p_cdata && t_input != NULL && p_text + t_length == t_input->cur;

	if (t_parse->text_kind == kRevXMLTextHeld)
	{
		if (t_ascii && t_input == t_parse->text_input &&
			(size_t)t_input->consumed + (size_t)(p_text - t_input->base) == t_parse->text_end &&
			revxml_text_keep(t_parse, p_text, t_length))
		{
			t_parse->text_end += t_length;
			if (t_input->cur != t_input->end)
				revxml_text_flush(t_parse);
			return;
		}
		revxml_text_flush(t_parse);
	}
	else if (t_parse->text_kind == kRevXMLTextRun)
	{
		if (!p_cdata && !t_ascii)
		{
			// The next part of the run.
			bool t_goes_on;
			if (!revxml_parse_sending(t_parse))
			{
				t_parse->text_kind = kRevXMLTextNone;
				t_parse->text_length = 0;
				return;
			}
			t_goes_on = revxml_text_run_goes_on(t_parse, t_length);
			if (revxml_text_keep(t_parse, p_text, t_length))
			{
				revxml_text_send_run(t_parse, !t_goes_on);
				if (!t_goes_on)
					t_parse->text_kind = kRevXMLTextNone;
				return;
			}
		}
		revxml_text_flush(t_parse);
	}

	if (t_ascii)
	{
		if (t_parse->hold && t_input->cur == t_input->end && revxml_text_keep(t_parse, p_text, t_length))
		{
			t_parse->text_kind = kRevXMLTextHeld;
			t_parse->text_input = t_input;
			t_parse->text_end = (size_t)t_input->consumed + (size_t)(t_input->cur - t_input->base);
			return;
		}
		revxml_text_send(t_parse, p_text, t_length);
		return;
	}
	if (!revxml_parse_sending(t_parse))
		return;
	if (!p_cdata && t_parse->native && revxml_text_run_goes_on(t_parse, t_length) &&
		revxml_text_keep(t_parse, p_text, t_length))
	{
		t_parse->text_kind = kRevXMLTextRun;
		revxml_text_send_run(t_parse, false);
		return;
	}
	revxml_text_send(t_parse, p_text, t_length);
}

// A start tag's revStartXMLNode message, its markers turned back into
//   bytes.
void revxml_sax_start_element(void *p_context, const xmlChar *p_name, const xmlChar **p_attributes)
{
	RevXMLParse *t_parse;
	size_t t_count;
	xmlChar **t_copies;
	const char **t_strings;
	t_parse = revxml_parse_for(p_context);
	revxml_text_flush(t_parse);
	if (!revxml_parse_sending(t_parse))
		return;
	if (t_parse == NULL || !t_parse->native)
	{
		CB_startElement((const char *)p_name, (const char **)p_attributes);
		return;
	}
	// The name, then the attributes' names and values.
	t_count = 1;
	if (p_attributes != NULL)
		while (p_attributes[t_count - 1] != NULL)
			t_count++;
	t_copies = (xmlChar **)calloc(t_count, sizeof(xmlChar *));
	t_strings = (const char **)calloc(t_count + 1, sizeof(const char *));
	if (t_copies == NULL || t_strings == NULL)
	{
		free(t_copies);
		free(t_strings);
		CB_startElement((const char *)p_name, (const char **)p_attributes);
		return;
	}
	for (size_t i = 0; i < t_count; i++)
	{
		const xmlChar *t_string;
		size_t t_length;
		t_string = i == 0 ? p_name : p_attributes[i - 1];
		t_copies[i] = revxml_unmark(t_string, strlen((const char *)t_string), &t_length);
		t_strings[i] = (const char *)(t_copies[i] != NULL ? t_copies[i] : t_string);
	}
	CB_startElement(t_strings[0], p_attributes != NULL ? t_strings + 1 : NULL);
	for (size_t i = 0; i < t_count; i++)
		xmlFree(t_copies[i]);
	free(t_copies);
	free(t_strings);
}

// An end tag's revEndXMLNode message, its markers turned back into bytes.
void revxml_sax_end_element(void *p_context, const xmlChar *p_name)
{
	RevXMLParse *t_parse;
	xmlChar *t_copy;
	size_t t_length;
	t_parse = revxml_parse_for(p_context);
	revxml_text_flush(t_parse);
	if (!revxml_parse_sending(t_parse))
		return;
	t_copy = NULL;
	if (t_parse != NULL && t_parse->native)
		t_copy = revxml_unmark(p_name, strlen((const char *)p_name), &t_length);
	CB_endElement((const char *)(t_copy != NULL ? t_copy : p_name));
	xmlFree(t_copy);
}

// Notes how far the parse has got. When bad data is parsed, 2.9 found the
//   document not well-formed at the byte it refused, and from there on
//   dropped every entity reference in text ("Tom &amp; Jerry" after a
//   native character read "Tom  Jerry"), as libxml2 2.15 still does after
//   an error. A strict parse is refused anyway, and its message depends
//   on the errors that libxml2 reports only while the document is
//   well-formed.
void revxml_parse_note_position(void *p_context)
{
	RevXMLParse *t_parse;
	t_parse = revxml_parse_for(p_context);
	if (t_parse == NULL || t_parse->strict || !t_parse->refused || t_parse->passed)
		return;
	if (revxml_parse_position(t_parse) > t_parse->refused_offset)
	{
		t_parse->passed = true;
		t_parse->ctxt->wellFormed = 0;
	}
}

// The character reference that the parser has just read, if it has: its
//   value and whether it is hexadecimal. libxml2 gives the character to
//   the characters handler from a buffer of its own, past the ';'. Text
//   cannot end in a whole reference, as text ends at '&'.
static bool revxml_char_ref_read(xmlParserInputPtr p_input, int *r_value, bool *r_hex)
{
	const xmlChar *t_end, *t_digits;
	bool t_hex;
	int t_value;
	if (p_input == NULL || p_input->base == NULL || p_input->cur == NULL)
		return false;
	t_end = p_input->cur - 1;
	if (t_end - p_input->base < 3 || *t_end != ';')
		return false;
	t_digits = t_end;
	while (t_digits > p_input->base && t_end - t_digits < 32 &&
		   ((t_digits[-1] >= '0' && t_digits[-1] <= '9') || (t_digits[-1] >= 'a' && t_digits[-1] <= 'f') ||
			(t_digits[-1] >= 'A' && t_digits[-1] <= 'F')))
		t_digits--;
	if (t_digits == t_end || t_digits - p_input->base < 2)
		return false;
	t_hex = t_digits[-1] == 'x' || t_digits[-1] == 'X';
	if (t_hex ? (t_digits - p_input->base < 3 || t_digits[-2] != '#' || t_digits[-3] != '&')
			  : (t_digits[-1] != '#' || t_digits[-2] != '&'))
		return false;
	t_value = 0;
	for (const xmlChar *t_digit = t_digits; t_digit < t_end; t_digit++)
	{
		int t_number;
		if (*t_digit >= '0' && *t_digit <= '9')
			t_number = *t_digit - '0';
		else if (t_hex)
			t_number = (*t_digit | 0x20) - 'a' + 10;
		else
			return false;
		t_value = t_value * (t_hex ? 16 : 10) + t_number;
		if (t_value > 0x10FFFF)
			return false;
	}
	*r_value = t_value;
	*r_hex = t_hex;
	return true;
}

// The characters of a character reference in text, after the byte 2.9
//   refused, when bad data is parsed: 2.9 read the rest as ISO-8859-1, so
//   a reference to U+0080...U+00FF gave that byte, native text like the
//   bytes round it, and one past U+00FF an entity reference ("&#x263A;"
//   stays in revXMLText; revXMLNodeContents and the messages leave it
//   out). libxml2 2.15 gives the character in UTF-8. Returns false when
//   *x_text is to be such a reference's name; else *x_text and *x_length
//   are the text, the byte's marker for a byte.
bool revxml_parse_char_ref(void *p_context, const xmlChar **x_text, int *x_length)
{
	RevXMLParse *t_parse;
	int t_value, t_length;
	bool t_hex;
	t_parse = revxml_parse_for(p_context);
	if (t_parse == NULL || !t_parse->passed || *x_length < 2)
		return true;
	t_length = *x_length;
	if (!revxml_char_ref_read(t_parse->ctxt->input, &t_value, &t_hex) || t_value < 0x80 ||
		xmlGetUTF8Char(*x_text, &t_length) != t_value || t_length != *x_length)
		return true;
	if (t_value <= 0xFF)
	{
		revxml_marker_write((unsigned char)t_value, t_parse->char_ref);
		*x_text = t_parse->char_ref;
		*x_length = REVXML_MARKER_LENGTH;
		return true;
	}
	snprintf((char *)t_parse->char_ref, sizeof(t_parse->char_ref), t_hex ? "#x%X" : "#%d", t_value);
	*x_text = t_parse->char_ref;
	return false;
}

// Notes an error or warning of the parse, which replaces any message 2.9
//   would have given before it.
void revxml_parse_note_error(void *p_context)
{
	RevXMLParse *t_parse;
	t_parse = revxml_parse_for(p_context);
	if (t_parse == NULL)
		return;
	t_parse->error_seen = true;
	if (t_parse->refused && revxml_parse_position(t_parse) > t_parse->refused_offset)
		t_parse->error_after_refusal = true;
}

// After a parse: 2.9's refusals of a well-formed parse, the tree's markers
//   turned back into bytes, the document's encoding as 2.9 named it, and
//   the error message's markers.
static xmlDocPtr revxml_parse_finish(RevXMLParse *p_parse, const RevXMLHead *p_head, bool p_decoded, xmlDocPtr p_doc, char *x_error, size_t p_error_size)
{
	if (p_parse->strict && (p_parse->refused || p_parse->label16))
	{
		if (p_doc != NULL)
			xmlFreeDoc(p_doc);
		p_doc = NULL;
		// 2.9 went on parsing after the error, so a later error replaced
		//   its message.
		if (p_parse->refused)
		{
			if (!p_parse->error_after_refusal)
			{
				unsigned char t_bytes[4];
				memset(t_bytes, 0, sizeof(t_bytes));
				memcpy(t_bytes, p_parse->refused_bytes, p_parse->refused_count);
				snprintf(x_error, p_error_size, "Input is not proper UTF-8, indicate encoding !\nBytes: 0x%02X 0x%02X 0x%02X 0x%02X\n",
						 t_bytes[0], t_bytes[1], t_bytes[2], t_bytes[3]);
			}
		}
		else if (!p_parse->error_seen)
			snprintf(x_error, p_error_size, "Document labelled UTF-16 but has UTF-8 content\n");
	}
	else if (p_parse->strict && p_doc == NULL && !p_head->utf16 &&
			 (xmlStrcasecmp((const xmlChar *)p_head->label, (const xmlChar *)"UTF-16LE") == 0 ||
			  xmlStrcasecmp((const xmlChar *)p_head->label, (const xmlChar *)"UTF-16BE") == 0))
	{
		// 8-bit text labelled UTF-16LE or UTF-16BE, which both read as
		//   UTF-16 from the declaration on. libxml2 2.15 stops at the
		//   declaration; 2.9 went on, and its last error was this.
		snprintf(x_error, p_error_size, "Start tag expected, '<' not found\n");
	}
	if (p_doc != NULL)
	{
		const char *t_encoding;
		bool t_rename;
		if (p_parse->native)
			revxml_unmark_nodes(p_doc, p_doc->children, (xmlNodePtr)p_doc);
		// The encoding the document declared, which 2.9 named it by
		//   (revXMLText writes the document in it), not the decoder libxml2
		//   2.15 read it with: 8-bit text labelled UTF-16, and UTF-16 that
		//   declares an encoding (2.15 names it by its byte order mark, so
		//   revXMLText of UTF-16 that declared UTF-8 gave one character),
		//   for an encoding it can write.
		t_encoding = p_head->label[0] != '\0' ? p_head->label : NULL;
		t_rename = p_decoded || p_head->label16;
		if (p_head->utf16 && t_encoding != NULL)
		{
			xmlCharEncodingHandlerPtr t_handler;
			if (xmlOpenCharEncodingHandler(t_encoding, 1, &t_handler) == XML_ERR_OK)
			{
				xmlCharEncCloseFunc(t_handler);
				t_rename = true;
			}
		}
		if (t_rename)
		{
			xmlFree((xmlChar *)p_doc->encoding);
			p_doc->encoding = t_encoding != NULL ? xmlStrdup((const xmlChar *)t_encoding) : NULL;
		}
	}
	if (p_parse->native)
		revxml_unmark_in_place(x_error);
	return p_doc;
}

// Whether 2.9 sent a start of document message here.
bool revxml_sax_sending(void *p_context)
{
	return revxml_parse_sending(revxml_parse_for(p_context));
}

// Sends the text kept back, before the end of the document.
void revxml_sax_flush(void *p_context)
{
	revxml_text_flush(revxml_parse_for(p_context));
}

// Parses p_data (p_length bytes, a C string) or, when it is NULL, the file
//   p_filename, with p_ctxt and p_options, as libxml2 2.9 read them (see
//   the top of this file): with markers for native text, refusing an
//   encoding that libxml2 cannot read, and reading 8-bit text labelled
//   UTF-16 as UTF-8. p_strict refuses what 2.9 refused when bad data was not
//   parsed; p_messages is whether SAX messages are sent. Returns the
//   document, or NULL with the error in r_error.
xmlDocPtr revxml_parse(xmlParserCtxtPtr p_ctxt, const char *p_data, unsigned long p_length, const char *p_filename,
					   int p_options, bool p_strict, bool p_messages, char *r_error, size_t p_error_size)
{
	RevXMLHead t_head;
	RevXMLParse t_parse;
	unsigned char *t_decoded;
	bool t_decoder;
	xmlDocPtr t_doc;

	memset(&t_head, 0, sizeof(t_head));
	t_head.kind = kRevXMLHeadDeclared;
	if (p_data != NULL)
		revxml_head((const unsigned char *)p_data, p_length, &t_head);
	else
		revxml_file_head(p_filename, &t_head);
	if (t_head.kind == kRevXMLHeadUnsupported)
	{
		// 2.9 stopped at the declaration, before any SAX message. It found
		//   a handler for HTML, which writes HTML but cannot read it.
		if (xmlStrcasecmp((const xmlChar *)t_head.label, (const xmlChar *)"HTML") == 0)
			snprintf(r_error, p_error_size, "switching encoding: encoder error\n");
		else
			snprintf(r_error, p_error_size, "Unsupported encoding %s\n", t_head.label);
		return NULL;
	}

	memset(&t_parse, 0, sizeof(t_parse));
	t_parse.ctxt = p_ctxt;
	t_parse.strict = p_strict;
	t_parse.label16 = t_head.label16;
	// The label was 2.9's first error, so when strict it sent no SAX
	//   messages from the start.
	t_parse.stopped = p_strict && t_head.label16;
	t_parse.previous = s_revxml_parse;
	s_revxml_parse = &t_parse;
	xmlCtxtSetCharEncConvImpl(p_ctxt, revxml_find_encoding, &t_parse);

	t_decoded = NULL;
	t_decoder = false;
	if (p_data != NULL)
	{
		const char *t_text;
		size_t t_length;
		const char *t_encoding;
		t_text = p_data;
		t_length = p_length;
		t_encoding = NULL;
		if (t_head.kind == kRevXMLHeadUTF8)
		{
			t_decoded = revxml_native_text(&t_parse, (const unsigned char *)p_data, p_length, &t_length);
			if (t_decoded != NULL)
				t_text = (const char *)t_decoded;
			else
				t_length = p_length;
			if (t_head.label16)
				t_encoding = "UTF-8";
		}
		// A C string is parsed whole, as 2.9 parsed memory, so that a run
		//   of text arrives in one characters message: libxml2 2.15 reads
		//   other memory 4000 bytes at a time. Text it has to decode still
		//   comes in parts, which are held together.
		t_parse.hold = p_messages;
		if (t_text[t_length] == '\0' && memchr(t_text, '\0', t_length) == NULL)
			t_doc = xmlCtxtReadDoc(p_ctxt, (const xmlChar *)t_text, NULL, t_encoding, p_options);
		else
			t_doc = xmlCtxtReadMemory(p_ctxt, t_text, (int)t_length, NULL, t_encoding, p_options);
	}
	else
	{
		// A file is decoded as it is read, with markers for its bytes that
		//   are not UTF-8, unless it declares another encoding.
		const char *t_encoding;
		t_encoding = NULL;
		if (t_head.kind == kRevXMLHeadUTF8)
		{
			t_encoding = kRevXMLNativeEncoding;
			t_decoder = true;
		}
		t_doc = xmlCtxtReadFile(p_ctxt, p_filename, t_encoding, p_options);
	}
	revxml_text_flush(&t_parse);
	t_doc = revxml_parse_finish(&t_parse, &t_head, t_decoder, t_doc, r_error, p_error_size);

	s_revxml_parse = t_parse.previous;
	free(t_parse.text);
	free(t_decoded);
	return t_doc;
}
