script "stack_RSS_Reader_card_id_1032"
-- Stack file: ide/Resources/Examples/Remastered/RSS Reader.oxtstack
-- Object: stack "RSS Reader" > card "Reader" (id 1032)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--The Reader: pick a feed, read its stories, open one in your browser.
--It reads a feed as the Import card does (theotherbassist's script, 2016).
--url fetches the feed's text, and revXMLCreateTree makes a tree of it.
--revXMLNumberOfChildren counts its items, and revXMLNodeContents reads each one's title by its path:
--/rss/channel/item[3]/title.
--This card reads each item's date, link and summary too, and Atom feeds as well.

constant kMonths = "Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec"
constant kMost = 50  --stories at most
--Time zones a feed may write as letters, and as numbers
constant kZones = "GMT +0000,UTC +0000,UT +0000,Z +0000,EST -0500,EDT -0400,CST -0600,CDT -0500,MST -0700,MDT -0600,PST -0800,PDT -0700"
--HTML's names for some letters, and their numbers (&amp; last: "&amp;lt;" means the text "&lt;")
constant kEntities = "nbsp 32,quot 34,apos 39,lt 60,gt 62,lsquo 8216,rsquo 8217,ldquo 8220,rdquo 8221,ndash 8211,mdash 8212,hellip 8230,amp 38"

local sBusy  --true while a feed is on its way
local sWaiting  --a feed that came while another card was in front

on preOpenCard
   if sWaiting is not empty then
      showFeed sWaiting
      put empty into sWaiting
   else if the number of lines of field "Stories" is 0 and not sBusy then
      showNote "rss", "Pick a feed to read", "Choose one above, or paste the address of any news feed, then press Read."
   end if
   pass preOpenCard
end preOpenCard

on returnInField  --Return in the address reads the feed
   if the short name of the target is "URL" then
      readFeed the text of field "URL"
   else
      pass returnInField
   end if
end returnInField

on enterInField
   returnInField
end enterInField

on arrowKey pKey  --up and down go from story to story
   if the selectedField is empty and (pKey is "up" or pKey is "down") and the cShown of me is an integer then
      if pKey is "up" then
         showStory the cShown of me - 1
      else
         showStory the cShown of me + 1
      end if
   else
      pass arrowKey
   end if
end arrowKey

-- Fetches a feed, and lists its stories
command readFeed pURL
   local tXML, tProblem
   if sBusy then exit readFeed  --(one feed at a time)
   put word 1 to -1 of pURL into pURL
   if pURL is empty then
      showNote "rss", "Which feed?", "Pick one above, or paste the address of a feed into the box."
      exit readFeed
   end if
   if "://" is not in pURL and not (pURL begins with "file:") then
      put "https://" before pURL  --(an address typed without its https://)
   end if
   put pURL into field "URL"
   markFeed pURL
   clearStories
   showNote "wait", "Reading the feed" & numToCodepoint(8230), pURL
   put true into sBusy
   put url pURL into tXML  --this waits until the feed has come, or has not
   put the result into tProblem
   put false into sBusy
   --(while it waited, the window may have gone to another card: the stories wait for this one)
   set the defaultStack to the short name of the owner of me
   if the long id of this card is not the long id of me then
      put tXML into sWaiting
      exit readFeed
   end if
   if tXML is empty or tProblem is not empty then
      showNote "offline", "The feed did not come", whyNot(tProblem)
      exit readFeed
   end if
   showFeed tXML
end readFeed

-- Why a feed may not come, in words
function whyNot pProblem
   if the platform is "HTML5" then
      return "A web page may read a feed from another site only if that site allows it, and this one does not." && \
            "Try another feed, or open RSS Reader in the desktop IDE, which reads any feed."
   end if
   if pProblem is empty then
      put "nothing came back" into pProblem
   end if
   return "This computer may be offline, or the site did not answer (" & pProblem & ")." && \
         "Check the address, or try another feed."
end whyNot

-- Lists the stories of a feed's text: a tree of its XML, its items counted, and each one read by its path
command showFeed pXML
   local tTree, tHead, tParent, tChild, tCount, tIndex, tPath, tStories, tLink
   put revXMLCreateTree(pXML, false, true, false) into tTree  --(the feed's bytes, as url gives them)
   if tTree is an integer and revXMLRootNode(tTree) is empty then  --(text that is not XML at all)
      revXMLDeleteTree tTree
      put "xmlerr" into tTree
   end if
   if tTree begins with "xmlerr" then
      showNote "alert", "That is not a feed", "The address answered with a page, not a feed. A site's feed often has an address that ends in /rss or /feed."
      exit showFeed
   end if
   switch revXMLRootNode(tTree)
      case "rss"  --RSS 2.0, as the Import card reads it: /rss/channel/item[1]
         put "/rss/channel" into tParent
         put "item" into tChild
         put "/rss/channel/title" into tHead
         break
      case "feed"  --Atom: /feed/entry[1]
         put "/feed" into tParent
         put "entry" into tChild
         put "/feed/title" into tHead
         break
      case "RDF"  --RSS 1.0, <rdf:RDF>: revXML names a tag without its prefix, so /RDF/item[1]
         put "/RDF" into tParent
         put "item" into tChild
         put "/RDF/channel/title" into tHead
         break
   end switch
   if tParent is not empty then
      put revXMLNumberOfChildren(tTree, tParent, tChild, 0) into tCount
   end if
   if tCount is not an integer or tCount < 1 then
      revXMLDeleteTree tTree
      showNote "alert", "No stories there", "The address answered with XML, but there are no stories in it."
      exit showFeed
   end if
   repeat with tIndex = 1 to min(tCount, kMost)
      put tParent & "/" & tChild & "[" & tIndex & "]" into tPath
      put textOfHtml(nodeText(tTree, tPath & "/title")) into tStories[tIndex]["title"]
      put firstOf(tTree, tPath, "pubDate,updated,published,date") into tStories[tIndex]["date"]  --(date: <dc:date>)
      put textOfHtml(firstOf(tTree, tPath, "description,summary,content")) into tStories[tIndex]["summary"]
      put word 1 to -1 of firstOf(tTree, tPath, "link,guid") into tLink
      if tLink is empty then
         put nodeAttribute(tTree, tPath & "/link", "href") into tLink  --(Atom's: <link href="..."/>)
      end if
      put tLink into tStories[tIndex]["link"]
   end repeat
   set the cChannel of me to textOfHtml(nodeText(tTree, tHead))
   revXMLDeleteTree tTree
   set the cStories of me to tStories
   listStories
   showStory 1
end showFeed

-- The text at a path in the tree, or empty if the feed has nothing there
function nodeText pTree, pPath
   local tText
   put revXMLNodeContents(pTree, pPath) into tText
   if tText begins with "xmlerr" then
      return empty
   end if
   return textDecode(tText, "UTF-8")  --(revXML gives its text as UTF-8)
end nodeText

-- The text of the first of some tags an item has: feeds name the same thing differently
function firstOf pTree, pPath, pTags
   local tTag, tText
   repeat for each item tTag in pTags
      put nodeText(pTree, pPath & "/" & tTag) into tText
      if tText is not empty then
         return tText
      end if
   end repeat
   return empty
end firstOf

function nodeAttribute pTree, pPath, pName
   local tText
   put revXMLAttribute(pTree, pPath, pName) into tText
   if tText begins with "xmlerr" then
      return empty
   end if
   return textDecode(tText, "UTF-8")
end nodeAttribute

-- The words of a bit of HTML: its tags out, its entities (&amp; &#8217;) made letters
function textOfHtml pHtml
   local tText, tWhole, tHex, tCode, tEntity
   put replaceText(pHtml, "<[^>]*>", " ") into tText  --a tag becomes a space
   repeat while matchText(tText, "(&#([xX]?)([0-9a-fA-F]{1,6});)", tWhole, tHex, tCode)  --a letter by its number
      if tHex is not empty then
         put baseConvert(tCode, 16, 10) into tCode
      end if
      if tCode is an integer and tCode >= 32 and tCode <= 1114111 and (tCode < 55296 or tCode > 57343) then
         replace tWhole with numToCodepoint(tCode) in tText
      else
         replace tWhole with space in tText
      end if
   end repeat
   repeat for each item tEntity in kEntities  --a letter by its name
      replace "&" & word 1 of tEntity & ";" with numToCodepoint(word 2 of tEntity) in tText
   end repeat
   return word 1 to -1 of replaceText(tText, "\s+", " ")  --one space between words
end textOfHtml

-- When a story came, in words: "40 min ago", "5 h ago", or its day.
-- RSS writes a date "Sat, 18 Oct 2026 10:15:00 GMT", and Atom "2026-10-18T10:15:00Z"
function friendlyDate pDate
   local tWhen, tZone, tAgo
   put word 1 to -1 of pDate into tWhen
   if char 5 of tWhen is "-" and char 8 of tWhen is "-" then
      put rssDate(tWhen) into tWhen  --(Atom's way, written RSS's way)
   end if
   if the last char of word 1 of tWhen is not comma then
      put "Mon, " before tWhen  --(convert wants a day of the week first, but does not check it)
   end if
   repeat for each item tZone in kZones  --(convert wants a time zone as a number)
      if word -1 of tWhen is word 1 of tZone then
         put word 2 of tZone into word -1 of tWhen
         exit repeat
      end if
   end repeat
   if matchText(word -2 of tWhen, "^[0-9]{1,2}:[0-9]{2}$") then
      put ":00" after word -2 of tWhen  --(and its seconds)
   end if
   convert tWhen from internet date to seconds
   if tWhen is not an integer then  --(a date convert cannot read: its day, as it is written)
      if char 5 of pDate is "-" then
         return char 1 to 10 of pDate
      end if
      return word 2 to 4 of pDate
   end if
   put the seconds - tWhen into tAgo
   if tAgo < 60 then
      return "just now"
   else if tAgo < 3600 then
      return tAgo div 60 && "min ago"
   else if tAgo < 86400 then
      return tAgo div 3600 && "h ago"
   else if tAgo < 172800 then
      return "yesterday"
   end if
   convert tWhen to dateItems
   return item 3 of tWhen && word (item 2 of tWhen) of kMonths && item 1 of tWhen
end friendlyDate

-- An Atom date in RSS's way: "2026-10-18T10:15:00+01:00" is "18 Oct 2026 10:15:00 +0100"
function rssDate pDate
   local tYear, tMonth, tDay, tTime, tHour, tMinute, tSeconds, tSecond, tZoneHours, tZoneMinutes, tZone, tPattern
   put "^([0-9]{4})-([0-9]{2})-([0-9]{2})" into tPattern  --a day: 2026-10-18
   put "(T([0-9]{2}):([0-9]{2})" after tPattern  --then perhaps a time: T10:15
   put "(:([0-9]{2}))?)?" after tPattern  --perhaps with seconds: :00
   if not matchText(pDate, tPattern, tYear, tMonth, tDay, tTime, tHour, tMinute, tSeconds, tSecond) then
      return pDate
   end if
   if tHour is empty then
      put "00" into tHour
      put "00" into tMinute
   end if
   if tSecond is empty then
      put "00" into tSecond
   end if
   if matchText(pDate, "([+-][0-9]{2}):?([0-9]{2})$", tZoneHours, tZoneMinutes) then
      put tZoneHours & tZoneMinutes into tZone
   else
      put "+0000" into tZone  --(Z, or none: the time is UTC)
   end if
   return (tDay + 0) && word (tMonth + 0) of kMonths && tYear && tHour & ":" & tMinute & ":" & tSecond && tZone
end rssDate

-- The list: each story's title, and under it when it came
command listStories
   local tStories, tCount, tIndex, tHtml, tWhen
   put the cStories of me into tStories
   put the number of elements of tStories into tCount
   repeat with tIndex = 1 to tCount
      put friendlyDate(tStories[tIndex]["date"]) into tWhen
      if tWhen is empty then
         put the cChannel of me into tWhen
      end if
      put "<p><b>" & htmlOf(tStories[tIndex]["title"]) & "</b></p>" & \
            "<p><font size=" & quote & "11" & quote & " color=" & quote & "#94a3b8" & quote & ">" & htmlOf(tWhen) & "</font></p>" after tHtml
   end repeat
   set the htmlText of field "Stories" to tHtml
   set the visible of group "Placeholder" to (tCount is 0)
   hide field "ListEmpty"
   repeat with tIndex = 1 to tCount
      set the spaceAbove of line (2 * tIndex - 1) of field "Stories" to 6
      set the spaceBelow of line (2 * tIndex) of field "Stories" to 8
   end repeat
   set the vScroll of field "Stories" to 0
   showThumb "Stories"
   put "<b>" & htmlOf(the cChannel of me) & "</b><font color=" & quote & "#94a3b8" & quote & ">  " & \
         numToCodepoint(183) & "  " & tCount && "stories</font>" into tHtml
   set the htmlText of field "ListHead" to tHtml
end listStories

function htmlOf pText
   replace "&" with "&amp;" in pText
   replace "<" with "&lt;" in pText
   replace ">" with "&gt;" in pText
   return pText
end htmlOf

-- A story's title, when it came, where it is and what it says, on the panel at the right
command showStory pIndex
   local tStories, tLink, tTop, tText
   put the cStories of me into tStories
   if pIndex is not an integer or tStories[pIndex] is not an array then
      exit showStory
   end if
   set the cShown of me to pIndex
   put toUpper(the cChannel of me) into field "Source"
   put tStories[pIndex]["title"] into field "Headline"
   put tStories[pIndex]["link"] into tLink
   set the itemDelimiter to slash
   put friendlyDate(tStories[pIndex]["date"]) into field "When"
   if item 3 of tLink is not empty then  --the site the link goes to
      if field "When" is not empty then
         put "  " & numToCodepoint(183) & "  " after field "When"
      end if
      put replaceText(item 3 of tLink, "^www\.", "") after field "When"
   end if
   set the itemDelimiter to comma
   put tStories[pIndex]["summary"] into tText
   if the number of chars of tText > 600 then  --(a long one: its first words, and an ellipsis)
      put char 1 to 600 of tText into tText
      put word 1 to -2 of tText & numToCodepoint(8230) into tText
   end if
   put tText into field "Summary"
   -- (the title takes the lines it needs, and the rest follows it)
   set the height of field "Headline" to min(the formattedHeight of field "Headline", 108)
   set the top of field "Headline" to the bottom of field "Source" + 4
   set the top of field "When" to the bottom of field "Headline" + 4
   put the bottom of field "When" + 10 into tTop
   set the rect of field "Summary" to the left of field "Summary", tTop, the right of field "Summary", the top of group "Open" - 12
   -- (a summary too long for its room loses words at its end, and ends with an ellipsis)
   repeat while the formattedHeight of field "Summary" > the height of field "Summary" and the number of words of field "Summary" > 1
      put word 1 to -2 of field "Summary" & numToCodepoint(8230) into field "Summary"
   end repeat
   set the cLink of group "Open" to tLink
   if tLink begins with "http" then
      set the blendLevel of group "Open" to 0
   else
      set the blendLevel of group "Open" to 60
   end if
   hide group "Note"
   show group "Story"
   showPick true
end showStory

-- The tint behind the story shown, in the list; pScroll scrolls the list to it
command showPick pScroll
   local tIndex, tRect, tTop, tBottom
   put the cShown of me into tIndex
   if tIndex is not an integer or the number of lines of field "Stories" < 2 * tIndex then
      hide graphic "Pick"
      exit showPick
   end if
   put the formattedRect of line (2 * tIndex - 1) to (2 * tIndex) of field "Stories" into tRect
   put item 2 of tRect - 6 into tTop
   put item 4 of tRect + 6 into tBottom
   if pScroll is true and tTop < the top of field "Stories" then
      set the vScroll of field "Stories" to the vScroll of field "Stories" - (the top of field "Stories" - tTop) - 4
      showThumb "Stories"
      showPick false
      exit showPick
   else if pScroll is true and tBottom > the bottom of field "Stories" then
      set the vScroll of field "Stories" to the vScroll of field "Stories" + (tBottom - the bottom of field "Stories") + 4
      showThumb "Stories"
      showPick false
      exit showPick
   end if
   set the rect of graphic "Pick" to the left of field "Stories" + 2, tTop, the right of field "Stories" - 10, tBottom
   show graphic "Pick"
end showPick

on listScrolled  --the wheel scrolled the list: the tint follows its story
   showPick false
end listScrolled

-- A note on the panel at the right, in place of a story: an icon, a title, a line or two
command showNote pIcon, pTitle, pText
   local tName, tTop
   repeat for each item tName in "rss,wait,offline,alert"
      set the visible of image ("Note_" & tName) to (tName is pIcon)
   end repeat
   put pTitle into field "Note_title"
   put pText into field "Note_text"
   set the height of field "Note_text" to the formattedHeight of field "Note_text" + 4
   -- (all of it in the middle of the panel, up and down)
   put item 2 of the loc of graphic "Panel" - (64 + 16 + 24 + 6 + the height of field "Note_text") div 2 into tTop
   set the top of graphic "Note_circle" to tTop
   repeat for each item tName in "rss,wait,offline,alert"
      set the loc of image ("Note_" & tName) to the loc of graphic "Note_circle"
   end repeat
   set the top of field "Note_title" to tTop + 64 + 16 - 4
   set the top of field "Note_text" to the bottom of field "Note_title" + 6
   hide group "Story"
   show group "Note"
   -- (with no stories, the list has faint lines while a feed is on its way, and else a line that says it is empty)
   if the number of lines of field "Stories" is 0 then
      set the visible of group "Placeholder" to (pIcon is "wait")
      set the visible of field "ListEmpty" to (pIcon is not "wait")
   end if
end showNote

-- No stories: an empty list, before a feed is read
command clearStories
   put empty into field "Stories"
   show group "Placeholder"
   set the cStories of me to empty
   set the cShown of me to empty
   hide graphic "Pick"
   showThumb "Stories"
   put "Stories" into field "ListHead"
end clearStories

-- Lights the button of the feed being read, if it is one of them
command markFeed pURL
   local tIndex, tButton
   repeat with tIndex = 1 to the number of groups of group "Feeds"
      put the long id of group tIndex of group "Feeds" into tButton
      if the cURL of tButton is pURL then
         set the cRest of tButton to the cPicked of tButton
         set the foregroundColor of graphic 1 of tButton to the cPickedLine of tButton
      else
         set the cRest of tButton to "255,255,255"
         set the foregroundColor of graphic 1 of tButton to the cLine of tButton
      end if
      set the backgroundColor of graphic 1 of tButton to the cRest of tButton
   end repeat
end markFeed
