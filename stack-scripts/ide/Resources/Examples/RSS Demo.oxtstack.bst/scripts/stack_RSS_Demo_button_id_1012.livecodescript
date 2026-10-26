script "stack_RSS_Demo_button_id_1012"
-- Stack file: ide/Resources/Examples/RSS Demo.oxtstack
-- Object: stack "RSS Demo" > card (id 1002) > button "Import" (id 1012)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

-- via theotherbassist, April 2016

on mouseUp
   put fld "feed" into tURL
   put 1 into tCurrent
   put 1 into x
   put revXMLCreateTreeFromFile(tURL,false,true,false) into tTREE
   put revXMLNumberOfChildren(tTree, "/rss/channel/", "item", 0) into tTotal
   
   repeat
   put "/rss/channel/item[" & tCurrent & "]/title" into tTitle
   put revXMLNodeContents(tTREE, tTitle) into tA
   put tA & return into line 1 of tContentArray[x]
   if tTotal < tCurrent then
      revXMLDeleteAllTrees
      combine tContentArray using return
      set the unicodetext of fld "content" to uniEncode(tContentArray,"UTF8")
      exit repeat
   else 
      add 1 to x
      add 1 to tCurrent
      next repeat
      end if
   end repeat
   
end mouseUp
