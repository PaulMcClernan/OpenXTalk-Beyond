script "stack_Mobile_Scroller_Example_button_id_1022"
-- Stack file: ide/Resources/Mobile Examples/Scroller Example.livecode
-- Object: stack "Mobile Scroller Example" > card "Main" (id 1002) > group "Controls" (id 1025) > button "Bounce" (id 1022)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   doSetProp "canBounce", the hilite of me
end mouseUp
