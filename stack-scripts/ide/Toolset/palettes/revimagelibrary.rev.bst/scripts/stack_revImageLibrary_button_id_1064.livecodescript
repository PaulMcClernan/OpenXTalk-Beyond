script "stack_revImageLibrary_button_id_1064"
-- Stack file: ide/Toolset/palettes/revimagelibrary.rev
-- Object: stack "revImageLibrary" > card "Images" (id 1002) > button "library chooser" (id 1064)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  send "menuPick" && quote & the label of me & quote to me
end mouseUp

on mouseRelease
  mouseUp
end mouseRelease

on menuPick pWhich
  lock screen
  if pWhich is "-" or pWhich begins with "(" then
    beep
    set the label of me to line 1 of the text of me
    put the label of me into pWhich
 end if
 
  put revLibraryStackName(pWhich) into tStackName
  
  if the label of me is among the items of "Standard Images,MetaCard Compatible Icons,Cursors,-" or word 1 to 2 of the label of me is "This Stack"  then
    disable btn "Delete..."
  else
    enable btn "Delete..."
  end if
  
  
  if word 2 of the selectedLine of me is "4" and the num of cds in stack tStackName > 10
  then set the cursor to watch
  lock cursor
  
  put empty into tIDsList
  set the defaultStack to tStackName
  repeat with c = 1 to the number of cds
    repeat with i = 1 to the number of images in cd c
      if the id of image i of cd c is not among the lines of tIDsList then
        put the id of image i of cd c & cr after tIDsList
      end if  
    end repeat
  end repeat
  delete last char of tIDsList
  set the defaultStack to "revImageLibrary"
  set the cIconsList of this cd to tIDsList
  repeat with i = 1 to 30
    set the icon of btn i of group "images in library" to line i of tIDsList
  end repeat
  set the pageIncrement of scrollbar 1 to 10
  set the lineIncrement of scrollbar 1 to 10
  put the number of lines in tIdsList into tLines
  if tLines < 1 then put 1 into tLines
  
  # TH-2008-01-14 : Bug fix 3032
  local tRound
  put trunc(tLines/10) * 10 into tRound
  set the endValue of scrollBar 1 to tRound - 9
  
  set the thumbSize of sb 1 to 10
  set the lineInc of sb 1 to 10
  set the pageInc of sb 1 to 10
  set the thumbPosition of sb 1 to 0
  revUpdatePalette
  disable btn "insert image into stack"
  disable btn "insert reference into stack"
  disable btn "delete...1"
  --put empty into fld "image id"
  set the loc of grc "marquee" to -200,-200
  unlock cursor
  unlock screen
end menuPick

on mouseDown
  put the text of me into tText
  if the mode of the topStack is not 1 then put "(This Stack" into line 4 of tText
  else put "This Stack -" && the short name of the topStack into line 4 of tText
  set the text of me to tText
end mouseDown

on mouseEnter
  
end mouseEnter
