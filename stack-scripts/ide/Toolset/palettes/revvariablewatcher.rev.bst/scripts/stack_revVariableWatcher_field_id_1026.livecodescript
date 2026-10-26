script "stack_revVariableWatcher_field_id_1026"
-- Stack file: ide/Toolset/palettes/revvariablewatcher.rev
-- Object: stack "revVariableWatcher" > card "home" (id 1002) > field "Watched" (id 1026)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  put the menuHistory of btn "execution contexts" into tLineNo
  put item 1 of line tLineNo of the cContexts of btn "execution contexts" into tDebuggingObject
  if tDebuggingObject is empty then exit mouseUp
  put word 2 of the clickLine into cl
  put the watchedVariables into wv
  if the clickText is empty then
    put word 2 of the clickLine into tLine
    ask "Stop condition:" with line tLine of field "Names" && " = "
    if the result is "cancel" then exit mouseUp
    put "." & cr into line tLine of me
    set the imageSource of char 1 of line tLine of me to 203451
    put cr & tDebuggingObject & comma & field "handler" & comma & line cl of field "Names" & comma & it after wv
  else
    put cr into the clickLine
    delete line lineOffset(tDebuggingObject & comma & field "handler" & comma & line cl of field "Names", wv) of wv
  end if
  set the watchedVariables to wv
end mouseUp
