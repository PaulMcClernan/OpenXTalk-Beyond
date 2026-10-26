script "stack_revOnline_group_id_327467"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "search list scrollbar" (id 327465) > group "Slider" (id 327467)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseEnter
  set the hilite of button "slider_icon" of me to true
  pass mouseEnter
end mouseEnter

on mouseLeave
  set the hilite of button "slider_icon" of me to false
  pass mouseLeave
end mouseLeave
