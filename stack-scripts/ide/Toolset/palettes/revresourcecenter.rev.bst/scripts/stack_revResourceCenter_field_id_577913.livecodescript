script "stack_revResourceCenter_field_id_577913"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Showorhideascrollbarautomaticallyastextisenteredinafield" (id 80261) > group "mainContent" (id 80271) > group (id 577915) > group "Example" (id 577003) > field "Example" (id 577913)
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
