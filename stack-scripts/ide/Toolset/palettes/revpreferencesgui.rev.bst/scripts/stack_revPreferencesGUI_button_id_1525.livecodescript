script "stack_revPreferencesGUI_button_id_1525"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Files & Memory" (id 1007) > button "ismac" (id 1525)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   send checkMacCustIcon to me
end mousedown

on checkMacCustIcon
   if the platform contains "mac" then
      set the backgroundColor of me to darkgreen
      set the hilite of me to true
      --
      -- now we need to check for developer tools...
      set the hideConsoleWindows to true
      put "xcode-select -p >/dev/null 2>&1 && echo " & QUOTE & "installed" & QUOTE & " || echo " & QUOTE & "fail" & QUOTE into devCmd
      get shell(devCmd)
      if it contains "installed" then
         set the backgroundColor of button "developerTools" to darkgreen
         set the hilite of button "developerTools" to true
      else
         -- fail, no developer tools
         disable button "customStackIcon"
         set the hilite of btn "customStackIcon" of this card to false
         set the backgroundColor of button "developerTools" to red
         
         exit checkMacCustIcon
      end if
      --
      -- okay, we have developer tools and we are on a mac
      enable button "customStackIcon"
      if the cMacCustomStackIcon of stack "revPreferences" is true then
         set the hilite of btn "customStackIcon" of this card to true
      else
         set the hilite of btn "customStackIcon" of this card to false
      end if
   else
      -- fail
      set the backgroundColor of me to red
      set the hilite of me to false
      --
      set the backgroundColor of button "developerTools" to red
      set the hilite of button "developerTools" to false
      --
      set the hilite of button "customStackIcon" to false
      disable button "customStackIcon"
      --
   end if
end checkMacCustIcon
