script "stack_revResourceCenter_group_id_540871"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Textmenu:populatingwithcontent" (id 82654) > group (id 2127) > group "Actions" (id 540871)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local sProgressBarWidth, sLeftLocation

command update
   if the cLeftType of me is not empty and the cLeftType of me is not "video" then
      set the icon of button "Icon" of group "Left" of me to the cLeftIcon of me
      if resourceAvailable(the cLeftType of me, the cLeftName of me) then
         set the text of field "Label" of group "Left" of me to "Launch " & resourceTypeToFriendlyName(the cLeftType of me)
      else
         set the text of field "Label" of group "Left" of me to "Download " & resourceTypeToFriendlyName(the cLeftType of me)
      end if
      show group "Left" of me
   else
      hide group "Left" of me
   end if
   
   if the cRightType of me is not empty then
      
      set the icon of button "Icon" of group "Right" of me to the cRightIcon of me
      if resourceAvailable(the cRightType of me, the cRightName of me) then
         if the cRightType of me is "script" then
            set the text of field "Label" of group "Right" of me to "Copy " & resourceTypeToFriendlyName(the cRightType of me)
         else
            set the text of field "Label" of group "Right" of me to "Launch " & resourceTypeToFriendlyName(the cRightType of me)
         end if
      else
         set the text of field "Label" of group "Right" of me to "Download " & resourceTypeToFriendlyName(the cRightType of me)
      end if
      
      if the cRightType of me is "script" then
         set the tooltip of field "Label" of group "Right" of me to "Copy the example objects to the clipboard"
      else
         set the tooltip of field "Label" of group "Right" of me to empty
      end if
      
      show group "Right" of me
   else
      hide group "Right" of me
   end if
end update

# OK-2008-08-15 : Abstracted in order to fix problem where "Pdf" was displayed instead of "PDF"
private function resourceTypeToFriendlyName pType
   if pType is "PDF" then
      return "PDF"
   end if
   
   return (toUpper(char 1 of pType) & char 2 to -1 of pType)
end resourceTypeToFriendlyName

command updateProgress pPercentage
   --log "pPercentage IS: " & pPercentage
   local tRoundedPercentage
   put trunc(sProgressBarWidth * pPercentage)into tRoundedPercentage
   put tRoundedPercentage div 100 into tRoundedPercentage
   set the width of graphic "ProgressBarGraphic" to tRoundedPercentage
   set the left of graphic "ProgressBarGraphic" to sLeftLocation
   if tRoundedPercentage >= sProgressBarWidth then
      --set the right of scrollbar "Progress" of me to the left of me - 500
      --set the right of graphic "ProgressBarGraphic" of me to the left of me - 500
      --put 0 into sProgressBarWidth
   end if
end updateProgress


on mouseUp
   local tType, tName
   
   local tCardName
   put the short name of this card into tCardName
   if the cRightType of me is "script" then
      set the lockLocation of group "Example" to false
      copy group "Example"
      set the lockLocation of group "Example" to true
      exit mouseUp
   end if
   
   
   if the short name of the owner of the target is "Left" then
      put the cLeftType of me into tType
      put the cLeftName of me into tName
   end if
   
   if the short name of the owner of the target is "right" then
      put the cRightType of me into tType
      put the cRightName of me into tName
   end if
   
   if tName is empty or tType is empty then
      exit mouseUp
   end if
   
   if resourceAvailable(tType, tName) then
      resourceLaunch tType, tName
   else
      resourceDownload tType, tName
      
      set the location of stack "revRCDownloadProgress" to the location of this stack
      modal stack "revRCDownloadProgress"
      
      -- need to set the width of the progressbargraphic
      --      put the formattedWidth of field 1 of the owner of the target - \
      --      the leftmargin of field 1 of the owner of the target - \
      --      the rightmargin of field 1 of the owner of the target into sProgressBarWidth
      
      
      --      if the short name of the owner of the target is "Left" then
      --         put the left of field 1 of group "Left" of me + the leftmargin of field 1 of group "Left" into sLeftLocation
      --         set the left of graphic "ProgressBarGraphic" of me to sLeftLocation
      --      else 
      --         put the left of field 1 of group "Right" of me + the leftmargin of field 1 of group "Right" into sLeftLocation
      --         set the left of graphic "ProgressBarGraphic" of me to sLeftLocation
      --      end if
      --      set the width of graphic "ProgressBarGraphic" to 0
      --      set the top of graphic "ProgressBarGraphic" to the bottom of field 1 of the owner of the target + 5
      --      updateProgress 0
   end if
end mouseUp



