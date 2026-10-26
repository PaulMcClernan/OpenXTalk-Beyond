script "stack_App_Browser_button_id_1607"
-- Stack file: ide/Plugins/App Browser.livecode
-- Object: stack "App Browser" > card "Cards and Controls" (id 1002) > group "common menus" (id 1606) > button "Stack Popup" (id 1607)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

constant kComma="######REVCOMMA#####"

on menuPick pWhich
   global gREVObjectTree
   put item 6 of line (the cLine of me) of gREVObjectTree into tStack
   replace kComma with comma in tStack
   if there is not a stack tStack then
      answer error "Stack Does not exist"
      exit menuPick
   end if
   
   switch pWhich
      case "Go"
         if not the visible of stack tStack then show stack tStack
         go stack tStack
         break
      case "TopLevel"
         if not the visible of stack tStack then show stack tStack
         if the style of stack tStack is not "toplevel"
         then set the style of stack tStack to "toplevel"
         else toplevel stack tStack
         break
      case "Property Inspector"
         revIDEOpenInspectorForObjects the long id of stack tStack         
         break
      case "Edit Script"
         edit script of stack tStack
         break
      case "New Substack"
         put the mainStack of stack tStack into tMainStack
         send menuPick && quote & "New Mainstack" & quote to btn "file" of cd 1 of stack "revMenuBar"
         set the mainStack of the topStack to tMainStack
         break
      case "Save"
         if the effective fileName of stack tStack is not empty
         then revSave tStack
         else revSaveAs tStack
         break
      case "Close and Remove From Memory"
         put revBeforeRemovingStackFromMemory(tStack) into tCheck
         if tCheck is not empty then
            answer error "Before Revolution can remove this stack from memory please:" & cr & cr & tCheck
            exit menuPick
         end if
         put the effective fileName of stack tStack into tStackPath
         if tStackPath is empty then put the mainStack of stack tStack into tStackpath
         put the mainStack of stack tStackPath into tMainstack
         put the subStacks of stack tStackPath into tSubstacks
         put tMainStack & cr & tSubstacks into tStacks
         answer warning "Really remove the stack file" && tStackPath && "from memory?" & cr & "Any changes made since saving will be lost from the following stacks:" & cr & cr & tStacks with "Cancel" or "OK"
         if it is "Cancel" then exit menuPick
         repeat for each line l in tSubstacks
            close stack l
         end repeat
         delete stack tMainStack
         break
      case "Delete Substack"
         delete stack tStack
         break
      case "Save As Standalone Application..."
         send "revSaveAsStandalone"&&quote&tStack&quote to stack "revSaveAsStandalone"
         break
      case "Standalone Application Settings..."
         send "revStandaloneSettings"&&quote&tStack&quote to stack "revStandaloneSettings"
         break
   end switch
end menuPick
