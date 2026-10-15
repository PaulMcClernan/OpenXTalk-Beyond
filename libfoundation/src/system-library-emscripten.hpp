/*                                                                     -*-c++-*-
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

#include "system-private.h"

#include <foundation-auto.h>

/* ================================================================
 * Emscripten Handle Class
 * ================================================================ */

/* The __MCSLibraryHandleEmscripten class stands for one of two things. A
 * handle made with an address notionally represents the main executable,
 * in which it finds no symbols. A handle made with a native path is one of
 * the libraries that the web engine links into itself (a browser loads
 * none) and registers with MCSLibraryRegisterStatic: as on iOS
 * (system-library-static.hpp), the library is found by the name of its file
 * without the folder and the extension, so "<folder>/revxml.so" finds the
 * library registered as "revxml", and its symbols are those it registered.
 * OXT-Beyond: the registry is new; before it, a handle made with a path
 * was never made. */

#include <link.h>
#include <sys/stat.h>
#include <unistd.h>

class __MCSLibraryHandleEmscripten
{
public:
    __MCSLibraryHandleEmscripten(void)
    {
    }
    
    ~__MCSLibraryHandleEmscripten(void)
    {
        MCValueRelease(m_native_path);
    }
    
    bool IsDefined(void) const
    {
        return m_defined;
    }
    
    bool IsEqualTo(const __MCSLibraryHandleEmscripten& p_other) const
    {
        return m_static != nullptr &&
               m_static == p_other.m_static;
    }
    
    hash_t Hash(void) const
    {
        return MCHashPointer(m_static);
    }
    
    bool CreateWithNativePath(MCStringRef p_native_path)
    {
        /* The leaf name: the path without the folder and the extension */
        uindex_t t_last_separator = 0;
        if (MCStringLastIndexOfChar(p_native_path,
                                    '/',
                                    UINDEX_MAX,
                                    kMCStringOptionCompareExact,
                                    t_last_separator))
        {
            t_last_separator += 1;
        }
        
        uindex_t t_first_extension = 0;
        if (!MCStringFirstIndexOfChar(p_native_path,
                                      '.',
                                      t_last_separator,
                                      kMCStringOptionCompareExact,
                                      t_first_extension))
        {
            t_first_extension = UINDEX_MAX;
        }
        
        MCAutoStringRef t_leaf_name;
        if (!MCStringCopySubstring(p_native_path,
                                   MCRangeMakeMinMax(t_last_separator,
                                                     t_first_extension),
                                   &t_leaf_name))
        {
            return false;
        }
        
        for(const MCSLibraryStaticInfo *t_info = s_chain;
            t_info != nullptr;
            t_info = t_info->__next)
        {
            if (MCStringIsEqualToCString(*t_leaf_name,
                                         t_info->name,
                                         kMCStringOptionCompareCaseless))
            {
                m_static = t_info;
                m_native_path = MCValueRetain(p_native_path);
                m_defined = true;
                return true;
            }
        }
        
        return __MCSLibraryThrowCreateWithNativePathFailed(p_native_path,
                                                           nullptr);
    }
    
    bool CreateWithAddress(void *p_address)
    {
        m_defined = true;
        return true;
    }
    
    void *LookupSymbol(MCStringRef p_symbol) const
    {
        if (m_static == nullptr)
        {
            return nullptr;
        }
        
        for(size_t i = 0; m_static->exports[i].symbol != nullptr; i++)
        {
            if (MCStringIsEqualToCString(p_symbol,
                                         m_static->exports[i].symbol,
                                         kMCStringOptionCompareExact))
            {
                return m_static->exports[i].address;
            }
        }
        
        return nullptr;
    }
    
    bool CopyNativePath(MCStringRef& r_native_path) const
    {
        if (m_native_path != nullptr)
        {
            r_native_path = MCValueRetain(m_native_path);
            return true;
        }
        
        return MCStringCreateWithCString("<main>", r_native_path);
    }
    
    static void Register(MCSLibraryStaticInfo& p_info)
    {
        /* A library registered twice would make the chain a loop */
        for(const MCSLibraryStaticInfo *t_info = s_chain;
            t_info != nullptr;
            t_info = t_info->__next)
        {
            if (t_info == &p_info)
            {
                return;
            }
        }
        
        p_info.__next = s_chain;
        s_chain = &p_info;
    }

private:
    bool m_defined = false;
    /* The registered library, if it is one */
    const MCSLibraryStaticInfo *m_static = nullptr;
    /* The path it was found by */
    MCStringRef m_native_path = nullptr;
    
    static MCSLibraryStaticInfo *s_chain;
};

MCSLibraryStaticInfo *__MCSLibraryHandleEmscripten::s_chain = nullptr;

typedef class __MCSLibraryHandleEmscripten __MCSLibraryHandle;
