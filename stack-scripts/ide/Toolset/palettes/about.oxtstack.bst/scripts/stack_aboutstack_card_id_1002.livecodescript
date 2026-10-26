script "stack_aboutstack_card_id_1002"
-- Stack file: ide/Toolset/palettes/about.oxtstack
-- Object: stack "aboutstack" > card "id 1002" (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on opencard
   show fld "ttext" of group "sharedbits"
   set the tooltip of fld "ttext" of group "sharedbits" to ""
end opencard


on returnkey
   send mouseup to btn "close"
end returnkey

on enterkey
   returnkey
end enterkey
