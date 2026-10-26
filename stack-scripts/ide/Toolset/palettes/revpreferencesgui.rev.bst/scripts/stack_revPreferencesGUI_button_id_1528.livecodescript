script "stack_revPreferencesGUI_button_id_1528"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Files & Memory" (id 1007) > button "useGallery" (id 1528)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   send checkRecentGallerySetting to button "useGallery"
end mousedown

on checkRecentGallerySetting
   if the cRecentstacksAsGallery of stack "revPreferences" is true then
      set the hilite of btn "useGallery" of this card to false
      set the cRecentstacksAsGallery of stack "revPreferences" to false
   else
      set the hilite of btn "useGallery" of this card to true
      set the cRecentstacksAsGallery of stack "revPreferences" to true
   end if
end checkRecentGallerySetting
