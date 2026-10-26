script "stack_revDocsSupported_Platforms_Reference"
-- Stack file: ide/Documentation/rev/Supported Platforms Referen.rev
-- Object: stack "revDocsSupported Platforms Reference"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.


on preOpenStack
   set the _ideoverride of me to true
   
  set the textColor of char 1 to (the number of chars of field "Platforms List") \
         of field "Platforms List" to empty
end preOpenStack
