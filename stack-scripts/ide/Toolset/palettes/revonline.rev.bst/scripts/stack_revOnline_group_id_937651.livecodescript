script "stack_revOnline_group_id_937651"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "viewing pane" (id 31859) > group "stack" (id 31860) > group "chooser" (id 937645) > group "stack upload" (id 937651)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local sNames

command resize
   updateRecentlyOpenedStacks
   lock screen
   set the topleft of field "stack upload title" of me to (the left of me + 4, the top of me + 8)
   set the topleft of field "recent stacks title" of me to (the left of me + 4, the bottom of field "stack upload title" of me + 4)
   set the rect of field "recent files" of me to \
          (the left of me + 6, the bottom of field "recent stacks title" of me, the right of me, the bottom of me - 80)   
   
   put sNames into field "recent files" of me
   repeat until the formattedheight of field "recent files" of me < the height of field "recent files" of me
      delete line -1 of field "recent files" of me
   end repeat
     
   
   set the topright of button "browse" of me to (the right of me - 8, the bottom of field "recent files" of me + 5)
   set the rect of field "stack path" of me to \
          (the left of me + 12, the bottom of field "recent files" of me + 5, the left of button "browse" of me - 8, the bottom of field "recent files" of me + 27)
   set the rect of image "stack path background" of me to \
          (the left of me + 12, the bottom of field "recent files" of me + 5, the left of button "browse" of me - 8, the bottom of field "recent files" of me + 27)
   
   set the bottomleft of button "ok" of me to (the left of me + 6, the bottom of me - 4)
   set the bottomleft of button "cancel" of me to (the right of button "ok" of me + 6, the bottom of me - 4)
   --updateRecentStacks
   unlock screen
end resize

command updateRecentlyOpenedStacks
   local tRecentStacks
   put revIDERecentStacks() into tRecentStacks 
   
   local tPaths, tNames
   repeat with x = 1 to the number of elements in tRecentStacks
      put tRecentStacks[x]["label"] & return after tNames
      put tRecentStacks[x]["filename"] & return after tPaths
   end repeat
   delete char -1 of tPaths
   delete char -1 of tNames
   
   --put tNames into field "recent files" of me
   put tNames into sNames
   
   repeat until (the formattedheight of field "recent files" of me - 2) < the height of field "recent files" of me
      delete line -1 of field "recent files" of me
      delete line -1 of tPaths
   end repeat   
   set the cStackIds of field "recent files" of me to tPaths
end updateRecentlyOpenedStacks







