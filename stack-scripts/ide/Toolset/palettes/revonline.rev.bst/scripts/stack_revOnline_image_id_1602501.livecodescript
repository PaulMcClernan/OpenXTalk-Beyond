script "stack_revOnline_image_id_1602501"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "search filter" (id 1007) > image "revLogo" (id 1602501)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   revOnlineCacheClear
   revOnlineResetRequestIsRunning
   revOnlineQueueClear
   rvoResize
   resetall
end mouseUp
