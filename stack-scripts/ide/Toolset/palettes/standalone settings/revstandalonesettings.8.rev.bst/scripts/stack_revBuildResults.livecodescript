script "stack_revBuildResults"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > substack "revBuildResults"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

setProp cWarnings pWarnings
  lock messages
  put empty into field "Warnings"
  local tCount
  put 1 into tCount
  repeat for each line tWarning in pWarnings
    put tCount & tab & tWarning & return after field "Warnings"
    add 1 to tCount
  end repeat
  delete the last char of field "Warnings"
  subtract 1 from tCount
  put tCount && "warnings" into field "Warning Count" of card 1 of me
  
  set the vScrollBar of field "Warnings" to the formattedHeight of field "Warnings" > the height of field "Warnings" - 20
  set the vScroll of field "Warnings" to 100000
  
  # OK-2008-03-11 : Bug 5863
  # This dialog should be modal for symmetry with the dialog that comes up if no warnings ocurred.
  # This also prevents any stacks from appearing above this window.
  --modeless me
  modal me
  
  unlock messages
end cWarnings

on dismissMe
  close me
end dismissMe

on preOpenStack
  # OK-2008-03-31 : Bug 6216. Setting the location of stack before modalling it doesn't seem to work
  # so we set the location here as a workaround.
  set the loc of me to the screenLoc
end preOpenStack


