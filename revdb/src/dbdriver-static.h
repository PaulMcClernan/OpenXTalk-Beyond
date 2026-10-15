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

/* The names of revDB and of a database driver that is linked into a program
 * with others: the web engine links revDB and its SQLite driver into itself
 * (engine/src/em-externals.cpp). It is libexternal's external-static.h, for
 * the copy of libexternal that each one has, and these names besides.
 *
 * revDB and each driver build in their own copy of the code they share
 * (database.cpp, dbdrivercommon.cpp, and the inline functions of
 * dbdriver.h and dbdrivercommon.h), as a library of its own does, so that
 * each keeps its own state: DBObject::idcounter is the driver's own pointer
 * to revDB's counter (setidcounterref). Every source file of revDB, or of a
 * driver, is compiled with this file and EXTERNAL_STATIC_PREFIX set to its
 * name (revdb, dbsqlite), which turns each name into <prefix>_<name>. A
 * class is renamed whole, not only its out-of-line members: an inline
 * function of a class of one copy would otherwise stand for the same
 * function of the other, and the linker keeps only one of them. */

#ifndef __DBDRIVER_STATIC_H__
#define __DBDRIVER_STATIC_H__

#include "external-static.h"

/* revDB's support code has a strclone of its own, a macro (unxsupport.cpp) */
#undef strclone

/* revDB's own support functions (unxsupport.cpp), which the engine
 * declares too (osspec.h) */
#define MCU_path2std EXTERNAL_STATIC_NAME(MCU_path2std)
#define MCU_path2native EXTERNAL_STATIC_NAME(MCU_path2native)
#define MCU_fix_path EXTERNAL_STATIC_NAME(MCU_fix_path)
#define MCS_getcurdir EXTERNAL_STATIC_NAME(MCS_getcurdir)
#define MCS_resolvepath EXTERNAL_STATIC_NAME(MCS_resolvepath)

/* The classes and functions of dbdriver.h and dbdrivercommon.h */
#define DBObject EXTERNAL_STATIC_NAME(DBObject)
#define DBList EXTERNAL_STATIC_NAME(DBList)
#define DBConnection EXTERNAL_STATIC_NAME(DBConnection)
#define DBConnection2 EXTERNAL_STATIC_NAME(DBConnection2)
#define DBCursor EXTERNAL_STATIC_NAME(DBCursor)
#define DBCursor2 EXTERNAL_STATIC_NAME(DBCursor2)
#define DBCursor3 EXTERNAL_STATIC_NAME(DBCursor3)
#define DBString EXTERNAL_STATIC_NAME(DBString)
#define DBField EXTERNAL_STATIC_NAME(DBField)
#define DBBuffer EXTERNAL_STATIC_NAME(DBBuffer)
#define CDBConnection EXTERNAL_STATIC_NAME(CDBConnection)
#define CDBCursor EXTERNAL_STATIC_NAME(CDBCursor)
#define PlaceholderMap EXTERNAL_STATIC_NAME(PlaceholderMap)
#define QueryMetadata EXTERNAL_STATIC_NAME(QueryMetadata)
#define DBcallbacks EXTERNAL_STATIC_NAME(DBcallbacks)
#define longtostring EXTERNAL_STATIC_NAME(longtostring)
#define StrEscape EXTERNAL_STATIC_NAME(StrEscape)
#define StrSkipSpace EXTERNAL_STATIC_NAME(StrSkipSpace)
#define StrSkipWord EXTERNAL_STATIC_NAME(StrSkipWord)
#define StrNextWordIs EXTERNAL_STATIC_NAME(StrNextWordIs)
#define StrCopyWord EXTERNAL_STATIC_NAME(StrCopyWord)
#define parse_data EXTERNAL_STATIC_NAME(parse_data)
#define parse_value EXTERNAL_STATIC_NAME(parse_value)
#define DBNullValue EXTERNAL_STATIC_NAME(DBNullValue)

/* What revDB looks up in a driver (revdb.cpp) */
#define newdbconnectionref EXTERNAL_STATIC_NAME(newdbconnectionref)
#define releasedbconnectionref EXTERNAL_STATIC_NAME(releasedbconnectionref)
#define setidcounterref EXTERNAL_STATIC_NAME(setidcounterref)
#define setcallbacksref EXTERNAL_STATIC_NAME(setcallbacksref)

#endif
