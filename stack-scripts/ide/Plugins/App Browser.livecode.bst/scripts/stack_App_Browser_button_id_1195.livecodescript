script "stack_App_Browser_button_id_1195"
-- Stack file: ide/Plugins/App Browser.livecode
-- Object: stack "App Browser" > card "Cards and Controls" (id 1002) > group "common menus" (id 1606) > button "Card Popup" (id 1195)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

constant kComma="######REVCOMMA#####"

on menuPick pWhich
   global gREVObjectTree
   put item 1 of line (the cLine of me) of gREVObjectTree into tStack
   put item 8 of line (the cLine of me) of gREVObjectTree into tID
   replace kComma with comma in tStack
   if there is not a cd id tID of stack tStack then
      answer error "Card does not exist"
      exit menuPick
   end if
   put the long id of cd id tID of stack tStack into tCard
   
   switch pWhich
      case "Go"
         if not the visible of stack tStack then show stack tStack
         go cd id tID of stack tStack
         break
      case "TopLevel"
         if not the visible of stack tStack then show stack tStack
         toplevel tStack
      case "Select"
         if not the visible of stack tStack then show stack tStack
         go cd id tID of stack tStack
         select cd id tID of stack tStack
         break    
      case "Property Inspector"
         revIDEOpenInspectorForObjects tCard
         break
      case "Edit Script"
         edit script of tCard
         break
      case "New Card"
         set the defaultStack to tStack
         create cd
         break
      case "Delete Card"
         put "Are you sure you want to delete" && the long name of tCard & "?" into tWarning
         answer warning tWarning with "No" or "Yes"
         if it is "Yes" then delete tCard
         break
      case "Cut"
         cut the selobj
         break
      case "Copy"
         copy the selobj
         break
      case "Paste"
         set the defaultStack to tStack
         paste
         break
   end switch
end menuPick
