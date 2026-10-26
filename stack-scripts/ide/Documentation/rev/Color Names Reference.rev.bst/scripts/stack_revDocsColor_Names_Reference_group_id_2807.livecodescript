script "stack_revDocsColor_Names_Reference_group_id_2807"
-- Stack file: ide/Documentation/rev/Color Names Reference.rev
-- Object: stack "revDocsColor Names Reference" > card "Color Chart" (id 1002) > group "revLibraries" (id 2807)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenBackGround
  repeat with i = 1 to the number of btns in me
    insert script of btn i of me into back
  end repeat
end preOpenBackGround
