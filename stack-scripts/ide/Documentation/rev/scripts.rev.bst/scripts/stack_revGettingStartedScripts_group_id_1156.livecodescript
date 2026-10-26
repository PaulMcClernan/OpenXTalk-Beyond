script "stack_revGettingStartedScripts_group_id_1156"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Getting the dimensions of a picture file Example" (id 1156)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenBackground
  put empty into field "Filename"
  put "??" into word 2 of field "Height"
  put "??" into word 2 of field "Width"
end preOpenBackground
