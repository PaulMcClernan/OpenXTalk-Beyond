script "stack_cautionUponOpening_card_id_1002"
-- Stack file: ide/Toolset/palettes/cautionUponOpening.oxtstack
-- Object: stack "cautionUponOpening" > card (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on closestackrequest
   set the destroystack of this stack to true
   pass closestackrequest
end closestackrequest

on openstack
   set the cantmodify of this stack to true
   pass openstack
end openstack
