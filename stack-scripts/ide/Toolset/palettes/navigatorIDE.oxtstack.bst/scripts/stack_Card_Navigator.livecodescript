script "stack_Card_Navigator"
-- Stack file: ide/Toolset/palettes/navigatorIDE.oxtstack
-- Object: stack "Card Navigator"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on hNavigatorUpdate
   -- check if top stack is an IDE stack
   put false into tIsThisIDEStack
   put the topstack into tCurStack
   put the short name of the topStack into tStackName
   
   if tCurStack contains (slash & "rev") then put true into tIsThisIDEStack
   if tStackName contains (slash & "rev") then put true into tIsThisIDEStack
   
   put specialFolderPath("Engine") into tProgDir
   if tCurStack contains (tProgDir) then put true into tIsThisIDEStack
   
   if not(there is a fld "StackName" of this stack) then exit hNavigatorUpdate
   
   -- disable if IDE stack
   if tIsThisIDEStack is true then 
      hDisableNavigator
      put "(IDE stack) " & tStackName into fld "StackName" of this stack
      set the tooltip of fld "StackName" to ""
   else
      -- not IDE stack, so enable stuff
      hEnableNavigator
      put tStackName into fld "StackName" of this stack
      set the tooltip of fld "StackName" to tCurStack
      -- put tCurStack into fld "Stack" of stack "Navigator"
   end if
   --
   -- put tProgDir & " " & tIsThisIDEStack & " " & the ticks
   -- I would use IDESubscribeMessage, but this is proving unreliable. And I need something reliable, so...
   if not (the pendingmessages contains "hNavigatorUpdate") then send hNavigatorUpdate to this stack in 50 ticks
   
end hNavigatorUpdate

on hDisableNavigator
   try
      set the blendlevel of group "navbtns" of this stack to 50
      disable group "navbtns" of this stack
   catch e
   end try
end hDisableNavigator

on hEnableNavigator
   try
      set the blendlevel of group "navbtns" of this stack to 0
      enable group "navbtns" of this stack
   catch e
   end try
end hEnableNavigator

on closestack
   set the tShown of this stack to false
   set the destroyStack of this stack to true
   pass closestack
end closestack

on hAssignIcons
   lock screen
   set the icon of btn "first" of group "navbtns" of this card to the id of image "leftmost" of this card
   set the icon of btn "Prev" of group "navbtns" of this card to the id of image "left" of this card
   set the icon of btn "Next" of group "navbtns" of this card to the id of image "right" of this card
   set the icon of btn "Last" of group "navbtns" of this card to the id of image "rightmost" of this card
   set the icon of btn "Start" of group "navbtns" of this card to the id of image "top" of this card
   set the icon of btn "Back 1" of group "navbtns" of this card to the id of image "up" of this card
   set the icon of btn "Forward 1" of group "navbtns" of this card to the id of image "down" of this card
   set the icon of btn "Finish" of group "navbtns" of this card to the id of image "bottom" of this card
   set the icon of btn "New Card" of group "navbtns" of this card to the id of image "add-card" of this card
   set the icon of btn "Delete Card" of group "navbtns" of this card to the id of image "del-card" of this card
   set the textalign of btn "New Card" to right
   unlock screen
end hAssignIcons

on preopenstack
   set the tShown of this stack to true
   hAssignIcons
   hPositionNavigator
end preopenstack

on hPositionNavigator
   put the itemdelimiter into tOldDelim
   set the itemdelimiter to ","
   if there is a stack "revTools" then
      set the left of this stack to the right of stack "revTools" +20
      set the bottom of this stack to the bottom of stack "revTools"
   else
      set the left of this stack to 20
      set the bottom of this stack to item 4 of the screenrect -20
   end if
   set the itemdelimiter to tOldDelim
end hPositionNavigator
