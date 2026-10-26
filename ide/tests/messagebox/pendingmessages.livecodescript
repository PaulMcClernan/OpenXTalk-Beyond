script "MessageBoxPendingMessages"
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

-- The Pending Messages card lays every row out to the Message Box's width
-- when it opens with another stack the defaultStack, as it does from the
-- menu (openxtalk.org p=25450): before, every row after the first kept
-- its message field at the template's width, cut off until the Message
-- Box was resized.
on TestPendingMessagesRowsLaidOut
   local tStack, tStackName, tButton, tMB, tTemplateWidth, tRows, tGroup
   local tMessages, tMessage, i

   create stack
   put it into tStack
   put the short name of tStack into tStackName
   set the defaultStack to tStackName
   create button
   put the long id of it into tButton
   set the script of tButton to "on oxtTestPending" & return & "end oxtTestPending"
   send "oxtTestPending" to tButton in 60 seconds
   put the result & return after tMessages
   send "oxtTestPending" to tButton in 60 seconds
   put the result & return after tMessages

   revIDEOpenPalette "message box"
   put revIDEPaletteToStackName("message box") into tMB
   set the defaultStack to tStackName
   dispatch "showCard" to stack tMB with "Pending Messages"

   put the width of field "message" of group "pendingMessagesRow" of card "templates" of stack tMB into tTemplateWidth
   put 0 into tRows
   repeat with i = 1 to the number of groups of card "Pending Messages" of stack tMB
      put the long id of group i of card "Pending Messages" of stack tMB into tGroup
      if the short name of tGroup is not "pendingMessagesRow" then next repeat
      if the visible of tGroup is false then next repeat
      add 1 to tRows
      TestAssert "pending message row" && tRows && "laid out to the list's width", \
            the width of field "message" of tGroup > tTemplateWidth
   end repeat
   TestAssert "the rows of the pending messages are shown", tRows >= 2

   repeat for each line tMessage in tMessages
      cancel tMessage
   end repeat
   dispatch "showCard" to stack tMB with "Single Line"
   delete stack tStackName
end TestPendingMessagesRowsLaidOut
