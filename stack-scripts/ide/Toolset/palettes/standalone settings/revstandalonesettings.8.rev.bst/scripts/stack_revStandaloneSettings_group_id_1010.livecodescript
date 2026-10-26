script "stack_revStandaloneSettings_group_id_1010"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "General" (id 1002) > group "cards" (id 1010)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseEnter
  if the owner of the target is me and word 1 of the target is "button" then
      set the showBorder of the target to true
  end if
end mouseEnter

on mouseLeave 
   if the owner of the target is me and word 1 of the target is "button" then
      set the showBorder of the target to false
   end if
      
end mouseLeave


on mousedown
   
   if the owner of the target is me and word 1 of the target is "button" then
      navigateToCard the short name of the target
   end if
   
   -- 
   
   /*try 
   send hUpdateHeights to stack "revStandaloneSettingsbehavior" in 20 milliseconds
   dispatch hUpdateHeights to stack "revStandaloneSettingsbehavior"      
catch e
end try
*/

   send reaffirmHeights to me in 2 ticks
end mousedown

on reaffirmHeights
   --put the name of this card
   
end reaffirmHeights

on mouseenter
   send hUpdateHeights to stack "revStandaloneSettingsbehavior" in 20 milliseconds
end mouseenter

on mouseleave
   send hUpdateHeights to stack "revStandaloneSettingsbehavior" in 10 milliseconds
end mouseleave


