script "stack_revOnline_button_id_163649"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "templates" (id 157677) > button "Set Rating" (id 163649)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   local tRating
   put the text of field "Rating test" of card "templates" of this stack into tRating
   send "setRating tRating" to group "Rater Template"
   
   local tTrue
   put "true" into tTrue
   send "setCanRate tTrue" to group "Rater Template"
   
   local tId
   put "1" into tId
   send "setId tId" to group "Rater Template"
   
   local tCallback, tCallbackTarget
   put "rateCallback" into tCallback
   put the long id of me into tCallbackTarget
   send "setRateCallback tCallback, tCallbackTarget" to group "Rater Template"
end mouseUp

command rateCallback pId, pRating
   put "Rated: " & pId && pRating
end rateCallback
