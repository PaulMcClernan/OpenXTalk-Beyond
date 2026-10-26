script "stack_revStandaloneSettings_field_id_30333"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "iOS" (id 1641) > group "Requirement" (id 30344) > group (id 29881) > field "urlwhitelist" (id 30333)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  if the hilitedLines of me <> "" then 
    enable btn "Remove Entry"
  else
    disable btn "Remove Entry"
  end if
end mouseUp

on arrowKey
  send "mouseUp" to me in 10 milliseconds
  pass arrowKey
end arrowKey

on dragEnter
  set the acceptDrop to true
end dragEnter

on dragDrop pWhat
  put the dragData["files"] into tFiles
  if tFiles is not empty then
    repeat for each line l in tFiles
      if l is not empty then
        send "mouseUp"&& 1,l to btn "add file..."
      end if
    end repeat
  end if
end dragDrop
