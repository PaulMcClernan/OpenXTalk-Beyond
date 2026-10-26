script "stack_Animate_Letter_button_id_1050"
-- Stack file: ide/Resources/Examples/Animate Letter.oxtstack
-- Object: stack "Animate Letter" > card (id 1018) > button "Info" (id 1050)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   lock screen for visual effect
   set the visible of fld "Info" to not the visible of fld "Info"  --toggle show/hide
   unlock screen with visual effect dissolve
end mouseUp
