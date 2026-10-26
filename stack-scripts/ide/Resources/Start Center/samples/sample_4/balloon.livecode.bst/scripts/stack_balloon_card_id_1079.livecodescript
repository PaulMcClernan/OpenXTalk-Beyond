script "stack_balloon_card_id_1079"
-- Stack file: ide/Resources/Start Center/samples/sample_4/balloon.livecode
-- Object: stack "balloon" > card "page4" (id 1079)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenCard
   global gName
   put "Congratulations" && gName & ". You have reached the end of your balloon adventure." into field "story"
end preOpenCard
