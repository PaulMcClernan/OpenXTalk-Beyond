script "stack_revGettingStartedScripts_field_id_1251"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Switching between styled text and HTML source Example" (id 1250) > field "Display" (id 1251)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

setProp displayedFormat theType
  -- accepts "HTML" (default) or "styled"
  if theType is "HTML" then
    set the text of the target to the htmlText of the target
  else
    set the htmlText of the target to the text of the target
  end if
end displayedFormat
