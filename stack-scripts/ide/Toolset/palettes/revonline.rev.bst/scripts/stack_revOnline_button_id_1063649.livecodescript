script "stack_revOnline_button_id_1063649"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "viewing pane" (id 31859) > group "stack" (id 31860) > group "chooser" (id 937645) > group "external upload" (id 937669) > button "ok" (id 1063649)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   local tPaths
   local tPlatforms
   if the hilite of button "check" of group "windows" of the owner of me and \
          the text of field "path" of group "windows" of the owner of me is not empty then
      put the text of field "path" of group "windows" of the owner of me into tPaths["windows"]
      put "Windows, " after tPlatforms
   end if
   if the hilite of button "check" of group "os x" of the owner of me and \
          the text of field "path" of group "os x" of the owner of me is not empty then
      put the text of field "path" of group "os x" of the owner of me into tPaths["os x"]
      put "Mac OS X, " after tPlatforms
   end if
   if the hilite of button "check" of group "linux" of the owner of me and \
          the text of field "path" of group "linux" of the owner of me is not empty then
      put the text of field "path" of group "linux" of the owner of me into tPaths["linux"]
      put "Linux, " after tPlatforms
   end if
   delete char -1 of tPlatforms
   delete char -1 of tPlatforms
   if the keys of tPaths is empty then
      rvoUpdateTooltip "You must select at least one external"
   else
      if the cMode of group "chooser" of group "stack" of group "viewing pane" of stack "revonline" is "update" then
         newExternalFileUpdate tPaths, tPlatforms
      else
         newExternalFile tPaths, tPlatforms
      end if
   end if
end mouseUp
