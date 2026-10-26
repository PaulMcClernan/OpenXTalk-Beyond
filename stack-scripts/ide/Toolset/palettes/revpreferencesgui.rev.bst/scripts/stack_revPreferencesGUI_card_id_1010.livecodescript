script "stack_revPreferencesGUI_card_id_1010"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Script Editor" (id 1010)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenCard
   set the hilite of button "hide errors" to the cSEHideErrors of stack "revPreferences"
   set the hilite of button "hide palettes" to the cSEHidePalettes of stack "revPreferences"
   set the hilite of button "hide message box" to the cSEHideMessageBox of stack "revPreferences"
   send "update" to group "Script Editor"
   --
   if the cExternalScriptEditor of stack "revPreferences" is empty then set the cExternalScriptEditor of stack "revPreferences" to false
   set the hilite of button "External script editor" to the cExternalScriptEditor of stack "revPreferences"
   if the cExternalScriptEditorName of stack "revPreferences" is empty then
      set the text of btn "editorsList" of this card to ""
      set the showname of btn "editorsList" of this card to false
   else
      set the text of btn "editorsList" to the cExternalScriptEditorName of stack "revPreferences"
      set the showname of btn "editorsList" of this card to true
   end if
end preOpenCard
