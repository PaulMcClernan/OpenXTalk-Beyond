script "stack_revPreferencesGUI_button_id_1381"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Appearance" (id 1008) > group "Appearance" (id 1062) > button "toolselector color" (id 1381)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local lastItem

on mouseDown
  revRetainLabel
end mouseDown

on returnKey
  revRetainLabel
  pass returnKey
end returnKey

on enterKey
  revRetainLabel
  pass enterKey
end enterKey

on revRetainLabel
  put the label of me into lastItem
end revRetainLabel

on menuPick theItem
  if theItem is empty then
    set the label of me to lastItem
    exit menuPick
  end if
  if theItem contains "Other" then
    answer color
    if it is empty then -- canceled the dialog
      set the wholeMatches to true
      set the menuHistory of me to lineOffset(lastItem,me)
      pass menuPick
    end if
    put it into theItem
  end if
  set the backgroundColor of graphic "Tool Selector Swatch" to theItem
  set the cToolSelectorColor of stack "revPreferences" to theItem
end menuPick
