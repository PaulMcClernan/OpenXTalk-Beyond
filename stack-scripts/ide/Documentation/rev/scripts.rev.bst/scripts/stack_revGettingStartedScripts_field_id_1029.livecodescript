script "stack_revGettingStartedScripts_field_id_1029"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Show or hide a scrollbar automatically as text is entered in a field Example" (id 1028) > field "Example" (id 1029)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on rawKeyDown
  if the formattedHeight of me > the height of me then
    -- there's too much text to fit, so show a scrollbar:
    set the vScrollbar of me to true
  else -- text will fit without scrolling
    -- get rid of the scrollbar
    set the vScrollbar of me to false
  end if
  pass rawKeyDown -- let the keystroke be processed normally
end rawKeyDown 
