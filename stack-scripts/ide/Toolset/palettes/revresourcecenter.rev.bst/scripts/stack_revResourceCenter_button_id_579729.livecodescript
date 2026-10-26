script "stack_revResourceCenter_button_id_579729"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "SortingAList" (id 113772) > group "mainContent" (id 113786) > group (id 584247) > group "Example" (id 577015) > button "Sort Titles" (id 579729)
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
