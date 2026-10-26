script "stack_revMenuManager_button_id_4865"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > card "Menu Manager" (id 1002) > group "Menu Item Controls" (id 3265) > button "Shortcut" (id 4865)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.


setProp cREVDisabled pDisabled
   if pDisabled then
      disable me
      --if the platform is "MacOS" then
      --set the icon of me to 202565
      --else
      --set the icon of me to 202566
      --end if
   else
      enable me
      --if the platform is "MacOS" then
      --set the icon of me to 202544
      --else
      --set the icon of me to 202546
   --end if
end if
end cREVDisabled
