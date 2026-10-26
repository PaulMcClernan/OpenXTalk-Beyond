script "stack_revTitleBarSelector_button_id_1010"
-- Stack file: ide/Toolset/palettes/inspector/editors/com.livecode.pi.decorations.livecode
-- Object: stack "com.livecode.pi.decorations" > substack "revTitleBarSelector" > card (id 1002) > button "OK" (id 1010)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  local tTarget
  put the hilitedButtonName of group "decorations" into tTarget
  setDecorations tTarget, true
end mouseUp
