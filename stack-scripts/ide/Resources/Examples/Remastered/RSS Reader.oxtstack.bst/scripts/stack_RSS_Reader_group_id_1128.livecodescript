script "stack_RSS_Reader_group_id_1128"
-- Stack file: ide/Resources/Examples/Remastered/RSS Reader.oxtstack
-- Object: stack "RSS Reader" > card "Import" (id 1031) > group "Import" (id 1128)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

-- via theotherbassist, April 2016
--(Remastered for OXT-Beyond, 2026: the lines marked "(2026)" are new or changed, and say why)

on mouseUp
   local tURL, tCurrent, x, tTREE, tTotal, tTitle, tA, tContentArray, tXML, tContent  --(2026) declared, for strict compilation
   put fld "feed" into tURL
   put 1 into tCurrent
   put 1 into x
   --(2026) was: put revXMLCreateTreeFromFile(tURL, false, true, false) into tTREE
   --that reads a file, or an http address, but not an https one, and the feeds are all https now:
   --so url fetches the feed, and revXMLCreateTree makes the tree from its text
   put url tURL into tXML
   put revXMLCreateTree(tXML,false,true,false) into tTREE
   put revXMLNumberOfChildren(tTree, "/rss/channel/", "item", 0) into tTotal
   if tTotal is not an integer or tTotal < 1 then  --(2026) no feed came: the loop below would never end
      answer "Sorry, no feed came from that address. Check it, and that this computer is online" && \
            "(in a browser, the feed's site must allow other pages to read it)." with "OK" titled "Import"
      exit mouseUp
   end if

   repeat
   put "/rss/channel/item[" & tCurrent & "]/title" into tTitle
   put revXMLNodeContents(tTREE, tTitle) into tA
   put tA & return into line 1 of tContentArray[x]
   if tTotal <= tCurrent then  --(2026) was "<": that read one item past the last, and showed an error
      revXMLDeleteAllTrees
      --(2026) was: combine tContentArray using return
      --combine puts the elements in the order of their keys as text (1, 10, 11, ... 19, 2, 20), so the
      --tenth title came second: this puts them in the order the feed has them, as combine would join them
      repeat with x = 1 to tTotal
         put tContentArray[x] after tContent
         if x < tTotal then put return after tContent
      end repeat
      put tContent into tContentArray  --(2026) the titles, joined, where combine left them
      set the unicodetext of fld "content" to uniEncode(tContentArray,"UTF8")
      --(2026) the newer way to say the same: put textDecode(tContent, "UTF-8") into fld "content"
      showThumb "content"  --(2026) the thumb beside the list, which the wheel scrolls
      exit repeat
   else
      add 1 to x
      add 1 to tCurrent
      next repeat
      end if
   end repeat

end mouseUp
