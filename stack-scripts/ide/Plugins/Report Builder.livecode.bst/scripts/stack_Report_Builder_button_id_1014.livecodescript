script "stack_Report_Builder_button_id_1014"
-- Stack file: ide/Plugins/Report Builder.livecode
-- Object: stack "Report Builder" > card (id 1002) > button "Print Report" (id 1014)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --print report to pdf or paper
   local tPrint, tMargins, tHeader, tFooter
   if fld "Text" of stack "Report" = empty then
      answer "Sorry, there's nothing to print." with "OK" titled "Error"
      exit to top
   end if
   put the hilitedButtonName of grp "Print" into tPrint  --pdf,paper
   if the hilitedButtonName of grp "Margins" = "HalfInch" then put "36,36,36,36" into tMargins  --.5"=36px
   else put "72,72,72,72" into tMargins  --1"=72px
   if the hilite of btn "Header" of grp "Options" then put tab& "<%pageNumber%> of <%numPages%>" into tHeader  --centered pg/pgs
   else if the hilite of btn "Footer" of grp "Options" then put tab& "<%pageNumber%> of <%numPages%>" into tFooter  --centered pg/pgs
   set the printPaperOrientation to "portrait"  --portrait, landscape
   set the printMargins to tMargins  --L,T,R,B
   set the printPaperSize to (the width of stack "Report" + (item 1 of tMargins*2)) &","& (the height of stack "Report" + (item 2 of tMargins*2))  --stack w&h + margins
   set the fixedLineHeight of fld "Text" of stack "Report" to "true"  --required for forced page breaks with revPrintField
   revShowPrintDialog false,false  --no page setup, no print dialogs
   if tPrint = "pdf" then  --print to pdf
      answer "Please select your" &&quote& "Print-To-PDF/XPS" &quote&& "program instead of your printer." &cr&cr& \
            the availablePrinters with "Cancel" or "OK" titled "Print To PDF"
   else if tPrint = "paper" then  --print to paper
      answer "Is printer on and paper ready to print?" &cr& "Please select your printer." with "Cancel" or "OK" titled "Print To Paper"
   end if
   if it = "Cancel" then exit to top
   answer printer  --choose printer
   if result() = "Cancel" then exit to top
   revPrintField the long name of fld "Text" of stack "Report",tHeader,tFooter  --print with formatting,header,footer
   reset printing  --default
end mouseUp
