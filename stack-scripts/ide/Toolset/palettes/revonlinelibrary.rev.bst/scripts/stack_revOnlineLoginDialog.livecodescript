script "stack_revOnlineLoginDialog"
-- Stack file: ide/Toolset/palettes/revonlinelibrary.rev
-- Object: stack "revOnlineLibrary" > substack "revOnlineLoginDialog"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.


local sPasswordHash
local sPassword
local sEmail

on preOpenStack
   set the loc of me to the screenloc
   if revOnlinePrefGet("rememberEmail") then
      put revOnlinePrefGet("Email") into field "Email" of me
      set the hilite of button "remember email" of me to true
      enable button "remember password" of me
   else
      put empty into field "Email" of me
      set the hilite of button "remember email" of me to false
      disable button "remember password" of me
   end if
   linkShow "Forgot your password?", "Forgot password"
   put empty into field "Password" of me
   --put empty into field "Message" of me
   set the cValue of field "password" of me to empty
   set the parentScript of field "Password" of me to the long id of button "Password Field" of stack "revOnlineLibrary"
   enable button "remember email" of me   
   enable field "email" of me
   enable field "password" of me
   set the cValue of field "password" of me to empty
   if revOnlinePrefGet("rememberpassword") then
      set the hilite of button "remember password" of me to true
   else
      set the hilite of button "remember password" of me to false
   end if
   enable button "Log in" of me
   
   # OK-2009-09-18 : Added some font abstraction stuff
   revFontApplySystemStyle the long id of field "Title" of me, 20, "bold"
end preOpenStack

on saveStackRequest
   put empty into field "Email" of me
   put empty into field "Password" of me
   put empty into field "Message" of me
end saveStackRequest

command submitLogin
   infoShow "Logging in..."
   disable button "Log in" of me
   disable field "email" of me
   disable field "password" of me
   put the text of field "Email" of me into sEmail
   put md5digest(the cValue of field "Password" of me) into sPasswordHash
   revOnlineLogin the text of field "Email" of me, md5digest(the cValue of field "Password" of me), empty, empty, true
   submitLoginContinuation the result
end submitLogin
 
command submitLoginContinuation pSuccess
   if pSuccess then
      revOnlinePrefSet "rememberEmail", (the hilite of button "remember email" of me)
      revOnlinePrefSet "rememberPassword", (the hilite of button "remember password" of me)
      if the hilite of button "remember email" of me then
         revOnlinePrefSet "email", sEmail
         if the hilite of button "remember password" of me then
            revOnlinePrefSet "passwordhash", sPasswordHash
         end if
      else
         --revOnlinePrefSet "rememberEmail", false
         revOnlinePrefSet "email", empty
         --revOnlinePrefSet "rememberPassword", false
         revOnlinePrefSet "passwordhash", empty
      end if
      infoShow "Login successful"
      wait 3 seconds with messages
      set the cResult of me to "success"
      close me
      enable button "Log in" of me
   else if pSuccess is "no connection" then
      infoShow "Couldn't connect to server, please try again later"
      enable field "email" of me
      enable field "password" of me
      enable button "Log in" of me
   else
      linkShow "Incorrrect log in, forgot password?", "Forgot password"
      enable field "email" of me
      enable field "password" of me
      enable button "Log in" of me
      set the cValue of field "password" of me to empty
      put empty into field "password" of me
      
      revOnlinePrefSet "rememberEmail", false
      revOnlinePrefSet "email", empty
      revOnlinePrefSet "rememberPassword", false
      revOnlinePrefSet "passwordhash", empty
      set the hilite of button "remember email" of me to false
      set the hilite of button "remember password" of me to false
      disable button "remember password" of me
   end if
end submitLoginContinuation

command submitCancel
   set the cResult of me to "cancelled"
   close me
end submitCancel

command infoShow pMessage
   set the htmlText of field "Message" of me to "<p>" & pMessage & "</p>"
end infoShow

command linkShow pMessage, pLink
   set the htmlText of field "Message" of me to "<p><font face='Segoe UI' size='10'><a href=" & quote & pLink & quote & ">" & pMessage & "</a></font></p>"
end linkShow

command log pMessage
   put pMessage & return after msg
end log

on linkClicked pLink
   if pLink is "Forgot Password" then
      if the text of field "email" of me is not empty then
         disable button "log in" of me
         infoShow "Resetting password ..."
         put empty into field "Password" of me
         revOnlineResetPassword the text of field "Email" of me, "resetPasswordCallback", the long id of me
      else
         infoShow "You must enter your email address to reset your password"
         send "linkShow Forgot your password?, Forgot password" to me in 4 seconds
      end if
   end if
end linkClicked

command resetPasswordCallback pResult
   enable button "log in" of me
   if pResult is true then
      infoShow "Your new password has been emailed to you"
   else if pResult is "not registered" then
      infoShow "The username supplied has not yet been registered for a revOnline account, please use the Sign Up button to do so"
   else if pResult is "not activated" then
      infoShow "Your revOnline account has not yet been activated, please click the activation link in your registration email"
   else
      infoShow "Error, could not reset password"
   end if
end resetPasswordCallback

on returnInField
   
end returnInField

on enterInField
   
end enterInField

 
