script "stack_revBrushpopup_group_id_1173"
-- Stack file: ide/Toolset/palettes/tools/revBrushpopup.livecode
-- Object: stack "revBrushpopup" > card "Brushes Card" (id 1001) > group "Brush shapes" (id 1173)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.


# TH-2008-03-12 : Have introduced a custom property to store the selected brush type which is set on mouse enter
# the appropriate brush is then set to this on stack close.  This remedies a problem with stack panels not
# receiving mouseUp messages.

on mouseEnter
  set the defaultStack to "revBrushPopup"
  if the short name of the owner of the target is "Brush shapes" then 
    set the cBrushShape of this stack to the number of the target
    set the loc of grc "marquee" to the loc of the target
  end if
end mouseEnter

on mouseUp
   close this stack
end mouseUp
