script "stack_RecentStacksAsGallery"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > substack "RecentStacksAsGallery"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on openstack
   send opencard to card 1 of this stack
end openstack


on refreshStack
   set cursor to watch
   lock screen
   send closecard to card 1 of this stack
   unlock screen
end refreshStack
