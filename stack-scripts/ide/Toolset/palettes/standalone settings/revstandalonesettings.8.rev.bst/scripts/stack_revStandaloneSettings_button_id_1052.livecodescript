script "stack_revStandaloneSettings_button_id_1052"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Copy Files" (id 1027) > button "Remove Entry" (id 1052)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  if the hilitedLines of fld "files" is not empty then
    put the hilitedLines of fld "files" into tLines
    repeat with X=the number of items in tLines down to 1
      delete line (item X of tLines) of fld "files"
    end repeat
    setProps
  end if
end mouseUp
