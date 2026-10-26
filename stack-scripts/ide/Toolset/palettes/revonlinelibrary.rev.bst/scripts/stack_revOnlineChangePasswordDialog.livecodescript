script "stack_revOnlineChangePasswordDialog"
-- Stack file: ide/Toolset/palettes/revonlinelibrary.rev
-- Object: stack "revOnlineLibrary" > substack "revOnlineChangePasswordDialog"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenStack
   if revOnlinePrefGet("rememberEmail") and revOnlinePrefGet("Email") is not empty then
      put revOnlinePrefGet("Email") into field "Email" of me
      set the lockText of field "Email" of me to true
   else
      set the lockText of field "Email" of me to false
      put empty into field "Email" of me
   end if
   
   put empty into field "Password" of me
   put empty into field "Message" of me
   put empty into field "New password" of me
   put empty into field "New password confirmation" of me
   
   set the parentScript of field "Password" of me to the long id of button "Password Field" of stack "revOnlineLibrary"
   set the parentScript of field "New password" of me to the long id of button "Password Field" of stack "revOnlineLibrary"
   set the parentScript of field "New password confirmation" of me to the long id of button "Password Field" of stack "revOnlineLibrary"
   
   set the cValue of field "Password" of me to empty
   set the cValue of field "New password" of me to empty
   set the cValue of field "New password confirmation" of me to empty
   
   # OK-2009-09-18
   revFontApplySystemStyle the long id of field "Title" of me, 20, "bold"
   
   enableFields
end preOpenStack

on saveStackRequest
   put empty into field "Email" of me
   put empty into field "Password" of me
   put empty into field "Message" of me
   put empty into field "New password" of me
   put empty into field "New password confirmation" of me
end saveStackRequest

private command enableFields
   enable button "Change" of me
   enable field "email" of me
   enable field "password" of me
   enable field "New password" of me
   enable field "New password confirmation" of me
end enableFields

private command disableFields
   disable button "Change" of me
   disable field "Email" of me
   disable field "Password" of me
   disable field "New password" of me
   disable field "New password confirmation" of me
end disableFields


command submitChange
   if the cValue of field "New password" of me is not the cValue of field "New password confirmation" of me then
      infoShow "Password's don't match, please try again"
      exit submitChange
   end if 
   
   disableFields
   
   # If the user is not logged in, their password cannot be changed. As we have their 
   # email and password already in fields on this dialog, we can do the login automatically
   # without needing to bring up a second dialog
   if revOnlineSession() is empty then
      revOnlineLogin the text of field "Email" of me, md5digest(the cValue of field "Password" of me), "loginCallback", the long id of me
      exit submitChange
   end if
   
   submitChangeContinuation
end submitChange

command loginCallback pSuccess
   if not pSuccess then
      enableFields
      linkShow "Incorrrect log in, forgot password?", "Forgot password"
      set the cValue of field "Password" of me to empty
      exit loginCallback
   end if
   
   submitChangeContinuation
end loginCallback

command submitChangeContinuation
   revOnlineChangePassword revOnlineSession(), md5digest(the cValue of field "Password" of me), md5digest(the cValue of field "New Password" of me), "submitChangeCallback", the long id of me
end submitChangeContinuation

command submitChangeCallback pResult
   if pResult then
      infoShow "Your new Revolution password has been successfully changed"
      wait 3 seconds with messages
      close me
   else
      infoShow "There was an error changing your password"
      enableFields
   end if
end submitChangeCallback

command submitCancel
   set the cResult of me to "cancelled"
   close me
end submitCancel

command infoShow pMessage
   set the htmlText of field "Message" of me to "<p>" & pMessage & "</p>"
end infoShow

command linkShow pMessage, pLink
   set the htmlText of field "Message" of me to "<a href=" & quote & pLink & quote & ">" & pMessage & "</a>"
end linkShow

command log pMessage
   put pMessage & return after msg
end log

on linkClicked pLink
   if pLink is "Forgot Password" then
      wait 500 milliseconds with messages
      infoShow "Your new Revolution password has been emailed"
      put empty into field "Password" of me
      revOnlineResetPassword the text of field "Email" of me, "resetPasswordCallback", the long id of me
   end if
end linkClicked

command resetPasswordCallback
   
end resetPasswordCallback

on returnInField
   
end returnInField

on enterInField
   
end enterInField

 
