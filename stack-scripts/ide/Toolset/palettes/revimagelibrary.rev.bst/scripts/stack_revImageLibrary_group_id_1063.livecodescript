script "stack_revImageLibrary_group_id_1063"
-- Stack file: ide/Toolset/palettes/revimagelibrary.rev
-- Object: stack "revImageLibrary" > card "Images" (id 1002) > group "Images In Library" (id 1063)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  if word 1 of the name of the target is "button" and the icon of the target is not 0 then 
    set the rect of grc "marquee" to the rect of the target
    set the cObject of grc "marquee" to the long id of the target -- resize stack
    enable btn "insert image into stack"
    enable btn "insert reference into stack"
    put the icon of the target into fld "image id"
    if the label of btn "library chooser" is not among the items of "Standard Images,Classic Images,Cursors" then enable btn "delete...1"
  end if
end mouseUp
