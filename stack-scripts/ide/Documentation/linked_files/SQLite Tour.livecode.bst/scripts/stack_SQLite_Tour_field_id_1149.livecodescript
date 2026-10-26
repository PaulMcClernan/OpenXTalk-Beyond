script "stack_SQLite_Tour_field_id_1149"
-- Stack file: ide/Documentation/linked_files/SQLite Tour.livecode
-- Object: stack "SQLite Tour" > card "Introduction" (id 1002) > group "ChapterSlider" (id 1021) > field "SliderValue" (id 1149)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   ask "Go to card..." with "10" titled "Navigate"
   if it = empty or it is not an integer or it <= "0" or it > the number of cds then exit to top
   go cd it
end mouseUp
