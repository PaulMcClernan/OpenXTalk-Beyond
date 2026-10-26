script "stack_revPreferencesGUI_button_id_1433"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Troubleshooting" (id 1439) > group (id 1442) > button "MsgboxSysWin" (id 1433)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   set the cMsgboxSysWin of stack "revPreferences" to the hilite of me
   --
   set the hilite of btn "MsgboxDontMess" to false
   set the cMsgboxdontTouch of stack "revPreferences" to false
   --
   revUpdateAB
   if there is a stack "message box" then send tWDTroubleshooting to stack "message box"
end mouseUp
