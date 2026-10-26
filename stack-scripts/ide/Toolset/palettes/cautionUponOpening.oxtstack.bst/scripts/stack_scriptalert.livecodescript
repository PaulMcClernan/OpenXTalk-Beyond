script "stack_scriptalert"
-- Stack file: ide/Toolset/palettes/cautionUponOpening.oxtstack
-- Object: stack "cautionUponOpening" > substack "scriptalert"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preopenstack
   -- put wd in middle of screen
   set the itemdelimiter to ","
   set the loc of this stack to item 3 of the screenrect /2, item 4 of the screenrect /2
end preopenstack
