script "stack_revFileAssociations_button_id_1009"
-- Stack file: ide/Toolset/palettes/revfileassociations.livecode
-- Object: stack "revFileAssociations" > card (id 1002) > button "Show" (id 1009)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  # We need this done as soon as the user clicks the button. In case they close the window for example.
  set the cDontShowFileAssociationsDialog of stack "revPreferences" to the hilite of me
end mouseUp
