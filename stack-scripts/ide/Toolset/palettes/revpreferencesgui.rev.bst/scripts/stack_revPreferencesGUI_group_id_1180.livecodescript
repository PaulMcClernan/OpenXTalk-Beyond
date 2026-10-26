script "stack_revPreferencesGUI_group_id_1180"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Documentation" (id 1011) > group "Documentation" (id 1180)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

command singleColumnView
      resetVisibleColumns
      revDocumentationPrefSet "mode", "vertical"
      set the hilite of button "Keyword" of group "VisibleColumns" of me to true
      set the disabled of group "VisibleColumns" of me to "true"
end singleColumnView

command multipleColumnView
   lock screen
   set the disabled of group "VisibleColumns" of me to "false"
   set the disabled of button "Keyword" of group "VisibleColumns" of me to "true"
   unlock screen
   revDocumentationPrefSet "mode", "horizontal"
end multipleColumnView

on mouseUp
   if the short name of the target is "MultipleColumns" then
      multipleColumnView
   else if the short name of the target is "SingleColumn" then
      singleColumnView
   end if
   
   if the owner of the target is the name of group "VisibleColumns" of me then
      local tColumnVisibility
      repeat for each item tColumnName in revDocumentationDefaultPref("columns")
         if the hilite of button tColumnName of group "VisibleColumns" of me then
            put true after tColumnVisibility
         else
            put false after tColumnVisibility
         end if
         put comma after tColumnVisibility
      end repeat
      delete the last char of tColumnVisibility
      revDocumentationPrefSet "columnVisibility", tColumnVisibility
   end if
   
   revDocumentationPrefSave
   update
   send "revDictionaryUpdate" to revDocumentationDictionaryStack()
end mouseUp

-- Sets the values of controls in the group to match the current pref settings.
command update
   lock screen
   
   local tMode, tColumnVisibility, tButton
   put revDocumentationPrefGet("mode") into tMode
   put revDocumentationPrefGet("columnVisibility") into tColumnVisibility
   switch tMode
      case "vertical"
         set the hilite of button "SingleColumn" of group "ColumnView" of card "Documentation" to true
         set the hilite of button "MultipleColumns" of group "ColumnView" of card "Documentation" to false
         singleColumnView
         break
      case "horizontal"
         set the hilite of button "MultipleColumns" of group "ColumnView" of card "Documentation" to true
         set the hilite of button "SingleColumn" of group "ColumnView" of card "Documentation" to false
         multipleColumnView
         local tVisibility, tCounter
         put 1 into tCounter
         repeat for each item tButton in revDocumentationDefaultPref("columns")
            put item tCounter of tColumnVisibility into tVisibility
            set the hilite of button tButton of me to tVisibility
            put tCounter + 1 into tCounter
         end repeat
         break
   end switch
   unlock screen
end update

command resetVisibleColumns
   local tColumns
   put revDocumentationDefaultPref("columns") into tColumns
   set the itemDelimiter to comma
   repeat with x=1 to the number of items of revDocumentationDefaultPref("columns")
      set the hilite of button (item x of tColumns) to "false"
   end repeat
end resetVisibleColumns
