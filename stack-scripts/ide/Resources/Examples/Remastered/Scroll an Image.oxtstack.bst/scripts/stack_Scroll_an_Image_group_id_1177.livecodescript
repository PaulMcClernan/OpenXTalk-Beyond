script "stack_Scroll_an_Image_group_id_1177"
-- Stack file: ide/Resources/Examples/Remastered/Scroll an Image.oxtstack
-- Object: stack "Scroll an Image" > card "Scrollbar Settings" (id 1033) > group "Settings" (id 1177)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--(added in the remaster) Each switch and
--button here sets one property of the
--group "Window", as the Object Inspector
--does, and the line under them is the
--line of script it ran.

on mouseUp
   local tSetting, tProperty, tValue
   --a switch is a group of its parts
   put the short name of the owner of the target into tSetting
   switch tSetting
      case "hScrollbar"
         --on or off: the bottom scrollbar
         put "hScrollbar" into tProperty
         put not the hScrollbar of group "Window" into tValue
         set the hScrollbar of group "Window" to tValue
         break
      case "vScrollbar"
         --on or off: the right scrollbar
         put "vScrollbar" into tProperty
         put not the vScrollbar of group "Window" into tValue
         set the vScrollbar of group "Window" to tValue
         break
      case "Width 12"
      case "Width 16"
      case "Width 20"
         --how thick the scrollbars are
         put "scrollbarWidth" into tProperty
         put word 2 of tSetting into tValue
         set the scrollbarWidth of group "Window" to tValue
         break
      case "Size Small"
         --the window: how much of the
         --painting shows at once
         put "rect" into tProperty
         put "276,124,476,304" into tValue
         set the rect of group "Window" to tValue
         break
      case "Size Large"
         put "rect" into tProperty
         put "276,124,580,384" into tValue
         set the rect of group "Window" to tValue
         break
      default
         exit mouseUp
   end switch
   showSettings
   put "set the" && tProperty && "of group" && quote & "Window" & quote && "to" && tValue into field "Ran"
end mouseUp

--the switches and buttons show the group's
--settings as they are now
command showSettings
   showSwitch "hScrollbar", the hScrollbar of group "Window"
   showSwitch "vScrollbar", the vScrollbar of group "Window"
   showChoice "Width 12", the scrollbarWidth of group "Window" is 12
   showChoice "Width 16", the scrollbarWidth of group "Window" is 16
   showChoice "Width 20", the scrollbarWidth of group "Window" is 20
   showChoice "Size Small", the width of group "Window" < 300
   showChoice "Size Large", the width of group "Window" >= 300
end showSettings

private command showSwitch pName, pOn
   if pOn then
      --on: the track is teal
      set the backgroundColor of graphic (pName & "_track") to "13,148,136"
      set the right of graphic (pName & "_knob") to the right of graphic (pName & "_track") - 2
   else
      --off: it is grey
      set the backgroundColor of graphic (pName & "_track") to "203,213,225"
      set the left of graphic (pName & "_knob") to the left of graphic (pName & "_track") + 2
   end if
end showSwitch

--(cRest is the colour the window gives a
--button when the pointer leaves it, and
--cLit when it is over it)
private command showChoice pName, pChosen
   if pChosen then
      set the cRest of group pName to "13,148,136"
      set the cLit of group pName to "20,184,166"
      set the textColor of field (pName & "_label") to "255,255,255"
   else
      set the cRest of group pName to "255,255,255"
      set the cLit of group pName to "240,250,249"
      set the textColor of field (pName & "_label") to "15,23,42"
   end if
   set the backgroundColor of graphic (pName & "_bg") to the cRest of group pName
end showChoice
