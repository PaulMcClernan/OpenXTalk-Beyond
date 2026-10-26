script "stack_revPreferencesGUI_button_id_1227"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "RevOnline" (id 1014) > group "revOnline" (id 1223) > group "Login options" (id 1224) > button "Delete account" (id 1227)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if revOnlineSession() is empty then
      revOnlineShowLoginDialog
   end if
   
   if revOnlineSession() is empty then
      exit mouseUp
   end if
   
   ask password clear "If you are sure you want to delete your RevOnline account, please confirm your password"
   if it is empty or the result is "Cancel" then
      exit mouseUp
   end if
   
   revOnlineDeleteAccount revOnlineSession(), md5digest(it), "deleteAccountCallback", the long id of me
end mouseUp

command deleteAccountCallback pResult
   if pResult then
      answer "Your account was successfullly deleted"
   else
      answer "There was an error deleting your account: " & pResult
   end if
end deleteAccountCallback
