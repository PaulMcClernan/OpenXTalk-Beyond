script "stack_revOnlineCreateAccountDialog"
-- Stack file: ide/Toolset/palettes/revonlinelibrary.rev
-- Object: stack "revOnlineLibrary" > substack "revOnlineCreateAccountDialog"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenStack
   set the loc of me to the screenloc
   put empty into field "Email" of me
   put empty into field "Message" of me
   enable button "Submit" of me
   
   # OK-2009-09-18
   revFontApplySystemStyle the long id of field "Title" of me, 20, "bold"
end preOpenStack

command submitRequest
   disable button "Submit" of me
   revOnlineRequestAccount the text of field "Email" of me, "submitRequestCallback", the long id of me
end submitRequest

command submitRequestCallback pResult
   if pResult is "true" then
      infoShow "You should receive an email containing your login details soon"
      wait 2 seconds with messages
      set the cResult of me to "success"
      close me
   else
      infoShow "Invalid email or email already taken, please try again"
   end if
   
   enable button "Submit" of me
end submitRequestCallback

command submitCancel
   set the cResult of me to "cancelled"
   close me
end submitCancel

on saveStackRequest
   put empty into field "Email" of me
   put empty into field "Message" of me
end saveStackRequest

command infoShow pMessage
   put pMessage into field "Message" of me
end infoShow

on returnInField
   
end returnInField

on enterInField
   
end enterInField


