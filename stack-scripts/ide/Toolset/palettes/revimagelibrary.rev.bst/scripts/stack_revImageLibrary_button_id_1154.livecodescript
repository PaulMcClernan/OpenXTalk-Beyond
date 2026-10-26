script "stack_revImageLibrary_button_id_1154"
-- Stack file: ide/Toolset/palettes/revimagelibrary.rev
-- Object: stack "revImageLibrary" > card "Objects" (id 1150) > group "Buttons" (id 1167) > button "Add Selected" (id 1154)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  put the cStackName of fld "objects list" into tStackName
  if (the selObj) is empty then exit mouseUp
  put (the selObj) into tList
  set the defaultStack to tStackName
  
  repeat for each line l in tList
    if word 1 of l is not in "playerimagescrollbar" then
      if the label of l is not empty then 
        put the label of l into tText
      else 
        put the short name of l into tText
      end if
    else put the short name of l into tText
    if tText is among the lines of fld "objects list" of stack "revImageLibrary" then
      repeat until tText is not among the lines of fld "objects list" of stack "revImageLibrary"
        if last char of tText is a number then add 1 to last char of tText
        else put "1" after tText
      end repeat
    end if
     
    lock messages
    create card tText
    copy l to card tText
    unlock messages
     
    --    repeat with i = 1 to the number of controls on cd tText
    --      set the cREVOrigColors of control i of cd tText to the colors of control i of cd tText
    --      put the effective colors of control i of cd tText into tColors
    --      disable control i of cd tText
    --      set the colors of control i of cd tText to tColors
    --    end repeat
  end repeat
   
  compact stack tStackName
  save stack tStackName
  set the defaultStack to "revImageLibrary"
   
  send "menuPick" && the label of btn "library chooser" to btn "Library chooser"
end mouseUp
