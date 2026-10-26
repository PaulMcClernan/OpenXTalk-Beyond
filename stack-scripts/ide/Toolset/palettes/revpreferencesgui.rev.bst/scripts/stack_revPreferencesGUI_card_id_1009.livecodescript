script "stack_revPreferencesGUI_card_id_1009"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Object Sizes" (id 1009)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenCard
   
   updateDefaultSizeFields
end preOpenCard

command updateDefaultSizeFields
  repeat for each line tDefaultSize in the cDefaultSizes of stack "revPreferences"
    local tName
    put item 1 of tDefaultsize into tName
    put the tName of stack "revPreferences" into field tName of group "Object Sizes" of me
  end repeat
end updateDefaultSizeFields
