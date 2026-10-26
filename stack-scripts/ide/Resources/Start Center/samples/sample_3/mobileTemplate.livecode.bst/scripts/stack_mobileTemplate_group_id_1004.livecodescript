script "stack_mobileTemplate_group_id_1004"
-- Stack file: ide/Resources/Start Center/samples/sample_3/mobileTemplate.livecode
-- Object: stack "mobileTemplate" > card "template" (id 1868) > group "header" (id 1004)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

################################################
# PROPERTY SETTERS
################################################

setprop headerBackgroundColor pColor
   set the backgroundcolor of graphic "background" of me to pColor
end headerBackgroundColor

setprop headerTitle pTitle
   if pTitle is empty then exit headerTitle
   if the number of chars of pTitle > 45 then
      put char 1 to 45 of pTitle & ".." into pTitle
   end if
   put pTitle into field "title" of me
end headerTitle

setprop headerButtonBackVisible pVisible
   if pVisible is false then
      set the visible of button "back" of me to false
   else
      set the visible of button "back" of me to true
   end if
end headerButtonBackVisible

getprop headerButtonBackVisible
   return the visible of button "back" of me
end headerButtonBackVisible

setprop headerButtonAddVisible pVisible
   if pVisible is false then
      set the visible of button "add" of me to false
   else
      set the visible of button "add" of me to true
   end if
end headerButtonAddVisible

getprop headerButtonAddVisible
   return the visible of button "add" of me
end headerButtonAddVisible

setprop headerButtonDeleteVisible pVisible
   if pVisible is false then
      set the visible of button "delete" of me to false
   else
      set the visible of button "delete" of me to true
   end if
end headerButtonDeleteVisible

getprop headerButtonDeleteVisible
   return the visible of button "delete" of me 
end headerButtonDeleteVisible

setprop headerButtonUploadVisible pVisible
   if pVisible is false then
      set the visible of button "upload" of me to false
   else
      set the visible of button "upload" of me to true
   end if
end headerButtonUploadVisible

getprop headerButtonUploadVisible
   return the visible of button "upload" of me 
end headerButtonUploadVisible

################################################
# POSITIONING
################################################
constant kPADDING = 10

on resizeControl
   lock screen
   lock messages
   set the lockloc of me to true
   
   local tShadowSize, tShadowOffset
   put the height of me / 10 into tShadowSize
   put tShadowSize / 2 into tShadowOffset
   
   set the rect of graphic "background" of me to the rect of me
   
   set the width of field "title" of me to the width of me
   set the loc of field "title" of me to the loc of me
   set the left of field "title" of me to the left of me
   set the top of field "title" of me to the top of field "title" of me - tShadowOffset
   
   set the loc of button "back" to the loc of me
   set the left of button "back" of me to the left of me + kPADDING
    set the top of button "back" of me to the top of button "back" of me - tShadowOffset
   
   set the loc of button "add" to the loc of me
   set the loc of button "upload" to the loc of me
   set the loc of button "delete" to the loc of me
   set the right of button "add" of me to the right of me - kPADDING
   set the right of button "upload" of me to the right of me - kPADDING
   set the right of button "delete" of me to the right of me - kPADDING
   set the top of button "add" of me to the top of button "add" of me - tShadowOffset
   set the top of button "upload" of me to the top of button "upload" of me - tShadowOffset
   set the top of button "delete" of me to the top of button "delete" of me - tShadowOffset
   
   set the height of graphic "strip" of me to tShadowSize
   set the width of graphic "strip" of me to the width of me
   set the loc of graphic "strip" of me to the loc of me
   set the bottom of graphic "strip" of me to the bottom of me
   
   set the lockloc of me to false
   unlock messages
   unlock screen
end resizeControl





