script "stack_revStandaloneSettings_field_id_1254"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Stacks" (id 1013) > group "Advanced Options" (id 2036) > field "stacks" (id 1254)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.


on arrowKey
  send "mouseUp" to me in 10 milliseconds
  pass arrowKey
end arrowKey

on mouseUp
  local tHilitedStacks,tSettings,tStack
  if the hilitedLines of field "stacks" is not empty then
    put the hilitedStacks of me into tHilitedStacks
    put the cRevStandaloneSettings["destroyStack"] of stack (line 1 of tHilitedStacks) into tSettings["destroyStack"]
    put the cRevStandaloneSettings["password"] of stack (line 1 of tHilitedStacks) into tSettings["password"]
    put the cRevStandaloneSettings["moveImages"] of stack (line 1 of tHilitedStacks) into tSettings["moveImages"]
    repeat for each line tStack in line 2 to -1 of tHilitedStacks
      if the cRevStandaloneSettings["destroyStack"] of stack tStack <> tSettings["destroyStack"] then
        put "false" into tSettings["destroyStack"]
      end if
      if the cRevStandaloneSettings["password"] of stack tStack <> tSettings["password"] then
        put "" into tSettings["password"]
      end if
      if the cRevStandaloneSettings["moveImages"] of stack tStack <> tSettings["moveImages"] then
        put "false" into tSettings["moveImages"]
      end if
    end repeat
    set the hilite of btn "destroyStack" to tSettings["destroyStack"] = true
    set the hilite of btn "encrypt" to tSettings["password"] <> ""
    put tSettings["password"] into fld "encrypt"
  end if
  revSetEdit
end mouseUp

getProp hilitedStacks
   local tStacks,tHilitedStacks,tItem
   put fld "stacks" into tStacks
   repeat for each item tItem in the hilitedLines of field "stacks"
      put line tItem of tStacks & cr after tHilitedStacks
   end repeat
   delete char -1 of tHilitedStacks
   return tHilitedStacks
end hilitedStacks
