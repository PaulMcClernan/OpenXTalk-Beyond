script "stack_revErrorReport"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > substack "revErrorReport"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

# OK-2007-01-05: Bug 4799. Under certain circumstances this modal stack could be opened offscreen 
# giving the appearance of a frozen application. Ensure this does not happen. 
on preOpenStack 
  set the loc of me to the screenLoc 
  pass preOpenStack 
end preOpenStack

on errorDialog pWhatError, pWhatError2
  set the executionError of stack "copy of revErrorReport" to pWhatError
  set the scriptError of stack "copy of revErrorReport" to pWhatError2
  set the uObject of stack "copy of revErrorReport" to the long id of the target
  modal "copy of revErrorReport"
end errorDialog
