script "stack_revPreferencesGUI_button_id_1469"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Troubleshooting" (id 1439) > group (id 1442) > button "MsgboxDontMess" (id 1469)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   set the cMsgboxTopLevel of stack "revPreferences" to false
   set the cInspectorSysWin of stack "revPreferences" to false
   set the cMsgboxdontTouch of stack "revPreferences" to true
   hide message box
   set the hilite of btn "MsgboxSysWin" to false
   set the hilite of btn "MsgboxTopLevel" to false
   set the hilite of btn "MsgboxDontMess" to true
   --
   revUpdateAB
end mouseUp
