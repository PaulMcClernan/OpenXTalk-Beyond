script "stack_revIconChooser_button_id_1064"
-- Stack file: ide/Toolset/palettes/reviconchooser.rev
-- Object: stack "revIconChooser" > card (id 1002) > button "library chooser" (id 1064)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local lLabel

on mouseUp
  exit mouseUp
end mouseUp

on mouseDown
  put the label of me into lLabel
end mouseDown

on menuPick pWhich
  if pWhich is empty then
    set the label of me to lLabel
    exit menuPick
  end if
  
  if char 1 to 6 of pWhich is "revLib" then put char 7 to -1 of pWhich into pWhich
  else if char 1 to 3 of pWhich is "rev" then put char 4 to -1 of pWhich into pWhich
  if pWhich is "Standard icons" then 
    put "revGeneralIcons" into tStackName
  else if pWhich is "MetaCard Compatible Icons" then 
    put "revCompatibilityIcons1" into tStackName
  else if pWhich is "MetaCard Compatible Patterns" then
    put "revCompatibilityPatterns1" & cr & "revCompatibilityPatterns2" into tStackName
  else if pWhich is "default patterns" then
    put "revGeneralPatterns" into tStackName
  else if pWhich is "this stack" then
    put the short name of the topStack into tStackName
  else put "revLib" & pWhich into tStackName
  
  put empty into tIDsList
  repeat for each line l in tStackName
    set the defaultStack to l
    repeat with c = 1 to the number of cds
      repeat with i = 1 to the number of images in cd c
        put the id of image i of cd c into tID
        if tID is not among the lines of tIDsList
        then put tID & cr after tIDsList
      end repeat
    end repeat
  end repeat
  --also check bgs that haven't been placed
  repeat with b = 1 to the num of bgs
    if the num of cds in bg b is 0 then
      repeat with i = 1 to the num of images in bg b
        put the id of image i of bg b into tID
        if tID is not among the lines of tIDsList
        then put tID & cr after tIDsList
      end repeat
    end if
  end repeat
  delete last char of tIDsList
  
  set the defaultStack to "revIconChooser"
  set the cIconsList of this cd to tIDsList
  repeat with i = 1 to 50
    set the icon of btn i to line i of tIDsList
    set the toolTip of btn i to the icon of btn i
  end repeat
  set the pageIncrement of scrollbar 1 to 10
  set the lineIncrement of scrollbar 1 to 10
  put the number of lines in tIdsList - 40 into tLines
  if tLines < 1 then put 1 into tLines
  
  # TH-2008-01-14 : Bug fix 3032
  local tRound
  put trunc(tLines/10) * 10 into tRound
  set the endValue of scrollBar 1 to tRound + 10

  set the thumbSize of sb 1 to 10
  set the lineInc of sb 1 to 10
  set the pageInc of sb 1 to 10
end menuPick
