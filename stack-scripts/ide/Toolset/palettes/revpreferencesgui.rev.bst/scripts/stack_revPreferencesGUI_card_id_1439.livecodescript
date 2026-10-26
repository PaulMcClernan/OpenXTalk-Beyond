script "stack_revPreferencesGUI_card_id_1439"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Troubleshooting" (id 1439)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenCard
   if the cMsgboxSysWin of stack "revPreferences" is empty then set the cMsgboxSysWin of stack "revPreferences" to false
   set the hilite of btn "MsgboxSysWin" to the cMsgboxSysWin of stack "revPreferences"
   --
   if the cMsgboxTopLevel of stack "revPreferences" is empty then set the cMsgboxTopLevel of stack "revPreferences" to false
   set the hilite of btn "MsgboxTopLevel" to the cMsgboxTopLevel of stack "revPreferences"
   --
   set the hilite of btn "MsgboxDontMess" to (the cMsgboxdontTouch of stack "revPreferences" is true)
   --
   if the cInspectorSysWin of stack "revPreferences" is empty then set the cInspectorSysWin of stack "revPreferences" to false
   set the hilite of btn "InspectorSysWin" to the cInspectorSysWin of stack "revPreferences"
   --
   if the cInspectorTopLevel of stack "revPreferences" is empty then set the cInspectorTopLevel of stack "revPreferences" to false
   set the hilite of btn "InspectorTopLevel" to the cInspectorTopLevel of stack "revPreferences"
end preOpencard

