script "stack_revNewScriptEditor_1_group_id_68484"
-- Stack file: ide/Toolset/palettes/script editor/revscripteditor.8.rev
-- Object: stack "revNewScriptEditor" > substack "revNewScriptEditor 1" > card "Main" (id 1002) > group "Script Tabs" (id 1038) > group "Tab 4" (id 68484)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

# Distance from the left of Tab button to the left of the icon
constant kIconOffset = 2

command resize
   set the rect of button "Tab" of me to the rect of me
   set the margins of button "Tab" of me to the width of button "Tab Icon" of me, 6, 4, 4
   set the loc of button "Tab Icon" of me to (the left of button "Tab" of me + round(0.5 * the width of button "Tab Icon" of me) + kIconOffset), (item 2  of the loc of button "Tab" of me)
end resize

# Hide the details of the group via virtual properties

# Parameters
#   pLabel : the text to set the label to
# Description
#   Sets the label without formatting it to the right.
setProp cRawLabel pLabel
   set the label of button "Tab" of me to pLabel
end cRawLabel

# Parameters
#   pLabel : the text to set the label to
# Description
#   Sets the label, but truncates to ensure the label fits. Puts "..." after if truncated.
setProp cLabel pLabel
   lock screen
   
   local tOldTextStyle
   put the textStyle of me into tOldTextStyle
   set the textStyle of me to "bold"
   
   if the last char of pLabel is "*" then
      set the label of button "Tab" of me to pLabel
   else
      set the label of button "Tab" of me to pLabel & "*"
   end if
   
   if the formattedWidth of button "Tab" of me <= the width of button "Tab" of me then
      set the label of button "Tab" of me to pLabel
      set the textStyle of me to tOldTextStyle
      exit cLabel
   end if
   
   # We are going to truncate the label to make it fit, initially we remove either the last word
   # or the last three chars to make room for the "..."
   local tLabel
   put pLabel into tLabel
   if the last char of tLabel is "*" then
      delete the last char of tLabel
   end if
   
   delete char -3 to -1 of tLabel
   
   # We put just the "..." after the label, but we test using "*..." (unless there's already a * there)
   local tPostfix
   put "*..." into tPostfix
   
   # Note that we allow room for the label and an additional "*" char,
   # which is appended to the label to signify that the tab's script has been edited.
   set the label of button "Tab" of me to tLabel & tPostfix
   
   repeat until (the formattedWidth of button "Tab" of me <= the width of button "Tab" of me) or (tLabel is empty)
      delete char -1 of tLabel
      set the label of button "Tab" of me to tLabel & tPostfix
   end repeat
   
   if the last char of pLabel is not "*" then
      delete the first char of tPostfix
   end if
   
   set the label of button "Tab" of me to tLabel & tPostfix
   set the textStyle of me to tOldTextStyle
   
   unlock screen
end cLabel

setProp cTooltip pTooltip
  set the tooltip of button "Tab" of me to pTooltip
end cTooltip

setProp cBackgroundColor pColor
   set the backgroundColor of button "Tab" of me to pColor
end cBackgroundColor

getProp cFormattedWidth
   # When tabs are highlighted, their textStyle is set to bold, we need to ensure the tab is
   # big enough to hold its text when it is highlighted without resizing, so we temporarily
   # set the textStyle to bold before getting the formattedWidth. We also allow a small amount
   # extra as it looks better. In addition to this, tabs are given an extra char sometimes to indicate
   # their state (e.g. a * for edited). We have to take this into account when sizing.
   local tWidth
   lock screen
   
   # Because the tabs automatically truncate the text to make it fit, we
   # temporarily set the text back to the original label before returning the formatted width.
   local tOldLabel
   put the label of button "Tab" of me into tOldLabel
   
   local tOldTextStyle
   put the textStyle of me into tOldTextStyle
   set the textStyle of me to "bold"
   if the last char of the label of button "Tab" of me is not "*" then
      set the label of button "Tab" of me to the label of button "Tab" of me & "*"
   end if
   put the formattedWidth of button "Tab" of me + the width of button "Tab Icon" of me  + kIconOffset into tWidth
   set the textStyle of me to tOldTextStyle
   set the label of button "Tab" of me to tOldLabel
   unlock screen
   
   return tWidth
end cFormattedWidth
  

setProp cIcon pImageId
   # Remove the if, its only there for development
   if there is a button "Tab Icon" of me then
      set the icon of button "Tab Icon" of me to pImageId
   end if
end cIcon

setProp cOverIcon pImageId
   if there is a button "Tab Icon" of me then
      set the hoverIcon of button "Tab Icon" of me to pImageId
   end if
end cOverIcon
   





