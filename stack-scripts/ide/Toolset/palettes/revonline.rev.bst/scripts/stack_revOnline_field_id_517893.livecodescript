script "stack_revOnline_field_id_517893"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "menubar" (id 36055) > field "controls" (id 517893)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.


on mousemove
   lock screen
   local tText
   put the mouseText into tText
   if tText is among the items of "My,Account,Upload,Content,Sign,Up,Out,Log,In" then
      clearColors
      clearStyles
      local tItem
      set the itemdelimiter to "|"
      put itemoffset(tText, the text of field "controls" of me) into tItem
      put item tItem of the field "controls" of me into tText
      
      if char 1 of the version < 7 then
         set the textColor of item tItem of field "controls" of me to 222,222,222
      else
         set the textColor of item tItem of field "controls" of me to rvoHiliteColor()
      end if
   end if
   unlock screen
end mousemove
   
on mouseUp
   lock screen
   local tText
   put the mouseText into tText
   
   if tText is among the items of "My,Account,Upload,Content,Sign,Up,Out,Log,In" then
      clearColors
      local tItem
      set the itemdelimiter to "|"
      put itemoffset(tText, the text of field "controls" of me) into tItem
      put item tItem of the field "controls" of me into tText
      set the textColor of item tItem of field "controls" of me to rvoHiliteColor()
      switch tText
         case "My Account  "
            if the textStyle of item tItem of field "controls" of me is "bold" then
               set the textStyle of item tItem of field "controls" of me to empty
               updateView "list"
               set the cSelectedUser of group "search filter" of this stack to empty
               --updateSearchList 0
            else
               set the textStyle of item tItem of field "controls" of me to "bold"
               updateView "list","user", revOnlineId()
                set the cSelectedUser of group "search filter" of this stack to revOnlineId()
               --updateSearchList 0
            end if
         break
         case "  Upload Content  "
            clearStyles
            updateView "list","stack", "new"
         break
         case "  Sign Out"
            logout
         break
         case "  Sign Up"
            showCreateAccountStack
         break
         case "Log In  "
            showLoginStack
         break         
      end switch
   end if
   unlock screen
end mouseUp

command clearColors
   repeat with x = 1 to the number of words of field "order" of me
      if word x of field "controls" of me is "|" then
         set the textColor of word x of field "controls" of me to empty
      end if
      if the textStyle of word x of field "controls" of me is not "bold" and word x of field "controls" of me is not "|" then
         if char 1 of the version < 7 then
            set the textColor of word x of field "controls" of me to white
         else
            set the textColor of word x of field "controls" of me to empty
         end if
      end if
   end repeat
end clearColors

command clearStyles
   repeat with x = 1 to the number of words of field "controls" of me
      set the textStyle of word x of field "controls" of me to empty
   end repeat
end clearStyles

on mouseLeave
   clearColors
   clearStyles
end mouseLeave

