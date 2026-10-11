script "CoreInterfaceSnapshot"
/*
Copyright (C) 2015 LiveCode Ltd.

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

on _TestImportScreenSnapshotFromRectHandler
    import snapshot from rectangle 100,100,500,400
    
    TestAssert "long id of new image is long id of it",  the long id of it is the long id of the last image
    TestAssertBroken "long id of image is it", it is the long id of the last image
end _TestImportScreenSnapshotFromRectHandler

on TestImportScreenSnapshotFromRectNoUI
   TestSkipIf "ui"
   TestSkipIf "platform", "HTML5"
   TestAssertThrow "should now throw an error", "_TestImportScreenSnapshotFromRectHandler",\
        the long id of me, "EE_SNAPSHOT_FAILED"
end TestImportScreenSnapshotFromRectNoUI

on TestImportScreenSnapshotFromRectUI
    TestSkipIfNot "ui"
    TestSkipIf "environment", "server"
    TestSkipIf "platform", "HTML5"

    _TestImportScreenSnapshotFromRectHandler
end TestImportScreenSnapshotFromRectUI

on _TestImportSnapshotFromStackHandler
    create stack "Untitled 1"

    import snapshot from window the windowId of stack "Untitled 1"
    TestAssert "long id of new image is long id of it",  the long id of it is the long id of the last image
    TestAssertBroken "long id of image is it", it is the long id of the last image
end _TestImportSnapshotFromStackHandler

on TestImportSnapshotFromStack
    if the environment is not "command line" then
        return "SKIP TEST"
    end if
    TestAssertThrow "should now throw an error", "_TestImportSnapshotFromStackHandler",\
        the long id of me, "EE_SNAPSHOT_FAILED"
end TestImportSnapshotFromStack

on TestImportSnapshotFromObject
    create button "b1"

    import snapshot from button "b1"

    TestAssert "long id of new image is long id of it",  the long id of it is the long id of the last image
    TestAssert "long id of image is it", it is the long id of the last image
end TestImportSnapshotFromObject

on TestImportSnapshotFromRectOfObject
   create field "field 1"
   set the rect of field "field 1" to 0,0,100,100
   
   import snapshot from rectangle 0,0,100,100 of field "field 1"
   TestAssert "long id of new image is long id of it",  the long id of it is the long id of the last image
   TestAssert "long id of image is it", it is the long id of the last image
end TestImportSnapshotFromRectOfObject


-- A group whose snapshot would take more than 4 GiB (here about 40,000
-- pixels square) used to crash the engine: the bitmap's size wrapped round
-- to a small buffer that drawing then wrote far past. Now the export and
-- the import throw instead.
private command _TestMakeHugeGroup
   -- The test stack is not open, so the images are made in the group
   -- rather than selected and grouped.
   create group "huge"
   create image "huge 1" in group "huge"
   set the rect of image "huge 1" to -20000,-20000,-19900,-19900
   create image "huge 2" in group "huge"
   set the rect of image "huge 2" to 19900,19900,20000,20000
end _TestMakeHugeGroup

on _TestExportHugeGroupHandler
   local tData
   export snapshot from group "huge" to tData as PNG
end _TestExportHugeGroupHandler

on _TestImportHugeGroupHandler
   import snapshot from group "huge"
end _TestImportHugeGroupHandler

on TestSnapshotOfHugeGroup
   _TestMakeHugeGroup
   TestAssert "the group is too big for a 4 GiB bitmap", \
         the width of group "huge" * the height of group "huge" > 2 ^ 30
   TestAssertThrow "export snapshot of a huge group throws", \
         "_TestExportHugeGroupHandler", the long id of me, "EE_SNAPSHOT_TOOBIG"
   TestAssertThrow "import snapshot of a huge group throws", \
         "_TestImportHugeGroupHandler", the long id of me, "EE_SNAPSHOT_TOOBIG"
end TestSnapshotOfHugeGroup
