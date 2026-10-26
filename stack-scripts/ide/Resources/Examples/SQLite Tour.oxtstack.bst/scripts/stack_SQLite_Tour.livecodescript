script "stack_SQLite_Tour"
-- Stack file: ide/Resources/Examples/SQLite Tour.oxtstack
-- Object: stack "SQLite Tour"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--SQLite Tour v1.0, (c) LiveCode Ltd, edited and debranded for open source as requested by LiveCode Ltd.
--to edit text, on cd 1 in msg box: show btn "Reset Fields"

on openCard
   lock screen
   set the vScroll of fld "TheText" to "0"  --top
   put the short name of this cd into fld "Title"
   put the short name of this cd into fld "Chapter"
   put the number of this cd into fld "SliderValue"
   set the thumbPosition of sb"Scrollbar" to the number of this cd
end openCard
