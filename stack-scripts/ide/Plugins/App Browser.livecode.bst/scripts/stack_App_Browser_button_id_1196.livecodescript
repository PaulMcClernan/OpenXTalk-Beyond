script "stack_App_Browser_button_id_1196"
-- Stack file: ide/Plugins/App Browser.livecode
-- Object: stack "App Browser" > card "Cards and Controls" (id 1002) > button "Control Popup" (id 1196)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseRelease pButton
  if the clickLoc is within the rect of fld "Controls" then
    send "mouseDown pButton" to fld "Controls"
    send "mouseUp pButton" to fld "Controls"
  end if
end mouseRelease

on menuPick pWhich
   global gREVStackName
   put revSelControls() into tObjects
   switch pWhich
      case "Property Inspector"
         revIDEOpenInspectorForObjects tObjects
         break
      case "Edit Script"
         repeat for each line l in tObjects
            edit script of l
         end repeat
         break
      case "Cut"
         cut
         break
      case "Copy"
         copy
         break
      case "Paste"
         set the defaultStack to gREVStackName
         paste
         break
      case "Clear"
         put empty into tNames
         repeat for each line l in tObjects
            put the name of l & cr after tNames
         end repeat
         delete last char of tNames
         put "Are you sure you want to delete the following controls?" & cr & cr & tNames into tWarning
         answer warning tWarning with "No" or "Yes"
         if it is "Yes" then 
            repeat for each line l in tObjects
               delete l
            end repeat
         end if
         break
      case "Refresh"
         revRefreshControls true, false
         break
   end switch
end menuPick
