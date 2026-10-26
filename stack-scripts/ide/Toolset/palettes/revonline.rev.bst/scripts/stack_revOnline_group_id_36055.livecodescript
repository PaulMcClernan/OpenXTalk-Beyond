script "stack_revOnline_group_id_36055"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "menubar" (id 36055)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.


command initialize
 
end initialize

command resize
   --lock screen
   set the topLeft of image "topBanner" of me to 0,0
   if field "email" of me is not empty then
      set the rect of field "email" of me to \
            (the right of me - 2 - the formattedwidth of field "email" of me, the top of field "email" of me, the right of me - 2, the bottom of field "email" of me)
      set the rect of field "login status" of me to \
            (the left of field "email" of me - the formattedwidth of field "login status" of me, the top of field "login status" of me, the left of field "email" of me + 5, the bottom of field "login status" of me)
   else
      set the topleft of field "email" of me to (the right of me + 10, the top of me +4)
      set the rect of field "login status" of me to \
            (the right of me - 2 - the formattedwidth of field "login status" of me, the top of field "login status" of me, the right of me - 2, the bottom of field "login status" of me)
   end if
   --   set the rect of field "login background" of me to \
         --   (min(the left of field "login status" of me, the right of me - 275), the top of me + 2, the right of me -2, the bottom of me -2)
   --   set the topright of image "login background end" of me to (the left of field "login background" of me + 4, the top of me)
   set the topright of field "controls" of me to (the right of me -5, the bottom of field "email" of me)
   --unlock screen
end resize

command showLoginStack
   local tResult
   revOnlineShowLoginDialog
   put the result into tResult
   if the result is "success" then
      rvoUpdateTooltip "You are now logged in"
      loggedInDisplay
   end if
end showLoginStack

command showCreateAccountStack
   local tResult
   revOnlineShowCreateAccountDialog
   put the result into tResult
   if the result is "success" then
      rvoUpdateTooltip "Account requested"
   end if
end showCreateAccountStack

command logout
   if the cSelectedUser of group "search filter" of this stack is revonlineId() then
      set the cSelectedUser of group "search filter" of this stack to empty
      updateSearchList 0
   end if
   revOnlineLogout "logoutCallback", the long id of me
end logout

command logoutCallback pResult
   if pResult is true then
      rvoUpdateTooltip "You logged out"
      loggedOutDisplay
   else
      rvoUpdateTooltip "Failed to log out"
   end if
end logoutCallback

command loggedInDisplay
   lock screen
   put "You are logged in as" into field "login status" of me
   put revOnlineEmail() into field "email" of me
   put "My Account  |  Upload Content  |  Sign Out" into field "controls" of me
   send "clearColors" to field "controls" of me
   resize
   unlock screen
   if the cMode of group "search list" of stack "revonline" is "list" then
      updateViewingPane
   end if
end loggedInDisplay

command loggedOutDisplay
   lock screen
   put "You are currently not logged in" into field "login status" of me
   put empty into field "email" of me
   put "Log In  |  Sign Up" into field "controls" of me
   send "clearColors" to field "controls" of me
   resize
   unlock screen
   updateViewingPane
end loggedOutDisplay



