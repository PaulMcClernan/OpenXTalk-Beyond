script "stack_revMenuManager_field_id_8005"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > card "Menu Manager" (id 1002) > group "Menu Item Controls" (id 3265) > field "Item Tag" (id 8005)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on returnInField
  lock screen
  closeField
  select the text of me
  unlock screen
end returnInField

on enterInField
  returnInField
end enterInField

on closeField
   exitField
   pass closeField
end closeField

on exitField
   if the text of me is empty then
      set the hilite of button "Item Tagged" to false
   end if
end exitField

// SN-2014-12-04: [[ Bug 11573 ]] Update the tag at every text change
on textChanged
   send "mouseUp" to button "Item Tagged" in 10 milliseconds
   // SN-2015-01-06: [[ Bug 14155 ]] Ensure that the custom prop storing the tag is
   // updated, in case the item name is changed before selecting another item.
   revFilterItemName
end textChanged
