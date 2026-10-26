script "stack_mobileTemplate_group_id_1018"
-- Stack file: ide/Resources/Start Center/samples/sample_3/mobileTemplate.livecode
-- Object: stack "mobileTemplate" > card "template" (id 1868) > group "nav" (id 1018)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local sNavData
local sSelected

################################################
# PROPERTY SETTERS
################################################

setprop navigationItems pNavItemData
   lock screen
   
   set the cNavItems of me to pNavItemData
   local tName, tCard, tIconImagePath, x
   
   put empty into sNavData
   put empty into sSelected
   put 1 into x
   repeat for each line tNavItem in pNavItemData
      put item 1 of tNavItem into tCard
      put item 2 of tNavItem into tIconImagePath
      
      if tCard is not empty and tIconImagePath is not empty then
         put tCard into sNavData[x]["card"]
         put tIconImagePath into sNavData[x]["path"]
         add 1 to x
      end if
   end repeat
   
   //if the environment is "development" then
      put "new_nav_item" into sNavData[x]["card"]
      put "add" into sNavData[x]["path"]
   //end if
   
   repeat with x = the number of images of me down to 1
      delete image x of me
   end repeat
   
   set the lockloc of me to true
   set the linesize of the templateimage to 0
   set the resizequality of the templateimage to "best"
   
   local tImagePath
   repeat for each line tNavID in the keys of sNavData
      put imagePathGet() & sNavData[tNavID]["path"] & ".png" into tImagePath
      create image ("image"&tNavID) in me
      
      lock messages
      set the dropshadow["opacity"] of image ("image"&tNavID) of me to 79
      set the dropshadow["size"] of image ("image"&tNavID) of me to 0
      set the dropshadow["distance"] of image ("image"&tNavID) of me to 1
      set the dropshadow["angle"] of image ("image"&tNavID) of me to 270
      unlock messages
      
      
      set the cNavID of image ("image"&tNavID) of me to tNavID
      set the filename of image ("image"&tNavID) of me to tImagePath
   end repeat
   
   resizeControl
   unlock screen
end navigationItems

getprop navigationItems
   return the cNavItems of me
end navigationItems

setprop navigationBackgroundColor pColor
   set the backgroundcolor of graphic "background" of me to pColor
end navigationBackgroundColor

setprop navigationHighlightColor pColor
   set the backgroundcolor of graphic "highlight" of me to pColor
end navigationHighlightColor

setProp navigationSelectedItem pItemName
   if pItemName is not among the lines of the keys of sNavData then exit navigationSelectedItem
   
   put pItemName into sSelected
   resizeControl
end navigationSelectedItem

getProp navigationSelectedItem
   if sSelected is among the lines of the keys of sNavData  then return sSelected
   return line 1 of the keys of sSelected
end navigationSelectedItem

################################################
# POSITIONING
################################################

on resizeControl
   lock screen
   lock messages
   set the lockloc of me to true
   
   set the rect of graphic "background" of me to the rect of me
   
   local tNavItemCount
   put the number of lines of the keys of sNavData into tNavItemCount
   if the environment is not "development" and sNavData[tNavItemCount]["card"] is "new_nav_item" then subtract 1 from tNavItemCount
   
   set the height of graphic "highlight" of me to the height of me
   
   if tNavItemCount > 0 then 
      local tItemWidth
      put the width of me / tNavItemCount into tItemWidth
      set the width of graphic "highlight" of me to tItemWidth
      
      if sSelected is not among the lines of the keys of sNavData then 
         put line 1 of the keys of sNavData into sSelected
      end if
      
      local tImageScale, tImageMaxHeight, tImageMaxWidth, tImageRatio, tLeft
      put 0.60 into tImageScale
      put the height of me * tImageScale into tImageMaxHeight
      put tItemWidth * tImageScale into tImageMaxWidth      
      put the left of me into tLeft
      local x = 1
      repeat for each line tNavID in the keys of sNavData
         
         if the height of image ("image"&tNavID) of me is not tImageMaxHeight then
            set the height of image ("image"&tNavID) of me to tImageMaxHeight
            put the formattedwidth of image ("image"&tNavID) of me / the formattedheight of image tNavID of me into tImageRatio
            set the width of image ("image"&tNavID) of me to tImageMaxHeight * tImageRatio
            
            if the width of image ("image"&tNavID) of me > tItemWidth then set the width of image tNavID of me to tItemWidth
         end if
         
         if the width of image ("image"&tNavID) of me > tImageMaxWidth then
            set the width of image ("image"&tNavID) of me to tImageMaxWidth
            put the formattedheight of image ("image"&tNavID) of me / the formattedwidth of image tNavID of me into tImageRatio
            set the height of image ("image"&tNavID) of me to tImageMaxWidth * tImageRatio
            
            if the width of image ("image"&tNavID) of me > tItemWidth then set the width of image tNavID of me to tItemWidth
         end if
         
         set the loc of image ("image"&tNavID) of me to tLeft + (tItemWidth / 2), item 2 of the loc of me
         add titemWidth to tLeft
         add 1 to x
         if tNavID is sSelected then 
            set the coloroverlay["color"] of image ("image"&tNavID) of me to "white"
            set the coloroverlay["opacity"] of image ("image"&tNavID) of me to 255
            set the loc of graphic "highlight" of me to the loc of image ("image"&tNavID) of me
         else
            set the coloroverlay of image ("image"&tNavID) of me to empty
         end if
      end repeat
   end if
   
   set the lockloc of me to false
   unlock messages
   unlock screen
end resizeControl

private function imagePathGet
   set the itemdel to "/"
   if the environment is "development" then
      return item 1 to -2 of the filename of this stack & "/images/icons/"
   else if the environment is "mobile" then
      return specialfolderpath("engine") & "/images/icons/"
   end if
end imagePathGet

private function iconGetList
   local tIconsFiles, tIcons
   set the defaultfolder to imagePathGet()
   put the files into tIconsFiles
   set the itemdel to "."
   repeat for each line tIconFile in tIconsFiles
      if char 1 of tIconFile is "." then next repeat
      if the last item of tIconFile is not "png" then next repeat
      
      put item 1 to -2 of tIconFile & comma & " " after tIcons
   end repeat 
   delete the last char of tIcons
   return tIcons
end iconGetList

on mouseUp
   // First we need to work out where they clicked on the group
   if the mouseloc is not within the rect of me then exit mouseUp
   
   local tClickXPos, tGroupWidth, tNavItemCount, tXRatio, tSelectedNavItem, tNavItemList
   put item 1 of the mouseloc into tClickXPos
   put the width of me into tGroupWidth
   put the keys of sNavData into tNavItemList
   
   put the number of lines of the keys of sNavData into tNavItemCount
   if the environment is not "development" and sNavData[tNavItemCount]["card"] is "new_nav_item" then subtract 1 from tNavItemCount
   
   
   
   put tClickXPos / tGroupWidth into tXRatio
   put trunc(tNavItemCount * tXRatio) + 1 into tSelectedNavItem
   
   local tNavID
   put line tSelectedNavItem of tNavItemList into tNavID
   
   if tNavID is a number then
      if tNavID is tNavItemCount and the environment is "development" then
         // The user is adding a new item
         local tCard, tIcon
         
         ask "You are creating a new navigation item. Please enter the name of the card you wish to navigate to when this item is clicked"
         if it is empty then exit mouseUp
         put it into tCard
         
         local tIcons
         put iconGetList() into tIcons
         ask "You must also specify the icon to be used by the nav bar. This must be one of the following:" & return & tIcons
         if it is empty then exit mouseUp
         if (" " & it) is not among the items of tIcons then exit mouseUp
         put it into tIcon
         
         local tNavItems
         put the navigationItems of me into tNavItems
         put return & tCard & comma & tIcon after tNavItems
         set the navigationItems of me to tNavItems
      end if
      // Make sure the stack has been setup
      if sNavData is empty then
         preOpenStack
         exit mouseUp
      end if
      
      # Don't navigate if we are already on the card
      if tNavID is the navigationSelectedItem of me then exit mouseUp
      
      set the navigationSelectedItem of me to tNavID
      lock screen for visual effect in rect the contentRect of this stack
      
      if there is not a card sNavData[tNavID]["card"] then
         create card sNavData[tNavID]["card"]
         set the script of card sNavData[tNavID]["card"] to the cNewCardScript of this stack
         send "preOpenCard" to card sNavData[tNavID]["card"]
      end if
      set the cNavID of card sNavData[tNavID]["card"] to tNavID
      go to card sNavData[tNavID]["card"]
      unlock screen with visual effect "push left" very fast
   end if
end mouseUp
   
