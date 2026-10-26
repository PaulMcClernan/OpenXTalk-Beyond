script "stack_Mobile_Browser_Example_card_id_1002"
-- Stack file: ide/Resources/Mobile Examples/Browser Example.livecode
-- Object: stack "Mobile Browser Example" > card (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

-- We use this variable to store the id of the UIWebView native
-- control.
local sBrowserId

on preOpenCard
   if the environment is not "mobile" then
      exit preOpenCard
   end if
   
   -- Create our browser control and store the id
   iphoneControlCreate "browser"
   put the result into sBrowserId
   
   -- Native controls start off invisible
   iphoneControlSet sBrowserId, "visible", "true"
   
   -- Set up a suitable initial url
   iphoneControlSet sBrowserId, "url", "http://www.google.com"
   
   -- Make sure everything is the right size
   resizeStack
end preOpenCard

on closeCard
   if the environment is not "mobile" then
      exit closeCard
   end if
   
   -- Destroy the control, if we fail to do this native UIViews
   -- will just accumulate
   iphoneControlDelete sBrowserId
end closeCard

on resizeStack
   if the environment is not "mobile" then
      exit resizeStack
   end if
   
   -- Adjust the size of the URL entry field
   set the rect of field "URL" to the left of field "URL", the top of field "URL", the width of this card - 4, the bottom of field "URL"
   
   -- Adjust the size of the browser view
   set the rect of group "Browser" to the left of group "Browser", the top of group "Browser", the width of this card - 4, the height of this card - 40
   
   -- Adjust the status field
   set the rect of field "Status" to 4, the bottom of group "Browser" + 4, the width of this card - 4, the height of this card - 4
   
   -- Now adjust the control itself
   iphoneControlSet sBrowserId, "rect", the rect of group "Browser"
end resizeStack

--------

-- This message is received after a request has been allowed and
-- loading is starting
on browserStartedLoading pUrl
   put "Started loading:" && pUrl into field "Status"
end browserStartedLoading

-- This message is received when a page has been completely
-- loaded and is displayed to the user
on browserFinishedLoading pUrl
   put "Finished loading:" && pUrl into field "Status"
   put pUrl into field "Url"
end browserFinishedLoading

-- This message is received when a new url is requested. Passing it
-- causes the load to go ahead, otherwise it does not.
on browserLoadRequest pUrl, pReason
   answer "Do you want to load:" && pUrl with "Yes" and "No"
   if it is "Yes" then
      pass browserLoadRequest
   else
      put "Refused:" && pUrl into field "Status"
   end if
end browserLoadRequest

--------

-- This handler is invoked by our Back/Forward/Stop/Refresh buttons
-- we just pass the request onto the control.
command doAction pAction
   if the environment is not "mobile" then
      exit doAction
   end if
   
   iphoneControlDo sBrowserId, pAction
end doAction

-- This handler is invoked when the url field is closed after editing.
-- It causes a new url to be requested
command goUrl pUrl
   if the environment is not "mobile" then
      exit goUrl
   end if
   
   iphoneControlSet sBrowserId, "url", pUrl
end goUrl
