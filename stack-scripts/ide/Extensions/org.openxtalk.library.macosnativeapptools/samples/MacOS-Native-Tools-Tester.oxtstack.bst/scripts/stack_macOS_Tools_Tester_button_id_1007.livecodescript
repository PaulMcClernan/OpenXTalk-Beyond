script "stack_macOS_Tools_Tester_button_id_1007"
-- Stack file: ide/Extensions/org.openxtalk.library.macosnativeapptools/samples/MacOS-Native-Tools-Tester.oxtstack
-- Object: stack "macOS Tools Tester" > card (id 1002) > button "Send Notification" (id 1007)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.


on mouseUp pMouseButton
   put macOSversion() into tAcurrateVersionNum
   set the itemDelimiter to "." 
   if item 1 of tAcurrateVersionNum >10 then
      Answer warning "NOTE: This API was marked deprecated in macOS 11, needs an update to the new API for macOS 12+"
   end if
   get PostUserNotification("Hello Notification", "This is the subtitle ", "your notification text goes here", "DLNote001", "sosumi")
   Answer "Message was posted, Check the macOS Notification Center panel."
   --   PostUserNotification pTitle, pSubtitle, pNotificationText, pMsgIdUsedforOverwriting, pAlertSoundToUse
end mouseUp
