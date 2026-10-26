script "stack_revGettingStartedScripts_group_id_1092"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Converting a relative path to an absolute path Example" (id 1092)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenBackground
  put empty into field "Path"
  put the defaultFolder into field "Starting Folder"
end preOpenBackground
