script "stack_RecentStacksAsGallery_card_id_1002"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > substack "RecentStacksAsGallery" > card (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on idle
   if the backgroundColor of btn "test" is green then
      if the shiftkey is down then exit idle
      set the backgroundColor of btn "test" to "red"
      opencard
   end if
end idle

on redrawMainGroup
   if there is a group "mainGroup" of card 1 of this stack then
      delete group "mainGroup" of card 1 of this stack
   end if
   if there is a group "thumbgroup" of card 1 of this stack then
      delete group "thumbgroup" of card 1 of this stack
   end if
   if there is a field "scroller" then delete field "scroller"
   
   --
   create group "mainGroup" in card 1 of this stack -- maingroup is where we create our thumbs
   create group "thumbgroup" in card 1 of this stack -- maingroup is where we create our thumbs
   set the clipsToRect of group "thumbgroup" to true
   
   set the width of group "mainGroup" to the width of this stack
   set the height of group "mainGroup" to the height of this stack
   set the width of group "thumbgroup" to the width of this stack
   set the height of group "thumbgroup" to the height of this stack
   set the topleft of group "thumbgroup" to 0,0
   --
   put the width of this stack / 4 into mySubWidth
   subtract 10 from mySubWidth
   -- set our previews directory
   put specialFolderPath("Documents") & slash & "OXTRecentStacks" into tRecentFolder
   create folder tRecentFolder
   --
   put the number of lines of field "stackData" into thumbCount
   put 0 into tCount
   put 10 into myOffset
   put 0 into myHOffset
   put 0 into myVOffset
   put the left of group "mainGroup" into myOffset
   if there is a field "scroller" then put "" into field "scroller"
   
   repeat thumbCount
      set the itemdelimiter to "*|*"
      add 1 to tCount
      
      put line tCount of field "stackData" into myData
      put item 1 of myData into myShortFileName
      put item 2 of myData into myLongFileName
      put tCount & "_GalleryThumb" into myImageName
      put tCount & "_GalleryCaption" into myBtnName
      put tCount & "_GalleryItem" into mySnapName
      
      create image myImageName in group "mainGroup"
      create button myBtnName in group "mainGroup"
      
      put myShortFileName into myPNGPreview
      set the itemdelimiter to "."
      put the last item of myPNGPreview into myFileExt
      replace "oxtstack" with "png" in myFileExt
      replace "livecode" with "png" in myFileExt
      replace "rev" with "png" in myFileExt
      put myFileExt into last item of myPNGPreview
      put tRecentFolder & slash & myPNGPreview into myPreviewLongFilename
      
      if there is a file myPreviewLongFilename then
         set the filename of image myImageName to myPreviewLongFilename
      else
         -- preview doesn't exist
         set the text of image myImageName to the text of image "missing-preview"
      end if
      -- resize proportionally
      put the width of image myImageName into tW
      put the height of image myImageName into tH
      put 400 / tW into tScaleW
      put 200 / tH into tScaleH
      put min(tScaleW, tScaleH) into tScale
      set the width of image myImageName to round(tW * tScale)
      set the height of image myImageName to round(tH * tScale)
      put myHOffset + the width of image myImageName into myHOffset
      --
      -- I want better quality
      set the resizeQuality of image myImageName to "best"
      --
      set the left of image myImageName to myOffset
      -- style caption
      set the style of button myBtnName to "opaque"
      set the autoHilite of button myBtnName to false
      set the textAlign of button myBtnName to center
      set the backgroundColor of button myBtnName to Yellow
      set the foregroundColor of button myBtnName to black
      set the textStyle of button myBtnName to Bold
      set the label of button myBtnName to myShortFileName
      --set the width of button myBtnName to (the width of image myImageName -20) -- this makes each caption slightly shorter than the imagem but...
      put the width of image myImageName into myMaxWidth
      put the label of button myBtnName into myTextCalc
      put the number of chars in myTextCalc into myTextCalc
      put 9 * myTextCalc into myCalcWidth
      if myCalcWidth > myMaxWidth then put myMaxWidth into myCalcWidth
      set the width of button myBtnName to myCalcWidth
      
      -- position caption
      set the bottom of button myBtnName to the bottom of image myImageName
      set the left of button myBtnName to the left of image myImageName + (the width of image myImageName /2) - the width of button myBtnName /2 
      
      set the topleft of group "mainGroup" to 10,10
      -- export
      put specialFolderPath("Temporary") & slash & "OXTThumb" into myTmpFolder
      create folder myTmpFolder
      put mySnapName & ".png" into myShortTempFile
      put myTmpFolder & slash & myShortTempFile into myTempFile
      export snapshot from group "maingroup" to file myTempFile as png
      if there is an image myShortTempFile of this card then delete image myShortTempFile of this card
      import paint from file myTempFile
      hide image myShortTempFile
      --
      set the tooltip of image myShortTempFile to myShortFileName -- tooltips for the image
      set the absStack of image myShortTempFile to myLongFileName -- property for the stack to open
      -- cleanup
      delete button myBtnName
      delete image myImageName
      -- add imageSource
      if there is a field "scroller" then
         -- ignore
      else
         create field "scroller" in group "thumbgroup"
         put the name of field "scroller" into myNewName 
         put "" into field myNewName
         
         --
      end if
      set the width of field myNewName to the width of this stack
      set the height of field myNewName to the height of this stack -30
      set the textHeight of field myNewName to 220
      set the opaque of field myNewName to false
      set the showborder of field myNewName to false
      set the locktext of field myNewName to true
      set the showFocusBorder of field myNewName to false
      set the threeD of field myNewName to false
      set the textAlign of field myNewName to center
      set the script of field myNewName to the script of btn "scriptTemplate"
      --
      put "i" after field myNewName
      put the number of chars in field myNewName into tCharToSet
      set the imageSource of char tCharToSet of field myNewName to myShortTempFile
      put myHOffset / the width of stack "RecentStacksAsGallery" into myNumRows
      
   end repeat
   put myNumRows + 0.5 into myNumRows
   put round(myNumRows) into myNumRows
   add 1 to myNumRows
   put 240 * myNumRows into myNewFieldHeight
   put the top of field "scroller" into myOldTop
   set the height of field "scroller" to myNewFieldHeight
   set the top of field "scroller" to myOldTop
   -- cleanup
   delete group "maingroup"
   --
   set the itemdelimiter to ","
   set the vScrollbar of group "thumbgroup" to true -- we have to do this last, otherwise groups get confused!
   set the vScroll of group "thumbgroup" to 0
   
   -- the refresh icon
   if the systemAppearance is "dark" then
      set the icon of button "Refresh" of this card to 225202
   else
      set the icon of button "Refresh" of this card to 225203
   end if
   set the layer of button "Refresh" to top
end redrawMainGroup

   
on updateRecentList
   local tRecentStacks, tRecentList
   get revIDERecentStacks() 
   put it into tRecentStacks
   local tStackInfo
   repeat with x = 1 to the number of elements in tRecentStacks
      put tRecentStacks[x] into tStackInfo
      put tStackInfo["label"] & "*|*" & tStackInfo["filename"] & return after tRecentList
   end repeat
   delete the last char of tRecentList
   filter lines of tRecentList without "*toolset*"
   filter lines of tRecentList without "*.app*"
   filter lines of tRecentList without empty
   put "" into field "stackData"
   put tRecentList into field "stackData"
end updateRecentList

on opencard
   choose browse tool
   set cursor to watch
   lock screen
   updateRecentList
   redrawMainGroup
   unlock screen
end opencard

on closecard
   if there is a group "mainGroup" of card 1 of this stack then
      delete group "mainGroup" of card 1 of this stack
   end if
   if there is a group "thumbgroup" of card 1 of this stack then
      delete group "thumbgroup" of card 1 of this stack
   end if
   if there is a field "scroller" then delete field "scroller"
   --
   put the number of images of this card into myCleanupCount
   put myCleanupCount into myReverseCleanup
   repeat myCleanupCount
      if the short name of image myReverseCleanup of this card contains "_GalleryItem" then delete image myReverseCleanup of this card
      subtract 1 from myReverseCleanup
   end repeat
   --
   set the backgroundColor of btn "test" to "green"
   
end closecard
