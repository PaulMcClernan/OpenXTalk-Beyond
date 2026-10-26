script "stack_revOnline_group_id_244327"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "ProgressBar" (id 244327)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local sMessage
local sWait

# pDivider parameters are the locations of other groups on the card used
# to align the fields in this group
command resize pDivider1, pDivider2
   set the rect of graphic "divider" of me to \
          (the left of me - 10, the top of me - 10, the right of me + 10, the top of me + 4)
   
   set the rect of field "version" of me to \
          (the left of me, the bottom of graphic "divider" of me, pDivider1, the bottom of me)
   --(the left of me, the bottom of graphic "divider" of me, the left of me + 200, the bottom of me)
   set the rect of field "total stacks" of me to \
          (pDivider1, the bottom of graphic "divider" of me, pDivider2, the bottom of me)
   
   --set the topleft of group "loading progress" of me to (pDivider2, the top of me + 6)
   --set the rect of field "feedback" of me to \
          --(the right of group "loading progress" of me, the top of me + 5, the right of me, the bottom of me)
   set the topright of group "loading progress" of me to (the right of me - 18, the top of me + 6)
   set the rect of field "feedback" of me to \
          (pDivider2, the top of me + 5, the left of group "loading progress" of me, the bottom of me)
end resize

command initialize
   set the cTooltip of me to empty
   put empty into field "Total Stacks" of me
   put "RevOnline |" into field "version" of me
   --rvoDrawProgressBar 0
   rvoHideProgressBar
end initialize

setProp cTooltip pMessage
   if sWait is not true then
      put pMessage into sMessage
      put pMessage into field "feedback" of me
   end if
end cTooltip

getProp cTooltip
   return sMessage
end cTooltip

# Used for locking the message displayed, necessary when a message
# needs to be displayed for a minimum time
setProp cWait pWait
   put pWait into sWait
   send "waitOverride" to me in 4 seconds
end cWait

getProp cWait
   return sWait
end cWait

command waitOverride
   put empty into sWait
   put empty into sMessage
   put empty into field "feedback" of me
end waitOverride

command clearTooltip pMessage
   if pMessage is the text of field "feedback" of me then
      put empty into field "feedback" of me
   end if
end clearTooltip

--command clearMe pMessage
--   if pMessage is the text of field "feedback" of me then
      
--   end if
--end clearMe

command updateNumberOfStacks pDisplayed, pMatches, pTotal 
   if pMatches is not empty then
      put "Displaying" && pDisplayed && "of" && pMatches && "results" into field "Total Stacks" of me
   else
      put "0 matches found" into field "Total Stacks" of me
   end if
   if pTotal is not empty then
      put "RevOnline |" && pTotal && "stacks online" into field "version" of me
   else
      put "RevOnline |" && "No conneciton" into field "version" of me
   end if
end updateNumberOfStacks

