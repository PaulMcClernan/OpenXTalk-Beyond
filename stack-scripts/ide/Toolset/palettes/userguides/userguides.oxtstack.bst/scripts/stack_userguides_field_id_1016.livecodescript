script "stack_userguides_field_id_1016"
-- Stack file: ide/Toolset/palettes/userguides/userguides.oxtstack
-- Object: stack "userguides" > card "Contents" (id 1002) > group "ttitle" (id 1006) > field "tActualContent" (id 1016)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on linkClicked plink
   set cursor to watch
   if plink is "go next card" then
      go next card
      send tRefreshIndex to fld "ClickList"
      exit linkClicked
   end if
   if plink is "go prev card" then
      go prev card
      send tRefreshIndex to fld "ClickList"
      exit linkClicked
   end if
   --
   if there is a card plink then
      go card plink
      send tRefreshIndex to fld "ClickList"
   else
      if plink contains "http" then
         -- is an online location
         launch url (plink)
      end if
      if plink contains "launch document" then
         -- is a local file
         do plink
      end if
   end if
end linkClicked

