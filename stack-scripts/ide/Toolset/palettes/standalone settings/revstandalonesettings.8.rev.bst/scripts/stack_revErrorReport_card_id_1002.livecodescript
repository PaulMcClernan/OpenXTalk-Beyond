script "stack_revErrorReport_card_id_1002"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > substack "revErrorReport" > card (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on escapeKey
  close stack "copy of revErrorReport"
end escapeKey

on preOpenCard
  local tError,tScriptError,tObject,tErrorString,tErrorLine,tUserThrow
  put the executionError of stack "copy of revErrorReport" into tError
  put the scriptError of stack "copy of revErrorReport" into tScriptError
  put the uObject of stack "copy of revErrorReport" into tObject
  set the executionError of stack "copy of revErrorReport" to empty
  set the scriptError of stack "copy of revErrorReport" to empty
  set the uObject of stack "copy of revErrorReport" to empty
  if tError is not empty then
    put "Executing at" && the long time &" on "& the long date & cr into tErrorString
    if item 2 of line 1 of tError is 0 then put "-4" into tErrorLine else put 1 into tErrorLine
    put "Type: " after tErrorString
    put item 1 of line tErrorline of tError into tNumber
    if tNumber is not a number then
      -- user throw
      put true into tUserThrow
      put "Object: "&tObject&cr&"Error: "&tError &cr after tErrorString
    else
      -- rev throw
      put line tNumber of the cErrorsList of stack "copy of revErrorReport" & cr after tErrorString
    end if
  else if tScriptError is not empty then
    put tScriptError into tError
    put "Compiling at" && the long time &" on "& the long date & cr into tErrorString
    put "Type: " & line (item 1 of line 1 of tError) of the cScriptErrors of stack "copy of revErrorReport" & cr after tErrorString
  end if
  if not tUserThrow then
    --    put "Object: " & the short name of tObject & cr after tErrorString
    --    if word 1 to -1 of line (item 2 line 1 of tError) of the script of tObject is empty or item 2 of line 1 of tError is 0 then put "-3" into tLineNo else put 1 into tLineNo
    --    put "Line: "  & word 1 to -1 of line (item 2 of line tLineNo of tError) of the script of tObject & cr after tErrorString
    
    put "Object: " & the long name of tObject & cr after tErrorString 
    try 
      put the script of tObject into tObjScript 
      if word 1 to -1 of line (item 2 line 1 of tError) of tObjScript is empty or item 2 of line 1 of tError is 0 
      then put "-3" into tLineNo else put 1 into tLineNo 
      put "Line: " & word 1 to -1 of line (item 2 of line tLineNo of tError) of tObjScript & cr after tErrorString 
    catch x 
      put 1 into tLineNo 
    end try 
    put "Line Num: " & (item 2 of line 1 of tError) & cr after tErrorString 
     
    put false into tExit
    repeat for each line tLine in tError
      if the number of items in tLine is 4 then
        put true into tExit
        exit repeat
      end if
    end repeat
    if not tExit then put line 1 of tError into tLine
    put "Hint: " & item 4 of tLine after tErrorString
  end if
  set the cReport of stack "copy of revErrorReport" to tErrorString
end preOpenCard
