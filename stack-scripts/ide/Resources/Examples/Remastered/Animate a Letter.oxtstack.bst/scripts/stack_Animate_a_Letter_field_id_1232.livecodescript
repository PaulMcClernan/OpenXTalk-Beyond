script "stack_Animate_a_Letter_field_id_1232"
-- Stack file: ide/Resources/Examples/Remastered/Animate a Letter.oxtstack
-- Object: stack "Animate a Letter" > card "Make a Story" (id 1041) > field "Story" (id 1232)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --hide all
   lock screen for visual effect
   hide group "Fox1"
   hide group "Fox2"
   hide group "Fox3"
   hide me
   unlock screen with visual effect "dissolve"  --quoted, for strict compilation mode
end mouseUp
