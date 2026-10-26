script "stack_revSaving_card_id_1001"
-- Stack file: ide/Toolset/palettes/revsaving.livecode
-- Object: stack "revSaving" > card (id 1001)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenStack
   revCheckSaveStackRect
   pass preOpenStack
end preOpenStack

setProp cSavingStack tStackName
   lock messages
   
   set the defaultStack to "revSaving"
   put revIDELocalise("Saving stack") && tStackName into field 1
   put the mainStack of stack tStackName into tMainStack
   put the substacks of stack tMainStack into tSubStacks
   
   repeat for each line l in tSubStacks
      put tab & tab & tab & l & cr after tSubTabbed
   end repeat
   delete char 1 of tSubTabbed
   delete last char of tSubTabbed
   put tSubTabbed into tSubStacks
   
   put revIDELocalise("Saving...") & cr & cr & "Stack:" & tab & tab & tStackName & cr into tOutput
   put revIDELocalise("Main stack:") & tab & tab & tMainStack & cr after tOutput
   put revIDELocalise("Sub stacks:") & tSubStacks & cr after tOutput
   put revIDELocalise("File name:") & tab & tab & the effective fileName of stack tStackName after tOutput
   put tOutput into field 1 of stack "revSaving"
   
   put cr & cr & revIDELocalise("Please wait") after fld 1
   set the width of field 1 to the formattedWidth of field 1 + 8
   set the height of field 1 to the formattedHeight of field 1
   set the topleft of field 1 to 0,0
   set the width of stack "revSaving" to the right of field 1
   set the height of stack "revSaving" to the height of field 1
   set the loc of stack "revSaving" to the loc of stack tStackName
   revCheckSaveStackRect
   unlock messages
end cSavingStack

on revCheckSaveStackRect
   --sanity checking
   lock screen
   if the right of this stack > item 3 of the windowBoundingRect
   then set the right of this stack to item 3 of the windowBoundingRect
   if the left of this stack < item 1 of the windowBoundingRect
   then set the left of this stack to item 1 of the windowBoundingRect
   if the bottom of this stack > item 4 of the windowBoundingRect
   then set the bottom of this stack to item 4 of the windowBoundingRect
   if the top of this stack < item 2 of the windowBoundingRect
   then set the top of this stack to item 2 of the windowBoundingRect
   unlock screen
end revCheckSaveStackRect

on saveCustomIcon
   -- this is where we create a custom icon (which we can only do on MacOS)
   put the pStackCustIcon of stack "revSaving" into tStackFullPath
   set the pStackCustIcon of stack "revSaving" to ""
   --
   put specialFolderPath("Temporary") into myTempDir
   put myTempDir & slash & "OXTCustomIconProcessor" into myTempDir
   create folder myTempDir
   --put myTempDir & return & tStackFullPath -- debug
   put myTempDir & slash & "image.png" into myExportFilename
   delete file myExportFilename -- make sure we create a fresh one
   export snapshot from card 1 of stack tStackFullPath to file myExportFilename as png
   --
   if there is a file myExportFilename then
      -- proceed
      put "cd " & QUOTE & myTempDir & QUOTE & return & ¬
      "mkdir icon.iconset && \" & return & ¬
      "for s in 16 32 128 256 512; do" & return & ¬
      "    sips -z $s $s image.png --out icon.iconset/icon_${s}x${s}.png" & return & ¬
      "    sips -z $((s*2)) $((s*2)) image.png --out icon.iconset/icon_${s}x${s}@2x.png" & return & ¬
      "done && \" & return & ¬
      "iconutil -c icns icon.iconset && \" & return & ¬
      "mkdir iconwork && \"  & return & ¬
      "cp icon.icns iconwork/ && \" & return & ¬
      "cd iconwork && \" & return & ¬
      "sips -i icon.icns" into myIconCmd
      replace "*THESTACKPATH*" with tStackFullPath in myIconCmd
      get shell(myIconCmd)
      -- that makes the icns file, but we aren't done...
      put myTempDir & slash & "icon.icns" into myIcnsFile
      if there is a file myIcnsFile then
         -- okay, continue
         -- got to make sure my icon tool is executable!
         put specialfolderpath("Engine") into myEngine
         set the itemDelimiter to "/"
         put item 1 to -2 of myEngine into myEngine
         put myEngine & slash & "Tools" & slash & "Externals" into myEngine
         put myEngine & slash & "seticon" into mySEIconBinary
         get shell("chmod +x " & QUOTE & mySEIconBinary & QUOTE)
         
         -- now we can tell the icon tool I made to actually do something!
         put (QUOTE & mySEIconBinary & QUOTE & " " & QUOTE & myIcnsFile & QUOTE & " " & QUOTE & tStackFullPath & QUOTE) into mySetIconScript
         
         --put mySetIconScript
         get shell(mySetIconScript)
         
         -- cleanup
         put "cd " & QUOTE & myTempDir & QUOTE & " && rm -R *" into myCmd
         get shell(myCmd)
         
      else
         -- failed to create icns file
         -- cleanup for next time
         put "cd " & QUOTE & myTempDir & QUOTE & " && rm -R *" into myCmd
         get shell(myCmd)
         --
         put revIDELocalise("Error. Couldn't create icns file") into line -1 of field 1 of stack "revSaving"
         wait 2 seconds
      end if
   else
      -- error
      -- cleanup for next time
      put "cd " & QUOTE & myTempDir & QUOTE & " && rm -R *" into myCmd
      get shell(myCmd)
      --
      put revIDELocalise("Error. Couldn't create temp icon file") into line -1 of field 1 of stack "revSaving"
      wait 2 seconds
   end if
end saveCustomIcon
