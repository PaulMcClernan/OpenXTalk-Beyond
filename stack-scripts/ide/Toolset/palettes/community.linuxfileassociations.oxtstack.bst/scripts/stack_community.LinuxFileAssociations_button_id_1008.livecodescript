script "stack_community.LinuxFileAssociations_button_id_1008"
-- Stack file: ide/Toolset/palettes/community.linuxfileassociations.oxtstack
-- Object: stack "community.LinuxFileAssociations" > card (id 1002) > button "Add" (id 1008)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   put specialFolderpath("Engine") into tIDEFolder
   put tIDEFolder & "/Resources/Linux/file-associations/mimeIcons.sh" into tScriptPath
   get shell(tScriptPath) -- run the script
   close this stack
end mousedown
