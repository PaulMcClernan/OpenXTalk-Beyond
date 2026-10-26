script "stack_Mobile_Sound_Example_scrollbar_id_1011"
-- Stack file: ide/Resources/Mobile Examples/Sound Example.livecode
-- Object: stack "Mobile Sound Example" > card (id 1002) > group "Backgound Sound" (id 1021) > scrollbar "Background Volume" (id 1011)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on scrollbarDrag
   setChannelVolume "Background", the thumbPosition of me
end scrollbarDrag
