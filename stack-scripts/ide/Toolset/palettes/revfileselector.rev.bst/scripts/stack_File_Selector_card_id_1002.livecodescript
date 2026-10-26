script "stack_File_Selector_card_id_1002"
-- Stack file: ide/Toolset/palettes/revfileselector.rev
-- Object: stack "File Selector" > card "File Selector Card" (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on help
  go to card "File Selector" of stack "Dialog Box Help" as modeless
end help

on refresh
  local filterstring, fnames
  set the cursor to watch
  lock screen
  set the itemDelimiter to "/"
  if the number of items in field "Directory" > 1 and the last char of field "Directory" is not "/"
  then put the last item of field "Directory" into filterstring
  if filterstring is empty then put "*" into filterstring
  put the directory into field "Directory"
  if the last char of field "Directory" is not "/"
  then put "/" after field "Directory"
  put filterstring after field "Directory"
  put the directories into field "Directories"
  if field "Directories" is empty
  then put ".." into field "Directories"
  else sort field "Directories"
  if the visible of field "Files" then
    put the files into fnames
    filter fnames with filterstring
    put fnames into field "Files"
    sort field "Files"
    local dirwidth, filewidth, cwidth
    put max(48, the formattedWidth of field "Directories") into dirwidth
    put max(48, the formattedWidth of field "Files") into filewidth
    put max(the formattedWidth of field "Directory" + 16, dirwidth + filewidth + 24, 250) into cwidth
    set the width of field "Directories" to dirwidth
    set the width of field "Files" to filewidth
    set the left of field "Files" to the right of field "Directories" + 8
    set the left of field "Flabel" to max(the right of field "Dlabel", the left of field "Files" - 8)
  else
    set the width of field "Directories" to 304
    put 320 into cwidth
  end if
  set the width of this stack to cwidth
  local twidth, perspace, toffset
  repeat with i = 1 to the number of buttons
    add the width of button i to twidth
  end repeat
  put (cwidth - twidth) / 5 into perspace
  put perspace into toffset
  repeat with i = 1 to the number of buttons
    set the left of button i to round(toffset)
    add the width of button i + perspace to toffset
  end repeat
  set the width of field "Directory" to cwidth - 16
  set the width of field "Selection" to cwidth - 32
  set the scroll of field "Directories" to 0
  unlock screen
end refresh

on returnKey
  send "mouseUp" to button id 1013
end returnKey

on escapeKey
  send "mouseUp" to button id 1014
end escapeKey

# command, title, prompt, filter, response
on preOpenCard
  set the itemDelimiter to numToChar(0)

  put 1 into tCount
  repeat for each item i in the dialogData
    add 1 to tCount
  end repeat

  if item 2 of the dialogData is empty then
    if word 1 of item 1 of the dialogData is "answer" then
      if word 2 of item 1 of the dialogData is "folder"
      then set the title of this stack to "Choose Directory"
      else set the title of this stack to "Open"
    else set the title of this stack to "Save"
  else set the title of this stack to item 2 of the dialogData
  put item 3 of the dialogData into field "Prompt"

  put the directory & "/" & item 4 of the dialogData into field "Directory"
  put item 5 of the dialogData into field "Selection"
  if word 2 of item 1 of the dialogData is "folder" then
    hide field "Files"
    hide field "Flabel"
    set the name of button id 1013 to "Choose"
  else
    show field "Files"
    show field "Flabel"
    if word 1 of item 1 of the dialogData is "answer"
    then set the name of button id 1013 to "Open"
    else set the name of button id 1013 to "Save"
  end if
  refresh
end preOpenCard

on closeStack
  put empty into field "Directory"
  put empty into field "Directories"
  put empty into field "Files"
  put empty into field "Selection"
  put empty into field "Prompt"
  set the dialogData to empty
end closeStack

on resizeStack
  local cheight
  put the height of this card into cheight
  repeat with i = 1 to 4
    set the bottom of button i to cheight - 12
  end repeat
  set the bottom of field "Selection" to the top of button 1 - 12
  set the bottom of field "Prompt" to the top of field "Selection" - 2
  set the height of field "Directories" to the top of field "Prompt" - 4 - the top of field "Directories"
  set the height of field "Files" to the top of field "Prompt" - 4 - the top of field "Files"
end resizeStack


on openCard
end openCard

on preOpenStack
   local tStackLoc
   local tScreenRect
   put line (the screen of this stack) of the screenRects into tScreenRect
   
   local tScreenWidth
   put item 3 of tScreenRect - item 1 of tScreenRect into tScreenWidth
   
   local tScreenHeight
   put item 4 of tScreenRect - item 2 of tScreenRect into tScreenHeight
   
   put item 1 of tScreenRect + (tScreenWidth div 2),item 2 of tScreenRect + (tScreenHeight div 2) into tStackLoc
   set the loc of this stack to tStackLoc
   reset cursors
   set the cursor to 1
end preOpenStack

on openStack
end openStack

on closeCard
end closeCard
