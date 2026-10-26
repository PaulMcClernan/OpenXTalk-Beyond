script "stack_revImageLibrary_field_id_1137"
-- Stack file: ide/Toolset/palettes/revimagelibrary.rev
-- Object: stack "revImageLibrary" > card "Objects" (id 1150) > field "objects list" (id 1137)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on arrowKey
  send "mouseUp" to me in 10 milliseconds
  pass arrowKey
end arrowKey
   
on mouseUp
  lock messages
  lock screen
  repeat with i = 1 to the number of controls in group "object preview"
    if there is a control 1 of group "object preview" then delete control 1 of group "object preview"
  end repeat
  put the name of this stack into tLibStackName
  put the cStackName of me into tStackName
  if tStackName is empty then
    disable btn "Delete1"
    disable btn "Delete"
    disable btn "Insert Into Stack"
    exit mouseUp
  end if
  enable btn "Delete"
  enable btn "Delete1"
  enable btn "Insert Into Stack"
  set the defaultStack to tStackName
  put line (the hilitedLines of me) of me into tCard
  --put tCard into fld "name" of stack tLibStackName
  if tCard is empty then
    set the defaultStack to tLibStackName
    put empty into fld "description"
    --disable fld "name"
    disable fld "description"
    disable btn "delete1"
    disable btn "insert into stack"
    disable btn "Add Selected"
    unlock screen
    exit mouseUp
  else
    set the defaultStack to tLibStackName
    --enable fld "name"
    enable btn "Add Selected"
    enable fld "description"
    enable btn "delete1"
    enable btn "insert into stack"
  end if
  set the defaultStack to tStackName
  put the cDescription of cd tCard of stack tStackName into fld "description" of stack tLibStackName
  import snapshot from control 1 of card tCard
  copy last image to group "object preview" of stack tLibStackName
  delete last image
  set the defaultStack to tLibStackName
  if the width of image 1 of group "object preview" > the width of group "object preview" or the height of image 1 of group "object preview" > the height of group "object preview" then
    set the resizeQuality of image 1 of group "object preview" to "best"
    
    put the width of image 1 of group "object preview" into tWidth
    put the height of image 1 of group "object preview" into tHeight
    if tWidth > tHeight then
      put (the width of group "object preview" - 4) / tWidth into tRatio
    else
      put (the height of group "object preview" - 4) / tHeight into tRatio
    end if
    set the width of image 1 of group "object preview" to tWidth * tRatio
    set the height of image 1 of group "object preview" to tHeight * tRatio
    
    --set the rect of image 1 of group "object preview" of stack tLibStackName to the rect of group "object preview" of stack tLibStackName
    set the loc of image 1 of group "object preview" to the loc of group "object preview"
    
    set the lockLocation of image 1 of group "object preview" to true
  else
    set the loc of image 1 of group "object preview" to the loc of group "object preview"
  end if
  unlock screen
end mouseUp
