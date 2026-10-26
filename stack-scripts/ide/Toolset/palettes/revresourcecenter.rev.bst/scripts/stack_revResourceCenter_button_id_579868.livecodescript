script "stack_revResourceCenter_button_id_579868"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Speakinganalertmessage" (id 100210) > group "mainContent" (id 100222) > group (id 579871) > group "Example" (id 577038) > button "Speak!" (id 579868)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  if field "Speech" is empty then put the defaultAlert of field "Speech" into field "Speech"
  speakAlert field "Speech"
end mouseUp

on speakAlert theText
  if theText is empty then exit speakAlert -- skip the rest
  try -- in case revSpeak isn't installed
    revSpeak theText
  catch theError -- if the "revSpeak" command fails
    put return & "(Cannot speak text on this system.)" \
       after theText
    beep -- make a sound to get the user's attention
  end try
  answer theText
end speakAlert
