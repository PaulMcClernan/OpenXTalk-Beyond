script "stack_revStandaloneSettings_group_id_1169"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Windows" (id 1016) > group "Windows" (id 1169)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

# OK-2007-07-09 : Bug 4592, Rewrote this code to remove duplication and inappropriate sending of engine messages.

on closeField
  WINpropertyChanged the id of the target
  pass closeField
end closeField

on returnInField
  WINpropertyChanged the id of the target
  pass returnInField
end returnInField

on tabKey
  WINpropertyChanged the id of the target
  pass tabKey
end tabKey

on revCheckAutoFill
  if the cRevStandaloneSettings["OSX,copyright"] of stack the cRevTargetStack of this stack = "" then 
    set the cRevStandaloneSettings["OSX,copyright"] of stack the cRevTargetStack of this stack to field "copyright"
  end if
end revCheckAutoFill

-- PM-2015-11-06: [[ Bug 16371 ]] Make sure the corrent handler is called when updating the fields of Windows group
on WINpropertyChanged pTargetId
  local tTarget
  put the long id of control id pTargetId into tTarget
  
  if the short name of tTarget contains "version" and the text of tTarget is not a number then
    put 0 into tTarget
    beep 1
  end if
  
  set the cRevStandaloneSettings["Windows," & the short name of tTarget] of stack the cRevTargetStack of this stack to the text of tTarget
  revSetEdit
  revCheckAutoFill
end WINpropertyChanged


