script "stack_revMenuManager_button_id_4867"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > card "Menu Manager" (id 1002) > group "Menu Item Controls" (id 3265) > button "Shortcut Checkbox" (id 4867)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  lock screen
  revCheckNameChanged
  if the hilite of me then 
     enable fld "Shortcut"
     --------------------
     -- LG 2008-08-26
     enable button "Control"
     enable button "Command"
     enable button "Shift"
     enable button "Option_Alt"
     --------------------
    select the text of fld "Shortcut"
  else
    --remove Shortcut
    put empty into fld "Shortcut"
    send "revSetShortCut" to fld "Shortcut"
    disable fld "Shortcut"
    -------------------------
    -- LG 2008-08-26
    set the hilite of button "Control" to "false"
    set the hilite of button "Command" to "false"
    set the hilite of button "Option_Alt" to "false"
    set the hilite of button "Shift" to "false"
    disable button "Control"
    disable button "Command"
    disable button "Shift"
    disable button "Option_Alt"
    -------------------------
  end if
  unlock screen
end mouseUp

