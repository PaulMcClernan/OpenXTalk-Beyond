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

/* The names of libexternal for an external that is linked into a program
 * with others: the web engine, which links revXML, revZip and revDB into
 * itself because a browser loads no libraries (engine/src/em-externals.cpp).
 *
 * Every external has its own copy of libexternal: the copy keeps the
 * engine's callbacks and the external's handler table, and the engine looks
 * up getXtable and the others in each external. In a library of its own each
 * copy keeps these names to itself, but linked into one program the copies
 * would define the same names. So every source file of such an external,
 * its copy of libexternal's included, is compiled with this file
 * (-include external-static.h, found on the include path) and
 * EXTERNAL_STATIC_PREFIX set to the external's name, which turns each of
 * these names into <prefix>_<name>: getXtable of revXML is revxml_getXtable.
 *
 * The list is every name libexternal's sources define (external.c,
 * unxsupport.cpp) and the names its declaration macros define in the
 * external (revolution/external.h). */

#ifndef __EXTERNAL_STATIC_H__
#define __EXTERNAL_STATIC_H__

#ifndef EXTERNAL_STATIC_PREFIX
#error "EXTERNAL_STATIC_PREFIX must name the external"
#endif

#define __EXTERNAL_STATIC_JOIN(m_prefix, m_name) m_prefix ## _ ## m_name
#define __EXTERNAL_STATIC_NAME(m_prefix, m_name) __EXTERNAL_STATIC_JOIN(m_prefix, m_name)
#define EXTERNAL_STATIC_NAME(m_name) __EXTERNAL_STATIC_NAME(EXTERNAL_STATIC_PREFIX, m_name)

/* What the engine looks up in an external (engine/src/externalv0.cpp) */
#define getXtable EXTERNAL_STATIC_NAME(getXtable)
#define configureSecurity EXTERNAL_STATIC_NAME(configureSecurity)
#define setExternalInterfaceVersion EXTERNAL_STATIC_NAME(setExternalInterfaceVersion)
#define shutdownXtable EXTERNAL_STATIC_NAME(shutdownXtable)

/* What the declaration macros define in the external (with
 * EXTERNAL_STATIC_PREFIX set, EXTERNAL_REFERENCE_LIBRARY defines nothing) */
#define g_external_name EXTERNAL_STATIC_NAME(g_external_name)
#define g_external_table EXTERNAL_STATIC_NAME(g_external_table)

/* The external interface (external.c) */
#define SendCardMessage EXTERNAL_STATIC_NAME(SendCardMessage)
#define EvalExpr EXTERNAL_STATIC_NAME(EvalExpr)
#define GetGlobal EXTERNAL_STATIC_NAME(GetGlobal)
#define SetGlobal EXTERNAL_STATIC_NAME(SetGlobal)
#define GetFieldByName EXTERNAL_STATIC_NAME(GetFieldByName)
#define GetFieldByNum EXTERNAL_STATIC_NAME(GetFieldByNum)
#define GetFieldById EXTERNAL_STATIC_NAME(GetFieldById)
#define SetFieldByName EXTERNAL_STATIC_NAME(SetFieldByName)
#define SetFieldByNum EXTERNAL_STATIC_NAME(SetFieldByNum)
#define SetFieldById EXTERNAL_STATIC_NAME(SetFieldById)
#define ShowImageByName EXTERNAL_STATIC_NAME(ShowImageByName)
#define ShowImageByNum EXTERNAL_STATIC_NAME(ShowImageByNum)
#define ShowImageById EXTERNAL_STATIC_NAME(ShowImageById)
#define ShowImageByLongId EXTERNAL_STATIC_NAME(ShowImageByLongId)
#define GetVariable EXTERNAL_STATIC_NAME(GetVariable)
#define SetVariable EXTERNAL_STATIC_NAME(SetVariable)
#define GetVariableEx EXTERNAL_STATIC_NAME(GetVariableEx)
#define SetVariableEx EXTERNAL_STATIC_NAME(SetVariableEx)
#define GetArray EXTERNAL_STATIC_NAME(GetArray)
#define SetArray EXTERNAL_STATIC_NAME(SetArray)
#define SecurityCanAccessFile EXTERNAL_STATIC_NAME(SecurityCanAccessFile)
#define SecurityCanAccessHost EXTERNAL_STATIC_NAME(SecurityCanAccessHost)
#define SecurityCanAccessLibrary EXTERNAL_STATIC_NAME(SecurityCanAccessLibrary)
#define AddRunloopAction EXTERNAL_STATIC_NAME(AddRunloopAction)
#define RemoveRunloopAction EXTERNAL_STATIC_NAME(RemoveRunloopAction)
#define RunloopWait EXTERNAL_STATIC_NAME(RunloopWait)
#define StackToWindowRect EXTERNAL_STATIC_NAME(StackToWindowRect)
#define WindowToStackRect EXTERNAL_STATIC_NAME(WindowToStackRect)
#define SendCardMessageUTF8 EXTERNAL_STATIC_NAME(SendCardMessageUTF8)
#define EvalExprUTF8 EXTERNAL_STATIC_NAME(EvalExprUTF8)
#define GetGlobalUTF8 EXTERNAL_STATIC_NAME(GetGlobalUTF8)
#define SetGlobalUTF8 EXTERNAL_STATIC_NAME(SetGlobalUTF8)
#define GetFieldByNameUTF8 EXTERNAL_STATIC_NAME(GetFieldByNameUTF8)
#define GetFieldByNumUTF8 EXTERNAL_STATIC_NAME(GetFieldByNumUTF8)
#define GetFieldByIdUTF8 EXTERNAL_STATIC_NAME(GetFieldByIdUTF8)
#define SetFieldByNameUTF8 EXTERNAL_STATIC_NAME(SetFieldByNameUTF8)
#define SetFieldByNumUTF8 EXTERNAL_STATIC_NAME(SetFieldByNumUTF8)
#define SetFieldByIdUTF8 EXTERNAL_STATIC_NAME(SetFieldByIdUTF8)
#define ShowImageByNameUTF8 EXTERNAL_STATIC_NAME(ShowImageByNameUTF8)
#define ShowImageByNumUTF8 EXTERNAL_STATIC_NAME(ShowImageByNumUTF8)
#define ShowImageByIdUTF8 EXTERNAL_STATIC_NAME(ShowImageByIdUTF8)
#define ShowImageByLongIdUTF8 EXTERNAL_STATIC_NAME(ShowImageByLongIdUTF8)
#define GetVariableUTF8 EXTERNAL_STATIC_NAME(GetVariableUTF8)
#define SetVariableUTF8 EXTERNAL_STATIC_NAME(SetVariableUTF8)
#define GetVariableExUTF8 EXTERNAL_STATIC_NAME(GetVariableExUTF8)
#define SetVariableExUTF8 EXTERNAL_STATIC_NAME(SetVariableExUTF8)
#define GetArrayUTF8 EXTERNAL_STATIC_NAME(GetArrayUTF8)
#define SetArrayUTF8 EXTERNAL_STATIC_NAME(SetArrayUTF8)
#define SecurityCanAccessFileUTF8 EXTERNAL_STATIC_NAME(SecurityCanAccessFileUTF8)
#define SecurityCanAccessHostUTF8 EXTERNAL_STATIC_NAME(SecurityCanAccessHostUTF8)
#define SecurityCanAccessLibraryUTF8 EXTERNAL_STATIC_NAME(SecurityCanAccessLibraryUTF8)
#define LoadModuleByName EXTERNAL_STATIC_NAME(LoadModuleByName)
#define UnloadModule EXTERNAL_STATIC_NAME(UnloadModule)
#define ResolveSymbolInModule EXTERNAL_STATIC_NAME(ResolveSymbolInModule)
#define CopyNativePathOfModule EXTERNAL_STATIC_NAME(CopyNativePathOfModule)
#define GetXDisplayHandle EXTERNAL_STATIC_NAME(GetXDisplayHandle)
#define GetXScreenHandle EXTERNAL_STATIC_NAME(GetXScreenHandle)
#define ConvertCStringFromNativeToUTF8 EXTERNAL_STATIC_NAME(ConvertCStringFromNativeToUTF8)
#define ConvertCStringToNativeFromUTF8 EXTERNAL_STATIC_NAME(ConvertCStringToNativeFromUTF8)
/* The engine defines these for itself (engine/src/util.cpp) */
#define MCSupportLibraryLoad EXTERNAL_STATIC_NAME(MCSupportLibraryLoad)
#define MCSupportLibraryUnload EXTERNAL_STATIC_NAME(MCSupportLibraryUnload)
#define MCSupportLibraryLookupSymbol EXTERNAL_STATIC_NAME(MCSupportLibraryLookupSymbol)
#define MCSupportLibraryCopyNativePath EXTERNAL_STATIC_NAME(MCSupportLibraryCopyNativePath)

/* The support functions (revolution/support.h, unxsupport.cpp) */
#define string_from_utf16 EXTERNAL_STATIC_NAME(string_from_utf16)
#define string_to_utf8 EXTERNAL_STATIC_NAME(string_to_utf8)
#define os_path_to_native EXTERNAL_STATIC_NAME(os_path_to_native)
#define os_path_to_native_utf8 EXTERNAL_STATIC_NAME(os_path_to_native_utf8)
#define os_path_from_native EXTERNAL_STATIC_NAME(os_path_from_native)
#define os_path_resolve EXTERNAL_STATIC_NAME(os_path_resolve)
#define strclone EXTERNAL_STATIC_NAME(strclone)
#define get_current_directory EXTERNAL_STATIC_NAME(get_current_directory)

#endif
