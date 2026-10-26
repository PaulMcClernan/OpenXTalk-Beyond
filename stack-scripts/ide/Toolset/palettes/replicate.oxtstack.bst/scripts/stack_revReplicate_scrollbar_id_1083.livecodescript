script "stack_revReplicate_scrollbar_id_1083"
-- Stack file: ide/Toolset/palettes/replicate.oxtstack
-- Object: stack "revReplicate" > card (id 1002) > scrollbar "New Scrollbar 1" (id 1083)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on scrollBarDrag x
  if fld (the cTargetField of me) is not an integer then pass scrollBarDrag
  put the endValue of me - x into fld (the cTargetField of me)
end scrollBarDrag
