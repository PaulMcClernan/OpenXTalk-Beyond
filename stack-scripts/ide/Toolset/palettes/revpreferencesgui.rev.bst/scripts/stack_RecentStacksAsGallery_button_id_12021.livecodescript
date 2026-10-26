script "stack_RecentStacksAsGallery_button_id_12021"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > substack "RecentStacksAsGallery" > card (id 1002) > button "Refresh" (id 12021)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   send refreshStack to card 1 of stack "RecentStacksAsGallery"
end mousedown
