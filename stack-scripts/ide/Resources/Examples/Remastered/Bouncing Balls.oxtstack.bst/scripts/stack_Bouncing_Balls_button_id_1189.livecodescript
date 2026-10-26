script "stack_Bouncing_Balls_button_id_1189"
-- Stack file: ide/Resources/Examples/Remastered/Bouncing Balls.oxtstack
-- Object: stack "Bouncing Balls" > card "Main" (id 1031) > button "toggleGraphics" (id 1189)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

## (remaster) The original's checkbox had no script, so a click on it changed nothing. It is a
## switch now: a click turns it, and the stack script's graphicsToggle turns accelerated rendering
## on or off to match
on mouseUp
   set the hilite of me to not the hilite of me
   showSwitch
   graphicsToggle
end mouseUp

## The switch shows the button's hilite: on, its knob is at the right and its track is orange
on showSwitch
   if the hilite of me then
      set the backgroundColor of graphic "SwitchTrack" of the owner of me to the cOn of me
      set the right of graphic "SwitchKnob" of the owner of me to the right of graphic "SwitchTrack" of the owner of me - 2
   else
      set the backgroundColor of graphic "SwitchTrack" of the owner of me to the cOff of me
      set the left of graphic "SwitchKnob" of the owner of me to the left of graphic "SwitchTrack" of the owner of me + 2
   end if
end showSwitch
