script "stack_revGettingStartedScripts_group_id_1244"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Storing a modification timestamp Example" (id 1244)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on closeField -- place in stack script
  set the lastModDate of this card to the seconds
end closeField

-- handle displaying the date and automatically updating it:

local lastTimestamp
local storedMessageID

on preOpenBackGround
  updateTimestamp
end preOpenBackGround

on updateTimestamp
  if not (there is a field "Explanation") then exit updateTimeStamp -- card changed
  if the lastModDate of this card is not lastTimeStamp then
    put the lastModDate of this card into lastTimestamp
    get lastTimestamp
    convert it to date and time
    put it into line 2 of field "Explanation"
  end if
  send "updateTimestamp" to me in 1 second
  put the result into storedMessageID
end updateTimestamp

on closeBackground
  cancel storedMessageID
end closeBackground
