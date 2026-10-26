script "stack_Mobile_Sound_Example_scrollbar_id_1022"
-- Stack file: ide/Resources/Mobile Examples/Sound Example.livecode
-- Object: stack "Mobile Sound Example" > card (id 1002) > group "Transient Sounds" (id 1020) > scrollbar "Transient Volume" (id 1022)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on scrollbarDrag
   setChannelVolume "Transient", the thumbPosition of me
end scrollbarDrag
