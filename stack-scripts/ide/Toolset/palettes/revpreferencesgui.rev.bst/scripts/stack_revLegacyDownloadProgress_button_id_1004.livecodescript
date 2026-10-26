script "stack_revLegacyDownloadProgress_button_id_1004"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > substack "revLegacyDownloadProgress" > card (id 1002) > button "Cancel" (id 1004)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  send "legacyDriversDownloadCancel" to group "Compatibility" of stack "revPreferencesGUI" in 0 milliseconds
end mouseUp
