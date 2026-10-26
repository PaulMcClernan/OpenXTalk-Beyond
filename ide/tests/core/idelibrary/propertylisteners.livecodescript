script "TestPropertyListeners"
/*
Copyright (C) 2026 OXT-Beyond contributors.

This file is part of OXT-Beyond, a fork of LiveCode Community.

LiveCode is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License v3 as published by the Free
Software Foundation.

LiveCode is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with LiveCode.  If not see <http://www.gnu.org/licenses/>.  */

-- OXT-Beyond: tests of revIDESubscribe and revIDEUnsubscribe for
-- idePropertyChanged, which have the IDE library listen to an object, as
-- the Inspector does, and stop. Stopping reads no stack from its file
-- again: not a stack deleted from memory, whose objects the engine stops
-- listening to itself, and not a stack whose long id names the file it was
-- saved to before it was saved as another (openxtalk.org p=25429)

-- (not the name of this script's own stack, which a test cannot delete)
constant kStack = "OXTListenerProbe"
constant kSubstack = "OXTListenerProbeSub"
constant kNumberedStack = "1984"
constant kCatcher = "OXTListenerProbeReload"

local sFolder

on TestSetup
   put specialFolderPath("temporary") & slash & "oxt-property-listeners-" & \
         the milliseconds into sFolder
   create folder sFolder
end TestSetup

on TestTeardown
   local tStack, tDefaultFolder, tFile
   __RemoveReloadCatcher
   repeat for each item tStack in kStack & comma & kNumberedStack
      if tStack is among the lines of the mainStacks then
         revIDESetUnedited tStack
         delete stack tStack
      end if
   end repeat
   put the defaultFolder into tDefaultFolder
   set the defaultFolder to sFolder
   repeat for each line tFile in the files
      delete file (sFolder & slash & tFile)
   end repeat
   set the defaultFolder to tDefaultFolder
   delete folder sFolder
end TestTeardown

-- A stack kStack (or pName) with a button B1, saved to a file in sFolder if
-- pSave is true
private command __NewStack pSave, pName
   if pName is empty then
      put kStack into pName
   end if
   create stack pName
   set the defaultStack to pName
   create button "B1"
   if pSave then
      save stack pName as (sFolder & slash & pName & ".oxtstack")
   end if
end __NewStack

-- Whether the IDE library listens to the object with the long id pObject,
-- from the engine's list of what it listens to
private function __ListenedTo pObject
   local tListeners
   put value("the revObjectListeners", the long id of stack "revidelibrary") into tListeners
   return pObject is among the lines of tListeners
end __ListenedTo

-- Counts each reloadStack message, sent when a stack is read from a file
-- while a stack of the same name is in memory, without passing it (the
-- IDE would ask what to do with the stack in memory)
private command __InsertReloadCatcher
   local tDefaultStack
   put the defaultStack into tDefaultStack
   create invisible stack kCatcher
   set the script of stack kCatcher to "on reloadStack" & return & \
         "   set the cReloads of me to the cReloads of me + 1" & return & \
         "end reloadStack"
   set the cReloads of stack kCatcher to 0
   insert the script of stack kCatcher into front
   set the defaultStack to tDefaultStack
end __InsertReloadCatcher

private command __RemoveReloadCatcher
   if kCatcher is among the lines of the mainStacks then
      remove the script of stack kCatcher from front
      delete stack kCatcher
   end if
end __RemoveReloadCatcher

on TestUnsubscribeStopsListening
   local tButton
   __NewStack false
   put the long id of button "B1" of card 1 of stack kStack into tButton
   revIDESubscribe "idePropertyChanged", tButton
   TestAssert "the IDE listens to an object subscribed to", __ListenedTo(tButton)

   revIDEUnsubscribe "idePropertyChanged", "", tButton
   TestAssert "unsubscribing leaves the result empty", the result is empty
   TestAssert "the IDE stops listening to an object unsubscribed from", \
         not __ListenedTo(tButton)
end TestUnsubscribeStopsListening

on TestUnsubscribeSavedStack
   local tButton
   __NewStack true
   go stack kStack
   put the long id of button "B1" of card 1 of stack kStack into tButton
   revIDESubscribe "idePropertyChanged", tButton
   TestAssert "the IDE listens to an object of a saved stack", __ListenedTo(tButton)

   revIDEUnsubscribe "idePropertyChanged", "", tButton
   TestAssert "unsubscribing leaves the result empty", the result is empty
   TestAssert "the IDE stops listening to an object of a saved stack", \
         not __ListenedTo(tButton)
end TestUnsubscribeSavedStack

on TestUnsubscribeClosedStack
   local tButton
   __NewStack true
   go stack kStack
   put the long id of button "B1" of card 1 of stack kStack into tButton
   revIDESubscribe "idePropertyChanged", tButton
   revIDESetUnedited kStack
   close stack kStack
   TestAssert "a closed stack stays in memory", kStack is among the lines of the mainStacks

   revIDEUnsubscribe "idePropertyChanged", "", tButton
   TestAssert "unsubscribing leaves the result empty", the result is empty
   TestAssert "the IDE stops listening to an object of a closed stack", \
         not __ListenedTo(tButton)
end TestUnsubscribeClosedStack

on TestUnsubscribeDeletedStack
   local tButton
   __NewStack true
   put the long id of button "B1" of card 1 of stack kStack into tButton
   revIDESubscribe "idePropertyChanged", tButton
   revIDESetUnedited kStack
   delete stack kStack

   revIDEUnsubscribe "idePropertyChanged", "", tButton
   TestAssert "unsubscribing leaves the result empty", the result is empty
   TestAssert "unsubscribing from an object of a deleted stack does not read the stack from its file", \
         kStack is not among the lines of the mainStacks
end TestUnsubscribeDeletedStack

on TestUnsubscribeDeletedSubstack
   local tButton
   __NewStack true
   create stack kSubstack
   set the mainStack of stack kSubstack to kStack
   set the defaultStack to kSubstack
   create button "B1"
   save stack kStack
   put the long id of button "B1" of card 1 of stack kSubstack into tButton
   revIDESubscribe "idePropertyChanged", tButton
   revIDESetUnedited kStack
   delete stack kStack

   revIDEUnsubscribe "idePropertyChanged", "", tButton
   TestAssert "unsubscribing leaves the result empty", the result is empty
   TestAssert "unsubscribing from an object of a deleted substack does not read its main stack from its file", \
         kStack is not among the lines of the mainStacks
end TestUnsubscribeDeletedSubstack

on TestUnsubscribeAfterSaveAs
   local tButton, tSavedAs, tReloads
   __NewStack true
   -- The long id names the file the stack was first saved to
   put the long id of button "B1" of card 1 of stack kStack into tButton
   revIDESubscribe "idePropertyChanged", tButton
   put sFolder & slash & kStack & "-saved-as.oxtstack" into tSavedAs
   save stack kStack as tSavedAs

   __InsertReloadCatcher
   revIDEUnsubscribe "idePropertyChanged", "", tButton
   TestAssert "unsubscribing leaves the result empty", the result is empty
   put the cReloads of stack kCatcher into tReloads
   __RemoveReloadCatcher
   TestAssert "unsubscribing with a long id that names the file a stack was saved to before does not read that file", \
         tReloads is 0
   TestAssert "the stack is still the one saved as the new file", \
         the filename of stack kStack is tSavedAs
end TestUnsubscribeAfterSaveAs

on TestUnsubscribeStackNamedWithNumber
   local tButton
   __NewStack false, kNumberedStack
   put the long id of button "B1" of card 1 of stack kNumberedStack into tButton
   revIDESubscribe "idePropertyChanged", tButton
   TestAssert "the IDE listens to an object of a stack named with a number", __ListenedTo(tButton)

   revIDEUnsubscribe "idePropertyChanged", "", tButton
   TestAssert "unsubscribing leaves the result empty", the result is empty
   TestAssert "the IDE stops listening to an object of a stack named with a number", \
         not __ListenedTo(tButton)
end TestUnsubscribeStackNamedWithNumber
