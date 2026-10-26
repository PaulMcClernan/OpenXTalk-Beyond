script "stack_Quick_Start_Guide_group_id_1174"
-- Stack file: ide/Resources/Examples/Remastered/Quick Start Guide.oxtstack
-- Object: stack "Quick Start Guide" > card "Orientation" (id 1031) > group "Narration" (id 1160) > group "Stop" (id 1174)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --(remaster) stop the narrator
   local tError
   try
      revStopSpeech
   catch tError  --no voice here, so nothing to stop
   end try
   narratorStopped  --see the stack script
end mouseUp
