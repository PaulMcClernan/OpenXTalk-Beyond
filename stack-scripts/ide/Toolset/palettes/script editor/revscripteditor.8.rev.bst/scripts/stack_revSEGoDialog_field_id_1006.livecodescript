script "stack_revSEGoDialog_field_id_1006"
-- Stack file: ide/Toolset/palettes/script editor/revscripteditor.8.rev
-- Object: stack "revNewScriptEditor" > substack "revSEGoDialog" > card (id 1002) > field "Number" (id 1006)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on returnInField
   closeAccept
end returnInField

on enterInField
   closeAccept
end enterInField

on keyDown pKey
   if inputValid(pKey) then
      pass keyDown
   end if
end keyDown

private function inputValid pInput
   if pInput is a number then
      return true
   else
      return false
   end if
end inputValid
