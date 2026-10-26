script "stack_Mobile_Sound_Example_group_id_1020"
-- Stack file: ide/Resources/Mobile Examples/Sound Example.livecode
-- Object: stack "Mobile Sound Example" > card (id 1002) > group "Transient Sounds" (id 1020)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if word 1 of the name of the target is "button" then
      playTransientSound the short name of the target
   end if
end mouseUp
