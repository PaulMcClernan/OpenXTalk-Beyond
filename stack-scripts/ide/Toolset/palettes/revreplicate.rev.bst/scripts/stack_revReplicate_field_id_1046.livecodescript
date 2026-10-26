script "stack_revReplicate_field_id_1046"
-- Stack file: ide/Toolset/palettes/revreplicate.rev
-- Object: stack "revReplicate" > card (id 1002) > field "Replicate" (id 1046)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local lPrefValue

on openField
  put me into lPrefValue
  pass openField
end openField

on closeField
  if the text of me is 1 then
    set the text of fld "replicateSuffix" to "time."
  else
    set the text of fld "replicateSuffix" to "times."
  end if
  if the text of me <= 0 or the text of me is not a number then
    answer "Please enter a number equal to 1 or more in the Replicate field."
    set the text of me to lPrefValue
    select text of me
  end if
 -- if the text of me > 50 then
  --  answer warning "Are you sure you want to replicate the selected objects"&&the text of me&&"times? This operation cannot be undone." with Cancel and OK
  --  if it is Cancel then
   --   set the text of me to lPrefValue
    --  select text of me
  --  end if
--  end if
  pass closeField
end closeField
