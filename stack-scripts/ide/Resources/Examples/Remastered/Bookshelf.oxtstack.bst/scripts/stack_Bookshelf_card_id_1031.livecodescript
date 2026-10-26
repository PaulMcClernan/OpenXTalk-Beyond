script "stack_Bookshelf_card_id_1031"
-- Stack file: ide/Resources/Examples/Remastered/Bookshelf.oxtstack
-- Object: stack "Bookshelf" > card "How It Works" (id 1031)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

-- The code on this page is in a code font:
-- Source Code Pro, which the IDE carries for
-- its Script Editor, or else the first
-- monospaced font the computer has, as in
-- the panel of scripts. The fields of code
-- have a custom property, cCode, that says so
on preOpenCard
   local tError, tFont, tIndex
   if the environment is "development" and \
         "Source Code Pro" is not among the lines of the fontNames then
      try
         start using font file (revIDESpecialFolderPath("fonts") & "/SourceCodePro-Regular.ttf")
      catch tError
      end try
   end if
   repeat for each item tFont in "Source Code Pro,Droid Sans Mono,Menlo,Consolas,DejaVu Sans Mono,Courier New"
      if tFont is among the lines of the fontNames then
         repeat with tIndex = 1 to the number of controls of me
            if the cCode of control tIndex of me is true then
               set the textFont of control tIndex of me to tFont
            end if
         end repeat
         exit repeat
      end if
   end repeat
   pass preOpenCard
end preOpenCard
