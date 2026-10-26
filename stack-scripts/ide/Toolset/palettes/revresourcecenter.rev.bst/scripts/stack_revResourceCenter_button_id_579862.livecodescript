script "stack_revResourceCenter_button_id_579862"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Poppingupamenuafteradelaytimer" (id 80366) > group "mainContent" (id 80378) > group (id 579865) > group "Example" (id 577036) > button "Color" (id 579862)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local didPopUpMenu -- keeps track of whether the menu was popped up

on mouseDown
  put false into didPopUpMenu -- start out by assuming no menu
  send "popGoesTheMenu" to me in 2 seconds
end mouseDown

on popGoesTheMenu theLocation
  -- The menu will pop up only if the user is still pressing
  -- the mouse over the button after 2 seconds:
  if the mouse is up \
     or the mouseLoc is not within the rect of me \
     then exit popGoesTheMenu
  put true into didPopUpMenu -- skip the mouseUp actions
  popup button "Colors" -- the hidden popup menu
end popGoesTheMenu

on mouseUp
  -- if the user popped up the menu, don't do the click action
  if didPopUpMenu then pass mouseUp
  -- if there is a text selection, set its color:
  if the short name of the selectedField is "Example Text" then
    set the textColor of the selectedChunk \
       to (last word of the label of me)
  end if
end mouseUp
