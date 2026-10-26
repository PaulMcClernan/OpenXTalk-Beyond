script "stack_revPreferencesGUI_group_id_1362"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Project Browser" (id 1320) > group "sections" (id 1362)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   local tSelectedSections, tSections
   put "Front scripts,Stacks,Back scripts,Stacks in use" into tSections
   repeat for each item tSection in tSections
      if the hilite of button tSection of me then
         put tSection & comma after tSelectedSections
      end if
   end repeat
   delete the last char of tSelectedSections
   
   updatePreference "pb_sections",tSelectedSections
end mouseUp
