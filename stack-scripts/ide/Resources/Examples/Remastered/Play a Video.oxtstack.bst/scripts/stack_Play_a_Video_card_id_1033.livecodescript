script "stack_Play_a_Video_card_id_1033"
-- Stack file: ide/Resources/Examples/Remastered/Play a Video.oxtstack
-- Object: stack "Play a Video" > card "Properties" (id 1033)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenCard  --what the Theater's player has now, and the code in a code font
   local tPlayer, tFont, tError
   put the long id of player "Movie" of card "Theater" into tPlayer
   set the itemDelimiter to slash
   put the last item of the filename of tPlayer into field "Now_filename"
   set the itemDelimiter to comma
   if field "Now_filename" is empty then
      put "(none)" into field "Now_filename"
   end if
   put the paused of tPlayer into field "Now_paused"
   put the currentTime of tPlayer into field "Now_currentTime"
   put the duration of tPlayer into field "Now_duration"
   put the timeScale of tPlayer into field "Now_timeScale"
   put the playRate of tPlayer into field "Now_playRate"
   put the looping of tPlayer into field "Now_looping"
   put the showController of tPlayer into field "Now_showController"
   if the environment is "development" and "Source Code Pro" is not among the lines of the fontNames then
      try  --(the IDE carries it for its Script Editor, as the scripts panel knows)
         start using font file (revIDESpecialFolderPath("fonts") & "/SourceCodePro-Regular.ttf")
      catch tError
      end try
   end if
   repeat for each item tFont in "Source Code Pro,Droid Sans Mono,Menlo,Consolas,DejaVu Sans Mono,Courier New"
      if tFont is among the lines of the fontNames then
         set the textFont of field "Code" to tFont
         exit repeat
      end if
   end repeat
   pass preOpenCard
end preOpenCard
