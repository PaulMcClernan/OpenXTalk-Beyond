script "stack_revResourceCenter_group_id_577024"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Gettingthedimensionsofapicturefile" (id 80339) > group "mainContent" (id 80351) > group (id 579813) > group "Example" (id 577024)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenBackground
  put empty into field "Filename"
  put "??" into word 2 of field "Height"
  put "??" into word 2 of field "Width"
end preOpenBackground
