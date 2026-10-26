script "stack_aboutstack_card_id_1013"
-- Stack file: ide/Toolset/palettes/about.oxtstack
-- Object: stack "aboutstack" > card (id 1013)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on opencard
   hide fld "ttext" of group "sharedbits"
   set the tooltip of fld "ttext" of group "sharedbits" to "click the text to hide"
end opencard

