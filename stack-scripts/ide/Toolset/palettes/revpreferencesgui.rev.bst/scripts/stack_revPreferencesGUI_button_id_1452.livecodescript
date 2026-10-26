script "stack_revPreferencesGUI_button_id_1452"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Troubleshooting" (id 1439) > button "Reset" (id 1452)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   set the cMsgboxSysWin of stack "revPreferences" to false
   set the cMsgboxTopLevel of stack "revPreferences" to false
   set the cInspectorSysWin of stack "revPreferences" to false
   set the cInspectorTopLevel of stack "revPreferences" to false
   set the cMsgboxdontTouch of stack "revPreferences" to true
   set the hilite of btn "MsgboxDontMess" to true
   --
   send preopencard to this card
   
end mouseUp
