script "stack_revPreferencesGUI_card_id_1404"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Automatic Updates" (id 1404)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenCard
   --send tLastAutomaticUpdateCheck to this card
   -- human readable version
   if the cUseAutoUpdates of stack "revPreferences" is true then
      set the hilite of cd btn "useAutomaticUpdates" to true
   else
      set the hilite of cd btn "useAutomaticUpdates" to false
   end if
   put the tAutoUpdatesLastChecked of stack "revPreferences" into tLastCheckTime
   send tAutoUpdatesHook to this card in 10 milliseconds -- start checks for auto updates
   send readLastUpd to this card in 10 milliseconds
end preOpenCard

on readLastUpd
   put specialFolderPath("engine") into tBasePath
   put tBasePath & slash & "Toolset" & slash & "palettes" & slash & "updates" & slash & "whatsnew.txt" into tWhatsNewFile
   if there is a file tWhatsNewFile then
      open file tWhatsNewFile
      read from file tWhatsNewFile until EOF
      put it into tChangesDescription
      close file tWhatsNewFile
      put "Summary of last update:" & return & " " & return & tChangesDescription into fld "updNote" of me
      set the textstyle of fld "updNote" of me to plain
      set the textstyle of line 1 of fld "updNote" of me to bold
      show fld "updNote" of me
   else
      put "" into fld "updNote" of me
      hide fld "updNote" of me
   end if
end readLastUpd

on tLastAutomaticUpdateCheck
   -- find out when the last automatic check for updates happened
   put the tAutoUpdatesLastChecked of stack "revPreferences" into tLastCheckTime
   if tLastCheckTime is "" then
      -- not checked
      put "not checked" into tLastCheckTime -- make sure we have something readable here
      put "Last checked for updates:" & return & tLastCheckTime into fld "tlastchecked" of cd "Automatic Updates" of stack "revPreferencesGUI"
      if not (the pendingmessages contains "tCheckForUpdates") then 
         send tCheckForUpdates to card "Automatic Updates" of stack "revPreferencesGUI" in 10 seconds -- launch the update if hasn't been done
      end if
   else
      -- human readable version
      put tLastCheckTime into tTheSecondsThen
      convert tTheSecondsThen to dateitems
      if item 5 of tTheSecondsThen <10 then put "0" & item 5 of tTheSecondsThen into item 5 of tTheSecondsThen -- make sure mins have a 0 prefix if needed
      put item 4 of tTheSecondsThen & ":" & item 5 of tTheSecondsThen & ",  " & item 3 of  tTheSecondsThen & "/" &  item 2 of  tTheSecondsThen & "/" &  item 1 of  tTheSecondsThen into tHumanReadableDate
      put "Last checked for updates:" & return & tHumanReadableDate into fld "tlastchecked" of cd "Automatic Updates" of stack "revPreferencesGUI"
      -- tLastCheckTime -- contains the seconds since last check
      -- find out if it's time to run
      put (the cUseAutoUpdatesInterval of stack "revPreferences") into tHumanInterval
      put "0" into tSecPlus
      if tHumanInterval is "Daily" then put "86400" into tSecPlus
      if tHumanInterval is "Weekly" then put "604800" into tSecPlus
      if tHumanInterval is "Monthly" then put "2419200" into tSecPlus
      convert tTheSecondsThen to seconds -- convert from dateItems back to seconds
      if the seconds > (tTheSecondsThen + tSecPlus) then
         tCheckForUpdates
      end if
   end if
end tLastAutomaticUpdateCheck

on tCheckForUpdates
   -- so now we know the updates should run, because it's time.
   -- and the user has it configured to allow the updates, so....
   -- launch the updater window
   
   -- RELIABLY get the path, as it's not clear how I reference where this is from without causing other errors (and this is only 3 lines)
   put the effective filename of this stack into tUpdatePath
   if tUpdatePath contains "revpreferencesgui.rev" then replace "revpreferencesgui.rev" with "" in tUpdatePath
   put tUpdatePath & "updates/" into tUpdatePath
   --
   if not (the pendingmessages contains "tCheckForUpdates") then open stack (tUpdatePath & "updates.livecode")
end tCheckForUpdates

on tCheckForUpdatesVis
   set the cUpdateCheckSilent of stack "revPreferences" to false
   tCheckForUpdates
end tCheckForUpdatesVis
   
   on tOpenReleaseNotes
   -- opens the release notes stack (tperry 17-8-24)
   -- OXT-Beyond: the Release Notes window, with the changelog; the classic
   -- stack with the Option (Alt) key down, or when the window cannot open
   if tOpenBeyondReleaseNotes() then exit tOpenReleaseNotes
   put the effective filename of this stack into tUpdHistoryFolder
   if tUpdHistoryFolder contains "revpreferencesgui.rev" then replace "revpreferencesgui.rev" with "" in tUpdHistoryFolder
   put tUpdHistoryFolder & "updates" & slash into tUpdHistoryFolder
   put tUpdHistoryFolder & "ReleaseNotes.oxtstack" into tReleaseNotesStack
   --put tReleaseNotesStack -- debug
   open stack (tReleaseNotesStack)
end tOpenReleaseNotes

-- OXT-Beyond: opens updates/revreleasenotes.livecodescript, beside this
-- stack; false when it is not there or cannot open
private function tOpenBeyondReleaseNotes
   local tPath, tHow, tError
   if the optionKey is down then return false
   set the itemDelimiter to slash
   put item 1 to -2 of the effective filename of stack "revPreferencesGUI" & "/updates/revreleasenotes.livecodescript" into tPath
   set the itemDelimiter to comma
   if there is no file tPath then return false
   try
      dispatch "revReleaseNotesShow" to stack tPath
      put it into tHow
   catch tError
      return false
   end try
   return tHow is "handled"
end tOpenBeyondReleaseNotes

on tAutoUpdatesHook
   -- changed as of 6,10,24 (tperry)
   if the cUseAutoUpdates of stack "revPreferences" is true then
      set the cUpdateCheckSilent of stack "revPreferences" to false -- we don't do it silently anymore
      send tCheckForUpdates to card "Automatic Updates" of stack "revPreferencesGUI"
   end if
end tAutoUpdatesHook
