script "stack_aboutstack_field_id_1007"
-- Stack file: ide/Toolset/palettes/about.oxtstack
-- Object: stack "aboutstack" > card "id 1002" (id 1002) > group "sharedbits" (id 1012) > field "ttext" (id 1007)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on linkClicked plink
      if plink contains "http" then
         -- is an online location
         launch url (plink)
      end if
end linkClicked

on mousedown
   put the number of this card of this stack into tCard
   if tCard is 1 then exit mousedown
   hide me
   if tCard is 2 then show group "licbtns"
end mousedown
