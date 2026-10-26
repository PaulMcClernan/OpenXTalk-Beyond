script "stack_Play_a_Video_group_id_1171"
-- Stack file: ide/Resources/Examples/Remastered/Play a Video.oxtstack
-- Object: stack "Play a Video" > card "Theater" (id 1032) > group "Controls" (id 1171)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp pButton  --a button of the bar: its group's name says which
   switch buttonOf(the long id of the target)
      case "PlayPause"
         playPause
         break
      case "Stop"
         stopMovie
         break
      case "Speed"
         nextSpeed
         break
      case "Loop"
         toggleLoop
         break
      case "Choose"
         chooseMovie
         break
      default
         pass mouseUp
   end switch
end mouseUp

on mouseDown pButton  --the time line: the movie follows the mouse while it is down
   if buttonOf(the long id of the target) is "Timeline" then
      seekTo the mouseH
      repeat while the mouse is down
         seekTo the mouseH
         wait 30 milliseconds with messages
      end repeat
   else
      pass mouseDown
   end if
end mouseDown

private function buttonOf pObj  --the group of the bar that pObj is in
   repeat while word 1 of pObj is not "card"
      if word 1 of pObj is "group" and the short name of pObj is not "Controls" then
         return the short name of pObj
      end if
      put the long owner of pObj into pObj
   end repeat
   return empty
end buttonOf
