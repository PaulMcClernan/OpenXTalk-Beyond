/*
 * config.h for the libxml2 that OXT-Beyond builds with gyp.
 *
 * libxml2's own builds (CMake, meson) generate this file from
 * config.h.cmake.in; gyp runs no configure step, so this hand-written copy
 * answers the same questions for every platform the engine is built for.
 * Since 2.13 the list is short: libxml2 relies on C99 and POSIX or Win32
 * for everything else.
 */

#ifndef OXT_LIBXML_CONFIG_H
#define OXT_LIBXML_CONFIG_H

/* getentropy() seeds the hash tables against hash flooding: glibc has it
   from 2.25 (the Linux builds need at most 2.31), musl from 1.1.20, macOS
   from 10.12 (the oldest supported is 10.13). Windows uses BCryptGenRandom
   instead, and elsewhere libxml2 falls back to the time and an address.
   The test cannot ask for glibc (__GLIBC__): libxml.h includes this file
   before any system header, so nothing has defined that yet. */
#if (defined(__linux__) && !defined(__ANDROID__)) || defined(__APPLE__)
#define HAVE_DECL_GETENTROPY 1
#else
#define HAVE_DECL_GETENTROPY 0
#endif

/* glob() is used only by the test programs, which are not built. */
#define HAVE_DECL_GLOB 0

/* Asked for only by xmllint, which is not built: the library itself never
   maps files. Answered as config.h.cmake.in would. */
#if !defined(_WIN32) && !defined(__ANDROID__) && !defined(__EMSCRIPTEN__) && \
    !defined(TARGET_SUBPLATFORM_ANDROID)
#define HAVE_DECL_MMAP 1
#else
#define HAVE_DECL_MMAP 0
#endif

/* Has no effect here: threads.c builds its destructor only when
   LIBXML_STATIC is not defined, and libxml.gyp always defines it, so
   nothing frees libxml2's global parser state when revXML is unloaded. On
   Windows, revXML's DllMain calls xmlDllMain (LIBXML_STATIC_FOR_DLL),
   which frees the per-thread state. Answered as config.h.cmake.in would. */
#if defined(__GNUC__) || defined(__clang__)
#define HAVE_FUNC_ATTRIBUTE_DESTRUCTOR 1
#endif

#define HAVE_STDINT_H 1

/* Where the default XML catalog is looked for (file:///etc/xml/catalog),
   unless XML_CATALOG_FILES says otherwise. catalog.c needs it on every
   platform. On Windows libxml2 would turn that URL into the relative path
   etc\xml\catalog, which depends on the current folder (the
   defaultFolder), so the Windows build has an empty default catalog
   instead; XML_CATALOG_FILES still works there. (libxml2 2.9 looked for
   etc\catalog in the folder above the executable's.) */
#define XML_SYSCONFDIR "/etc"
#ifdef _WIN32
#define XML_XML_DEFAULT_CATALOG ""
#define XML_SGML_DEFAULT_CATALOG ""
#endif

/* HAVE_DLOPEN, HAVE_SHLLOAD: only for xmlmodule.c, which is not built
   (LIBXML_MODULES_ENABLED is off). HAVE_LIBREADLINE, HAVE_LIBHISTORY: only
   for xmllint, which is not built. XML_THREAD_LOCAL is left undefined, so
   libxml2 keeps its per-thread state with pthread keys or Win32 TLS, which
   every compiler the engine is built with supports. */

#endif
