script "stack_revGettingStartedScripts_button_id_1236"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Sorting a list Example" (id 1235) > button "Sort Titles" (id 1236)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseDown
  sort lines of field "Example Titles" by withoutLeadingArticle(each)
end mouseDown

function withoutLeadingArticle theTitle
  get word 1 of theTitle
  if it is "The" or it is "An" or it is "A" then
    -- we don't want to use it for the sort:
    delete word 1 of theTitle
  end if
  return theTitle
end withoutLeadingArticle
