script "stack_revOnlineAffiliateSignupDialog"
-- Stack file: ide/Toolset/palettes/revonlinelibrary.rev
-- Object: stack "revOnlineLibrary" > substack "revOnlineAffiliateSignupDialog"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenStack
   set the loc of me to the screenLoc
   
   if revOnlinePrefGet("rememberEmail") and revOnlinePrefGet("Email") is not empty then
      put revOnlinePrefGet("Email") into field "Email" of me
      --set the lockText of field "Email" of me to true
   else
      --set the lockText of field "Email" of me to false
      put empty into field "Email" of me
   end if
   
   put empty into field "Password" of me
   put empty into field "Message" of me
   
   set the behavior of field "Password" of me to the long id of button "Password Field" of stack "revOnlineLibrary"
   set the cValue of field "Password" of me to empty
   set the label of button "Cancel" of me to "Cancel"
   put revOnlineEmail() into field "Email"
   if revOnlineSession() is not empty then
      put "**********" into field "Password"
   end if
   enableFields
   
   # OK-2009-09-18
   revFontApplySystemStyle the long id of field "Title" of me, 20, "bold"
end preOpenStack

on saveStackRequest
   put empty into field "Email" of me
   put empty into field "Password" of me
   put empty into field "Message" of me
end saveStackRequest

private command enableFields
   enable button "Register" of me
   enable field "email" of me
   enable field "password" of me
end enableFields

private command disableFields
   disable button "Register" of me
   disable field "Email" of me
   disable field "Password" of me
end disableFields

local sRequestInProgress = "false"
local sRequestId

command submitRegistration
   disableFields
   
   # If the user is not logged in, then log them in using the details entered, otherwise jump straight to the continuation
   if revOnlineSession() is empty then
      revOnlineLogin the text of field "Email" of me, md5digest(the cValue of field "Password" of me), "loginCallback", the long id of me
      put the result into sRequestId
      put true into sRequestInProgress
      exit submitRegistration
   end if
   
   submitRegistrationContinuation
end submitRegistration

command loginCallback pSuccess
   if not pSuccess then
      enableFields
      linkShow "Incorrrect log in, forgot password?", "Forgot password"
      set the cValue of field "Password" of me to empty
      put empty into sRequestId
      put false into sRequestInProgress
      exit loginCallback
   end if
   
   submitRegistrationContinuation
end loginCallback

command submitRegistrationContinuation
   revOnlineAffiliateSignup revOnlineSession(), "submitRegistrationCallback", the long id of me
   put the result into sRequestId
   put true into sRequestInProgress
end submitRegistrationContinuation

command submitRegistrationCallback pSuccess, pId
   put empty into sRequestId
   put false into sRequestInProgress
   if pSuccess then
      infoShow "Registration successful. Your affiliate ID is: " & pId & ". Further details have been emailed to you"
      set the label of button "Cancel" to "Done"
   else
      infoShow "There was an error registering for the programme, " & pId & ".  Please try again or contact support"
      enable button "register"
      enableFields
   end if
end submitRegistrationCallback
   
command submitCancel
   if sRequestInProgress then
      put false into sRequestInProgress
      revOnlineQueueCancel sRequestId
      put empty into sRequestId
   end if
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

 
