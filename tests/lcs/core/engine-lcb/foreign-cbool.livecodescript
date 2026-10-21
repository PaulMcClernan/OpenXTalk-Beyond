script "CoreEngineExtensionsForeignCBool"
/*
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

-- A foreign handler that returns a CBool, a one-byte result, gives the
-- value the C function returned. The web engine wrote a small result as a
-- whole word, at the word boundary below its slot, so a CBool slot that was
-- not aligned to a word kept its old value and true read as false
-- (libfoundation/src/foundation-ffi-js.cpp); the desktop engines were never
-- affected. MCMemoryAllocate and MCDataCreateWithBytes are engine functions
-- that an extension binds to with "<builtin>", which the web engine finds
-- since engine/src/em-externals.cpp registers them.

on TestSetup
   TestSkipIfNot "lcb"

   TestLoadAuxiliaryExtension "_foreign_cbool"
end TestSetup

on TestForeignCBoolResult
   local tResults
   put TestForeignCBoolResults() into tResults
   TestDiagnostic "allocated:" && tResults[1] & ", created:" && tResults[2] & ", bytes:" && tResults[3]
   TestAssert "a CBool result of true reads as true (MCMemoryAllocate)", tResults[1] is true
   TestAssert "a CBool result of true reads as true (MCDataCreateWithBytes)", tResults[2] is true
   TestAssert "the Data made by the foreign call has its bytes", tResults[3] is 3
end TestForeignCBoolResult
