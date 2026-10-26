script "stack_revGettingStartedScripts_group_id_1255"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Translating a color name to an RGB numeric triplet Example" (id 1255)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenBackground
  put the colorNames into button "Color Name"
  set the label of button "Color Name" to "Black"
  put "The color" && quote & "Black" & quote && "is" && quote & "0,0,0" & quote & "." \
      into field "Color Result"
end preOpenBackground
