script "stack_revStandaloneSettings_group_id_1221"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "OS X" (id 1015) > group "OSX" (id 1221)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

# OK-2007-07-09 : Changed this code to remove duplication and inappropriate sending of engine messages

on closeField
  OSXpropertyChanged the id of the target
  pass closeField
end closeField

on returnInField
  OSXpropertyChanged the id of the target
  pass returnInField
end returnInField

on tabKey
  OSXpropertyChanged the id of the target
  pass tabKey
end tabKey

-- PM-2015-11-06: [[ Bug 16371 ]] Make sure the corrent handler is called when updating the fields of OSX group
on OSXpropertyChanged pTargetId
  local tTarget
  put the long id of control id pTargetId into tTarget
  set the cRevStandaloneSettings["OSX,"&the short name of tTarget] of stack the cRevTargetStack of this stack to the text of tTarget
  revSetEdit
  revCheckAutoFill
end OSXpropertyChanged

on revCheckAutoFill
  if the cRevStandaloneSettings["MacOS,creator"] of stack the cRevTargetStack of this stack = "" or \
      the cRevStandaloneSettings["MacOS,creator"] of stack the cRevTargetStack of this stack = "RApp" then 
    set the cRevStandaloneSettings["MacOS,creator"] of stack the cRevTargetStack of this stack to fld "signature"
  end if
  if the cRevStandaloneSettings["MacOS,documentType"] of stack the cRevTargetStack of this stack = "" then 
    set the cRevStandaloneSettings["MacOS,documentType"] of stack the cRevTargetStack of this stack to fld "documentType"
  end if
  if the cRevStandaloneSettings["MacOS,shortVersion"] of stack the cRevTargetStack of this stack = "" then 
    set the cRevStandaloneSettings["MacOS,shortVersion"] of stack the cRevTargetStack of this stack to fld "shortVersion"
  end if
  if the cRevStandaloneSettings["MacOS,longVersion"] of stack the cRevTargetStack of this stack = "" then 
    set the cRevStandaloneSettings["MacOS,longVersion"] of stack the cRevTargetStack of this stack to fld "longVersion"
  end if
  if the cRevStandaloneSettings["Windows,copyright"] of stack the cRevTargetStack of this stack = "" then 
    set the cRevStandaloneSettings["Windows,copyright"] of stack the cRevTargetStack of this stack to fld "copyright"
  end if
end revCheckAutoFill

