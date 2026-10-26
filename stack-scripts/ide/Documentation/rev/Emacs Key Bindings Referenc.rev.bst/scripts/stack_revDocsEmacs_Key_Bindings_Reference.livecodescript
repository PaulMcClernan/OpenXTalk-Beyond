script "stack_revDocsEmacs_Key_Bindings_Reference"
-- Stack file: ide/Documentation/rev/Emacs Key Bindings Referenc.rev
-- Object: stack "revDocsEmacs Key Bindings Reference"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.



on preOpenStack
  switch the platform
  case "MacOS"
    put "Control" into field "Command Key Label"
    put "Option" into field "Option Key Label"
    put "Control-Option" into field "Command-Option Key Label"
    break
  case "Win32"
    put "Control" into field "Command Key Label"
    put "Alt" into field "Option Key Label"
    put "Control-Alt" into field "Command-Option Key Label"
    break
  default
    put "Control" into field "Command Key Label"
    put "Meta" into field "Option Key Label"
    put "Control-Meta" into field "Command-Option Key Label"
  end switch
  pass preOpenStack
end preOpenStack
