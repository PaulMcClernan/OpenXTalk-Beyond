script "stack_revReplicate_field_id_1044"
-- Stack file: ide/Toolset/palettes/replicate.oxtstack
-- Object: stack "revReplicate" > card (id 1002) > field "hScale" (id 1044)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local lOldLabel

on openField
  put the text of me into lOldLabel
end openField

on closeField
  put the text of me into tNewLabel
  if tNewlabel is 0 then exit closeField
  if fld "vScale" is 0 then exit closeField
  if lOldLabel is 0 then openField
  put (tNewLabel / lOldLabel) into tFactor
  if the iconState of btn "offsetLockButton" is locked then set the text of fld "vScale" to round(fld "vScale" * tFactor)
end closeField

on rawKeyDown
  openField
  pass rawKeydown
end rawKeyDown

on rawKeyUp
  closeField
end rawKeyUp
