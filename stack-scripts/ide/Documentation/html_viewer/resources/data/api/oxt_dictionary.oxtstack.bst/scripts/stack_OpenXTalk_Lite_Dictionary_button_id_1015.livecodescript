script "stack_OpenXTalk_Lite_Dictionary_button_id_1015"
-- Stack file: ide/Documentation/html_viewer/resources/data/api/oxt_dictionary.oxtstack
-- Object: stack "OpenXTalk Lite Dictionary" > card (id 1002) > button "export" (id 1015)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   -- Specify the field to be exported
   put the htmlText of field "styledTextField" into tFieldHTML
   
   -- Specify the paths for the HTML and PDF files
   put specialFolderPath("desktop") & "/ExportedField.html" into tHTMLPath
   
   -- Write the HTML content to a file
   put tFieldHTML into url ("file:" & tHTMLPath)
   
   answer "Exported to your desktop as an html file."
   
   -- Use wkhtmltopdf to convert the HTML file to a PDF
   /*
   put "wkhtmltopdf" && quote & tHTMLPath & quote && quote & tPDFPath & quote into tCommand
   get shell(tCommand)
   
   -- Check if the PDF was created successfully
   if there is a file tPDFPath then
      answer "Field has been exported as PDF to" && tPDFPath
   else
      answer "Failed to create PDF."
   end if
   */
   
end mouseUp

