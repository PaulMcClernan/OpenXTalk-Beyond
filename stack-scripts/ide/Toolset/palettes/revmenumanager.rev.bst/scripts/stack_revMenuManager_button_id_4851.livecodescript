script "stack_revMenuManager_button_id_4851"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > card "Menu Manager" (id 1002) > group "Menu Items:" (id 3226) > button "Delete Item" (id 4851)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   global gREVActiveMenuButton, gREVMMMenuItems, gREVTextHeight
   if the cAnswerDialog of fld "Menu Name" or the cAnswerDialog of fld "Item Name" then exit mouseUp
   
   lock screen
   --delete menu items
   put the hilitedLines of fld "Menu Items" into tHilitedLines
   put the scroll of fld "Menu Items" into tScroll
   --put the text of gREVActiveMenuButton into tText
   put the unicodetext of gREVActiveMenuButton into tText
   put uniDecode(tText,"UTF8") into tText
   
   put empty into tCounter
   put empty into tReferenceDeduction
   put gREVMMMenuItems into tMMMenuItemsBefore
   put empty into tMMMenuItemsAfter
   put empty into tSubMenusToDelete
   repeat for each line l in tMMMenuItemsBefore
      add 1 to tCounter
      if tCounter is among the items of tSubMenusToDelete then next repeat
      if tCounter is among the items of tHilitedLines then
         --delete this item
         add 1 to tReferenceDeduction
         put "######REVDELETEMENUITEM" into line (item 3 of l) of tText
         
         --if item has submenus, delete them
         if item 1 of l is not empty then
            put true into tDeletingSubMenus
            put (item 3 of l) + 1 into tStartLine
            put the num of lines in tText into tFinishLine
            put empty into tSubMenuCount
            repeat with i = tStartLine to tFinishLine
               if tab is in line i of tText then
                  add 1 to tSubMenuCount
                  put "######REVDELETEMENUITEM" into line i of tText
               else exit repeat
            end repeat
            --delete submenus from variable
            put tCounter + tSubMenuCount into tFinalSubMenuLine
            put tCounter + 1 into tStartSubMenuLine
            if item 1 of l is true then
               --produce list of lines of submenus that need deleted
               --increment subtraction that needs to be made to the references to button contents line number
               repeat with i = tStartSubMenuLine to tFinalSubMenuLine
                  put i & comma after tSubMenusToDelete
                  add 1 to tReferenceDeduction
               end repeat
            else
               --increment subtraction that needs to be made to the references to button contents line number
               repeat with i = tStartSubMenuLine to tFinalSubMenuLine
                  add 1 to tReferenceDeduction
               end repeat
            end if
         end if         
      else
         --if there's no reason to delete this menu item keep it
         put item 1 to 2 of l, (item 3 of l - tReferenceDeduction) & cr after tMMMenuItemsAfter
      end if
   end repeat
   delete last char of tMMMenuItemsAfter
   
   if tDeletingSubMenus then
      beep
      answer warning "One or more of the selected menu items contains submenus.  Deleting it will delete all its submenus.  Are you sure you want to delete it?" with "No" or "Yes"
      if it is not "Yes" 
      then pass mouseUp
   end if
   
   replace "######REVDELETEMENUITEM" & cr with empty in tText
   if the last line of tText is "######REVDELETEMENUITEM" then delete the last line of tText
   --update folded out triangle if all submenus deleted
   put empty into tMMFinalMenuItems
   repeat for each line l in tMMMenuItemsAfter
      if item 1 of l is true and tab is not in line (item 3 of l + 1) of tText
      then put empty, item 2 to 3 of l & cr after tMMFinalMenuItems
      else put l & cr after tMMFinalMenuItems
   end repeat
   delete last char of tMMFinalMenuItems
   put tMMFinalMenuItems into gREVMMMenuItems
   
   
   --update button contents
   --set the text of gREVActiveMenuButton to tText
   --put tText into btn "Preview"  
   set the unicodeText of gREVActiveMenuButton to uniEncode(tText,"UTF8")
   set the unicodeText of button "Preview" to uniEncode(tText,"UTF8")
   
   revUpdateField true
   set the scroll of fld "Menu Items" to tScroll
   revResetTriangles
   revUpdateScrollbar
   
   --update widget
   put (the last item of tHilitedLines - the num of items in tHilitedLines) into tWidgetLine
   set the cREVLine of grp "Item Insert" to tWidgetLine
   if tWidgetLine is 0 then
      set the top of grp "Item Insert" to the top of fld "Menu Items" -7
   else
      put the formattedTop of line tWidgetLine of fld "Menu Items" + 7 into tWidgetTop
      if tWidgetTop > the top of fld "Menu Items" and tWidgetTop < the bottom of fld "Menu Items"
      then set the top of grp "Item Insert" to tWidgetTop
      else set the top of grp "Item Insert" to -1000
   end if
   revInitialiseForNoItemSelection
   unlock screen
end mouseUp
