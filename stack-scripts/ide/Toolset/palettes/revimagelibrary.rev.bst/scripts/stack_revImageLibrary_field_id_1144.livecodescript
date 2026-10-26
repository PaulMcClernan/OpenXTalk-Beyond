script "stack_revImageLibrary_field_id_1144"
-- Stack file: ide/Toolset/palettes/revimagelibrary.rev
-- Object: stack "revImageLibrary" > card "Objects" (id 1150) > field "description" (id 1144)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on closeField
  put line (the hilitedLines of fld "objects list") of fld "objects list" into tCardName
  put the cStackName of fld "objects list" into tStackName
  set the cDescription of cd tCardName of stack tStackName to me
  save stack tStackName
end closeField
