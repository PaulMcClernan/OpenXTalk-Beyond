script "stack_revDocsColor_Names_Reference_button_id_2809"
-- Stack file: ide/Documentation/rev/Color Names Reference.rev
-- Object: stack "revDocsColor Names Reference" > card "Color Chart" (id 1002) > group "revLibraries" (id 2807) > button "revCommon" (id 2809)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

function revTargetStack pWhich
  if pWhich is not empty and there is a pWhich then put the long id of pWhich into tParse
  else put the long id of the target into tParse
  get wordOffset("stack",tParse)
  put word (it) to (it+1) of tParse into tStackName
  put the short name of tStackName into tStackName
  return tStackName
end revTargetstack

on revGoURL pWhich
  put false into tNT
  if (the platform is "Win32") and (word 1 of the systemVersion is "Windows") then
    set the shellCommand to "command.com"
  else if the platform is "Win32" then
    set the shellCommand to "cmd.exe"
    put true into tNT
  end if
  
  if the platform is "Win32" then
    set the hideConsoleWindows to true
    put word 1 of queryRegistry("hkey_local_machine\software\classes\http\shell\open\command\") into tWebBrowserPath
    if not tNT then get shell(tWebBrowserPath && quote & pWhich & quote)
    else get shell(tWebBrowserPath)
  else if the platform is "MacOS" then
    send pWhich to program "Finder" with "GURLGURL" without reply
  else
    get shell("netscape" && quote & pWhich & quote)
  end if
end revGoURL


getProp cREVGeneral[pWhichProp] pWhichProfile
  put the long id of the target into tTarget
  
  if pWhichProp is "revUniqueID" and the cREVGeneral[revUniqueID] of tTarget is empty then
    set the cREVGeneral[revUniqueID] of tTarget to the milliseconds
    return the cREVGeneral[revUniqueID] of tTarget
  else if pWhichProp is "revUniqueID" then
    return the cREVGeneral[revUniqueID] of tTarget
  end if
  
  if pWhichProp is not "profile" then if not gREVSuppressMessages or (gREVSuppressMessages and revOKTarget()) then pass cREVGeneral
  put the cREVGeneral["profile"] of tTarget into tProfile
  if tProfile is empty or tProfile is the cREVGeneral[masterName] of tTarget then put "Master" into tProfile
  return tProfile
end cREVGeneral

setProp cREVGeneral[pWhichProp] pWhichProfile
  put the long id of the target into tTarget
  
  if pWhichProp is not "profile" and pWhichProp is not "inLineImages" and pWhichProp is not "virtualWidth" and pWhichProp is not "virtualHeight" then pass cREVGeneral
  if pWhichProp is "virtualWidth" then
    put the cREVGeneral[virtualWidth] of tTarget into tOriginalWidth
    set the cREVGeneral[virtualWidth] of tTarget to pWhichProfile
    put tOriginalWidth - pWhichProfile into tDifference
    put the rect of stack revTargetStack() into tRect
    put item 3 of tRect + tDifference into item 3 of tRect
    set the rect of stack revtargetStack() to tRect
    exit cREVGeneral
  end if
  if pWhichProp is "virtualHeight" then
    put the cREVGeneral[virtualHeight] of tTarget into tOriginalHeight
    set the cREVGeneral[virtualHeight] of tTarget to pWhichProfile
    put tOriginalHeight - pWhichProfile into tDifference
    put the rect of stack revTargetStack() into tRect
    put item 4 of tRect + tDifference into item 4 of tRect
    set the rect of stack revtargetStack() to tRect
    exit cREVGeneral
  end if
  --inline images next
  if pWhichProp is "inLineImages" then
    if pWhichProfile is true then
      lock messages
      lock screen
      set the lockLocation of the templateGroup to true
      set the rect of the templateGroup to item 1 to 2 of the rect of tTarget,item 3 of the rect of tTarget-the scrollbarWidth of tTarget,item 4 of the rect of tTarget
      set the name of the templateGroup to the short name of tTarget&"images"&the number of this cd
      create group
      reset the templateGroup
      put the short name of tTarget & "images"&the number of this cd into tGroupName
      --now pad the group so it can scroll
      reset the templateGraphic
      set the style of the templateGraphic to "line"
      set the lineSize of the templateGraphic to 0
      set the topLeft of the templateGraphic to the topLeft of tTarget
      create grc in group tGroupName
      reset the templateGraphic
      set the scroll of group tGroupName to 0
      set the scroll of tTarget to 0
      set the cREVGeneral["preInlineText"&the number of this cd] of tTarget to the text of tTarget
      set the itemDel to "/"
      put 0 into tSubtract
      repeat
        if tFinalExit then exit repeat
        put 0 into tLineCount
        set the scroll of group tGroupName to 0
        set the scroll of tTarget to 0
        repeat for each line l in the text of tTarget
          put true into tFinalExit
          add 1 to tLineCount
          if item 2 of l is "*IMAGEFILE*" then
            do "put empty into line tLineCount of" && tTarget
            reset the templateImage
            set the fileName of the templateImage to item 3 to -1 of l
            put the short name of tTarget into tFieldName
            put (the formattedHeight of line 1 to tLineCount of fld tFieldName + the top of tTarget) into tTop
            set the width of the templateImage to the formattedWidth of the templateImage
            put the formattedHeight of the templateImage into tImageHeight
            set the height of the templateImage to tImageHeight
            set the lockLoc of the templateImage to true
            set the topLeft of the templateImage to the left of tTarget+8,tTop-tSubtract
            create image in group tGroupName
            put 0 into tNewLines
            repeat
              add 1 to tNewLines
              put cr after line tLineCount of the target
              if the formattedHeight of line tLineCount to tLineCount+tNewLines of fld tFieldName >= tImageHeight then exit repeat
            end repeat
            put cr after line tLineCount of the target
            put false into tFinalExit
            exit repeat
          end if
          if item 2 of l is "*IMAGEID*" then
            do "put empty into line tLineCount of" && tTarget
            reset the templateButton
            set the showName of the templateButton to false
            set the showBorder of the templateButton to false
            set the traversalOn of the templateButton to false
            set the autoHilite of the templateButton to false
            set icon of the templateButton to item 3 to -1 of l
            put the short name of tTarget into tFieldName
            put (the formattedHeight of line 1 to tLineCount of fld tFieldName + the top of tTarget) into tTop
            set the width of the templateButton to the formattedWidth of the templateButton
            put the formattedHeight of the templateButton into tImageHeight
            set the height of the templateButton to tImageHeight
            set the lockLoc of the templateButton to true
            set the topLeft of the templateButton to the left of tTarget+8,tTop-tSubtract
            create button in group tGroupName
            put 0 into tNewLines
            repeat
              add 1 to tNewLines
              put cr after line tLineCount of the target
              if the formattedHeight of line tLineCount to tLineCount+tNewLines of fld tFieldName >= tImageHeight then exit repeat
            end repeat
            put cr after line tLineCount of the target
            put false into tFinalExit
            exit repeat
          end if
        end repeat
        put 30 into tSubtract
      end repeat
      reset the templateButton
      reset the templateImage
      --now pad the group so it can scroll
      put the formattedHeight of fld tFieldName into tFieldHeight
      reset the templateGraphic
      set the style of the templateGraphic to "line"
      set the lineSize of the templateGraphic to 0
      set the topLeft of the templateGraphic to the left of tTarget,tFieldHeight+the top of tTarget
      create grc in group tGroupName
      reset the templateGraphic
      set the scroll of group tGroupName to 0
      set the scroll of the target to 0
      unlock screen
      unlock messages
    else
      delete group (the short name of tTarget&"images"&the number of this cd)
      set the text of tTarget to the cREVGeneral["preInlineText"&the number of this cd] of tTarget
      set the cREVGeneral["preInlineText"&the number of this cd] of tTarget to empty
    end if
    set the cREVGEneral["inLineImages"&the number of this cd] of tTarget to pWhichProfile
    exit cREVGeneral
  end if
  global gREVProfileReadOnly, gREVAutoCreateProfiles
  lock screen
  lock messages
  put the customPropertySet of tTarget into tReturnSet
  set the cREVGeometryCache[order] of this cd to empty
  if pWhichProfile is not empty and pWhichprofile is not "master" and pWhichProfile is not the cREVGeneral[masterName] of tTarget and pWhichProfile is not among the lines of the cREVGeneral[profileList] of tTarget then
    if gREVAutoCreateProfiles then revNewProfile pWhichProfile, tTarget
    unlock screen
    unlock messages
    exit cREVGeneral
  end if
  if the cREVGeneral[profile] of tTarget is "Master" or the cREVGeneral[profile] of tTarget is empty or the cREVGeneral[profile] of tTarget is the cREVGeneral[masterName] of tTarget then
    --its in master, going out
    if not gREVProfileReadOnly then
      set the customPropertySet of tTarget to cREVTempMaster
      put the properties of tTarget into tTempArray
      set the customProperties of tTarget to tTempArray
    end if
  else
    --its another profile, going into or through master
    set the customPropertySet of tTarget to "cREVMaster"
    if the customKeys[cREVMaster] of tTarget is not empty then put the customProperties of tTarget into tCurrentMasterArray
    if not gREVProfileReadOnly then
      set the customPropertySet of tTarget to "cREVTempMaster"
      put the customProperties of tTarget into tTempMasterArray
      put the properties of tTarget into tCurrentPropertiesArray
      --compare the temporary master with the current properties
      --any changes:
      --the original tempMaster value gets added to the current master array
      --and the new value gets created in the current profile array
      put keys(tCurrentPropertiesArray) into tCurrentPropertyKeys
      set the caseSensitive to true
      repeat for each line l in tCurrentPropertyKeys
        if tTempMasterArray[l] is not tCurrentPropertiesArray[l] then
          put tTempMasterArray[l] into tCurrentMasterArray[l]
          put tCurrentPropertiesArray[l] into tProfileArray[l]
        end if
      end repeat
      --transfer the current profile array to the object
      set the customPropertySet of tTarget to "cREVDiverged" & the cREVGeneral[profile] of tTarget
      set the customProperties of tTarget to tProfileArray
      --now transfer the current master array to the master profile
      set the customPropertySet of tTarget to cREVMaster
      set the customProperties of tTarget to tCurrentMasterArray
    end if
    set the properties of tTarget to tCurrentMasterArray
    set the cREVGeneral[profile] of tTarget to "Master"
  end if
  if pWhichProfile is not empty and pWhichProfile is not "master" and pWhichProfile is not the cREVGeneral[masterName] of tTarget then
    set the cREVGeneral[profile] of tTarget to pWhichProfile
    set the customPropertySet of tTarget to "cREVDiverged"&pWhichProfile
    if the customKeys of tTarget is not empty then put the customProperties of tTarget into tTempArray1
    set the properties of tTarget to tTempArray1
  end if
  set the customPropertySet of tTarget to tReturnSet
  unlock screen
  unlock messages
end cREVGeneral
