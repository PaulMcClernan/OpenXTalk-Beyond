script "stack_CustomScriptCol_card_id_1002"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > substack "CustomScriptCol" > card (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on opencard
   -- this is what I hate about LCC/OXT
   -- why isn't this working??
   send mousedown to button "update" of this stack
   
end opencard

on idle
   if the hasFired of this card is true then exit idle
   -- why do I have to resort to stupid methods like this?
   -- Why doesn't opencard work here?
   set the hasFired of this card to true
   -- set location of this wd
   set the itemdelimiter to ","
   set the loc of this stack to item 3 of the screenrect /2, item 4 of the screenrect /2
   
   send mousedown to button "update" of this stack
end idle

on closecard
   -- thankfully this seems to work!
   set the hasFired of this card to false
   set the backgroundColor of graphic "cSwatch" to ""
   put "" into field "rgbvalue"
   pass closecard
end closecard
