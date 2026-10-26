script "stack_revTitleBarSelector_button_id_1024"
-- Stack file: ide/Toolset/palettes/inspector/editors/com.livecode.pi.decorations.livecode
-- Object: stack "com.livecode.pi.decorations" > substack "revTitleBarSelector" > card (id 1002) > group "decorations" (id 1011) > button "title,menu,minimize,close" (id 1024)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  set the cReturnValue of this stack to "title,menu"
  pass mouseUp
end mouseUp

on mouseDoubleUp
  pass mouseDoubleUp
end mouseDoubleUp
