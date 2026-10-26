script "stack_Mobile_Sound_Example_scrollbar_id_1036"
-- Stack file: ide/Resources/Mobile Examples/Sound Example.livecode
-- Object: stack "Mobile Sound Example" > card (id 1002) > group "Queued Sounds" (id 1035) > scrollbar "Background Volume" (id 1036)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on scrollbarDrag
   setChannelVolume "Queue", the thumbPosition of me
end scrollbarDrag
