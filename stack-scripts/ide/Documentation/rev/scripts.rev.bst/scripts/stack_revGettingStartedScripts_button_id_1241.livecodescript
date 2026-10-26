script "stack_revGettingStartedScripts_button_id_1241"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Speaking an alert message Example" (id 1240) > button "Speak!" (id 1241)
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
