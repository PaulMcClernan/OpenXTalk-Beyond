script "stack_revDataViewControl_button_id_1019"
-- Stack file: ide/Toolset/palettes/revCore.8.livecode
-- Object: stack "revCore" > substack "revDataViewControl" > card (id 1002) > button "Drop Indicator Behavior" (id 1019)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on resizeControl
   if the target is not me then pass resizeControl
   
   put the rect of me into theViewRect
   
   put the rect of graphic 2 of me into theRect
   put item 3 of theViewRect + 1 into item 3 of theRect
   set the rect of graphic 2 of me to theRect
end resizeControl
