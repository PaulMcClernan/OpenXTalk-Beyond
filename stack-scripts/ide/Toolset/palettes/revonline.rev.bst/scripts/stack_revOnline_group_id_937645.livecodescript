script "stack_revOnline_group_id_937645"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "viewing pane" (id 31859) > group "stack" (id 31860) > group "chooser" (id 937645)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local sContentType
local sMode

getProp cContentType
   return sContentType
end cContentType

setProp cContentType pType
   lock screen
   put pType into sContentType
   resize
   unlock screen
end cContentType

getProp cMode
   return sMode
end cMode

setProp cMode pMode
   put pMode into sMode
end cMode


command resize
   hide group "stack upload" of the owner of me
   hide group "code upload" of the owner of me
   hide group "external upload" of the owner of me
   
   if the cMode of me is "update" then
      set the rect of field "please select" of me to \
             (the left of me, the top of me - 28, the right of me, the top of me - 28)
   else
      set the rect of field "please select" of me to \
             (the left of me, the top of me, the right of me, the top of me + 32)
   end if
 
   if sContentType is "code" or sContentType is "code snippet" then
      set the topleft of button "stack" of me to (the left of me + 4, the bottom of field "please select" of me + 6)
      set the topleft of button "code" of me to (the right of button "stack" of me - 1, the bottom of field "please select" of me + 4)
      set the topleft of button "external" of me to (the right of button "code" of me - 1, the bottom of field "please select" of me + 6)
      set the rect of graphic "left tab top" of me to \
             (the left of me, the bottom of button "code" of me - 3, the left of button "code" of me + 1, the bottom of button "code" of me - 2)
      set the rect of graphic "right tab top" of me to \
             (the right of button "code" of me - 1, the bottom of button "code" of me - 3, the right of me, the bottom of button "code" of me - 2)
      show group "code upload" of me
      
   else if sContentType is "external" then
      set the topleft of button "stack" of me to (the left of me + 4, the bottom of field "please select" of me + 6)
      set the topleft of button "code" of me to (the right of button "stack" of me - 1, the bottom of field "please select" of me + 6)
      set the topleft of button "external" of me to (the right of button "code" of me - 1, the bottom of field "please select" of me + 4)
      set the rect of graphic "left tab top" of me to \
             (the left of me, the bottom of button "external" of me - 3, the left of button "external" of me + 1, the bottom of button "external" of me - 2)
      set the rect of graphic "right tab top" of me to \
             (the right of button "external" of me - 1, the bottom of button "external" of me - 3, the right of me, the bottom of button "external" of me - 2)
      show group "external upload" of me
      
   else
      set the topleft of button "stack" of me to (the left of me + 4, the bottom of field "please select" of me + 4)
      set the topleft of button "code" of me to (the right of button "stack" of me - 1, the bottom of field "please select" of me + 6)
      set the topleft of button "external" of me to (the right of button "code" of me - 1, the bottom of field "please select" of me + 6)
      set the rect of graphic "left tab top" of me to \
             (the left of me, the bottom of button "stack" of me - 3, the left of button "stack" of me + 1, the bottom of button "stack" of me - 2)
      set the rect of graphic "right tab top" of me to \
             (the right of button "stack" of me - 1, the bottom of button "stack" of me - 3, the right of me, the bottom of button "stack" of me - 2)
      show group "stack upload" of me
   end if
   
   set the rect of group "stack upload" of me to (the left of me, the bottom of field "please select" of me + 25, the right of me, the bottom of me)
   send "resize" to group "stack upload" of me
   set the rect of group "external upload" of me to the rect of group "stack upload" of me
   send "resize" to group "external upload" of me
   set the rect of group "code upload" of me to the rect of group "stack upload" of me
   send "resize" to group "code upload" of me
end resize













