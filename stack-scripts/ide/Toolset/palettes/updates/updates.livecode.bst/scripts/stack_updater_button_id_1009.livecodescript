script "stack_updater_button_id_1009"
-- Stack file: ide/Toolset/palettes/updates/updates.livecode
-- Object: stack "updater" > card (id 1002) > button "whatschanged" (id 1009)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   put the tLogData of this card into tUpdLogFile -- set the update log file as a custom property
   if there is a file tUpdLogFile then
      open file tUpdLogFile
      read from file tUpdLogFile until EOF
      put it into tChangeData
      close file tUpdLogFile
      filter lines of tChangeData with "file: *"
      replace "-SPACE-" with " " in tChangeData -- deal with spaces
      put tChangeData into fld "popmenu" of stack "popstack" of this stack
      if tChangeData contains "whatsnew.txt" then
         put the tLogData of this card into tWhatsNewFile
         replace "update.log" with "whatsnew.txt" in tWhatsNewFile
         if there is a file tWhatsNewFile then
            open file tWhatsNewFile
            read from file tWhatsNewFile until EOF
            put it into tChangesDescription
            close file tWhatsNewFile
            answer tChangesDescription with "Close"
         end if
      end if
      /*
      if the number of lines in tChangeData >0 then
         set the height of fld "popmenu" of stack "popstack" of this stack to (the number of lines in tChangeData *22 ) +8
         set the rect of stack "popstack" of this stack to the rect of fld "popmenu" of stack "popstack" of this stack 
         set the topleft of fld "popmenu" of stack "popstack" of this stack to 0,0
         popup stack "popstack" at the mouseloc
      end if
      */
   else
      beep
   end if
end mousedown


