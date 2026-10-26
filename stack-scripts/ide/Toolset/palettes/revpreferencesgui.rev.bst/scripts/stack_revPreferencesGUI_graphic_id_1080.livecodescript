script "stack_revPreferencesGUI_graphic_id_1080"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Appearance" (id 1008) > group "Appearance" (id 1062) > graphic "Help Hilite Swatch" (id 1080)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   global gRevHelpHiliteColor
   answer color
   if it is empty then -- canceled the dialog
      set the wholeMatches to true
      pass mousedown
   end if
   put it into theItem
   set the backgroundColor of graphic "Help Hilite Swatch" to theItem -- name of this swatch
   set the label of btn "hypertext color" to theItem  -- name of the dropdown menu
   -- set the properties
   set the backgroundColor of graphic "Help Hilite Swatch" of card "Appearance" to theItem
   set the cREVHelpHiliteColor of stack "revPreferences" to theItem
   
   --
   -- thanks to mwieder for this
   -- for a tip I found at https://forums.livecode.com/viewtopic.php?t=11356
   put "Help Hilite Swatch" into tTargBtn
   set the menuHistory of button tTargBtn to  1 -- set it away to anything
   set the menuHistory of button tTargBtn to (the number of lines of button tTargBtn)
end mousedown


