script "stack_revObjectLibrary_field_id_1068"
-- Stack file: ide/Resources/Object Libraries/revObjectLibrary.rev
-- Object: stack "revObjectLibrary" > card "Message Intercepting Field" (id 1067) > field "Message Intercepting Field" (id 1068)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on keyDown
  hAlert
  pass keyDown
end keyDown

on deleteKey
  hAlert
  pass deleteKey
end deleteKey

on backSpaceKey
  hAlert
  pass backSpaceKey
end backSpaceKey

on cutKey
  hAlert
  pass cutKey
end cutKey

on pasteKey
  hAlert
  pass pasteKey
end pasteKey

on returnInField
  hAlert
  pass returnInField
end returnInField

on hAlert
  answer "Text editing performed on field."
end hAlert
