script "stack_revStandaloneSettings_button_id_3607"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "iOS" (id 1641) > group "iOS Settings" (id 30345) > group (id 30343) > button "Minimum iOS Version" (id 3607)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick pItemName
   set the itemDelimiter to "."
   storeSetting "minimum version", item 1 to 2 of (word 1 of pItemName)
end menuPick
