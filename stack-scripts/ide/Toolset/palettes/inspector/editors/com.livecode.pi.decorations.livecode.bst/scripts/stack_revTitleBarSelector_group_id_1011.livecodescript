script "stack_revTitleBarSelector_group_id_1011"
-- Stack file: ide/Toolset/palettes/inspector/editors/com.livecode.pi.decorations.livecode
-- Object: stack "com.livecode.pi.decorations" > substack "revTitleBarSelector" > card (id 1002) > group "decorations" (id 1011)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on openCard
   if the platform is "MacOS" then 
      set the itemDel to "."
      if item 1 of the systemVersion < 10 then
         put the hiliteColor into tColor
      else
         put "57,115,193" into tColor
      end if   
   else
      put the accentColor into tColor
   end if
   repeat with i = 1 to the num of controls
      if the owner of control i is me then
         set the hiliteColor of control i to tColor
      end if
   end repeat
   put the cDecorations of this stack into tDecorations
   if tDecorations is empty then
      put "empty" into tDecorations
   else if tDecorations is "title,menu,minimize,maximize,close" then
      put "default" into tDecorations
   end if
   
   hilite button tDecorations of me
   revUpdateDescription tDecorations
end openCard

on mouseUp
  if the owner of the target is the name of me then
    put the short name of the target into tDecorations
    revUpdateDescription tDecorations   
  end if
end mouseUp

on revUpdateDescription pDecorations
  put toUpper(char 1 of pDecorations) into char 1 of pDecorations
  replace comma with comma & space in pDecorations    
  put pDecorations into fld "Description"
end revUpdateDescription

on mouseDoubleUp
  local tTarget
  put the short name of the target into tTarget
  setDecorations tTarget, true
end mouseDoubleUp


