script "stack_RSS_Reader_card_id_1033"
-- Stack file: ide/Resources/Examples/Remastered/RSS Reader.oxtstack
-- Object: stack "RSS Reader" > card "Inside a Feed" (id 1033)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenCard  --the code in a code font: the first of these that the computer has
   local tFont, tIndex, tError
   if the environment is "development" and "Source Code Pro" is not among the lines of the fontNames then
      try  --(the IDE carries it for its Script Editor, as the scripts panel knows)
         start using font file (revIDESpecialFolderPath("fonts") & "/SourceCodePro-Regular.ttf")
      catch tError
      end try
   end if
   repeat for each item tFont in "Source Code Pro,Droid Sans Mono,Menlo,Consolas,DejaVu Sans Mono,Courier New"
      if tFont is among the lines of the fontNames then
         set the textFont of field "Xml" to tFont
         set the textFont of field "Path_code" to tFont
         repeat with tIndex = 1 to 4
            set the textFont of field ("Lines_code" & tIndex) to tFont
         end repeat
         exit repeat
      end if
   end repeat
   pass preOpenCard
end preOpenCard
