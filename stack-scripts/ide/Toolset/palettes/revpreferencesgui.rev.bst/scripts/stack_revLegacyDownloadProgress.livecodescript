script "stack_revLegacyDownloadProgress"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > substack "revLegacyDownloadProgress"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

command initialize
  set the visible of scrollbar "Progress Scrollbar" of me to true
  set the thumbPosition of scrollbar "Progress Scrollbar" of me to 0
  set the visible of button "Cancel" of me to true
end initialize

command finalize
  set the thumbPosition of scrollbar "Progress Scrollbar" of me to the endValue of scrollbar "Progress Scrollbar" of me - the thumbSize of scrollbar "Progress Scrollbar" of me
  wait 50 milliseconds with messages
  set the visible of scrollbar "Progress Scrollbar" of me to false
  set the visible of button "Cancel" of me to false
end finalize

command update pAmountDone, pTotalAmount
   set the startValue of scrollbar "Progress Scrollbar" of me to 0
  if pTotalAmount is an integer then
    set the endValue of scrollbar "Progress Scrollbar" of me to pTotalAmount
    set the thumbPosition of scrollbar "Progress Scrollbar" of me to pAmountDone
  end if
end update

command updateControls
   set the loc of button "Cancel" of me to (item 1 of the loc of button "Cancel" of me), (item 2 of the loc of scrollbar "Progress Scrollbar" of me)
end updateControls


on preOpenCard
  # block this to prevent the mainstack's handler executing
end preOpenCard

on preOpenStack
  # block this to prevent the mainstack's handler executing
end preOpenStack

on openCard
    # block this to prevent the mainstack's handler executing
end openCard

on openStack
  # block this to prevent the mainstack's handler executing
end openStack

on closeCard
  # block this to prevent the mainstack's handler executing
end closeCard

on closeStack
  # block this to prevent the mainstack's handler executing
end closeStack














