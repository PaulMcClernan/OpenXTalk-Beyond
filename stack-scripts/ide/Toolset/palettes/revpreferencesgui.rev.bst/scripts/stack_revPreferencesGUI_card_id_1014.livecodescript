script "stack_revPreferencesGUI_card_id_1014"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "RevOnline" (id 1014)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenCard
   send "update" to group "revOnline"
end preOpenCard
