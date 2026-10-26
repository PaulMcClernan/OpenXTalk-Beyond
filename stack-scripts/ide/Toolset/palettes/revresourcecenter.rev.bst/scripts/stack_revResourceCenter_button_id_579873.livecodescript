script "stack_revResourceCenter_button_id_579873"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Checkwhetherthescreenresolutionishighenough" (id 80284) > group "mainContent" (id 80302) > group (id 579875) > group "Example" (id 577040) > button "Check Screen Size" (id 579873)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  checkForScreenSize
end mouseUp

on checkForScreenSize
  if item 3 of the screenRect < 1024 \
      or item 4 of the screenRect < 768 then
    answer error "MyApp requires a 1024x768 or larger monitor." \
        & return & return & "(This handler has been modified from the example, for" \
        & "obvious reasons. The application would quit here, if we hadn't commented out that part.)" \
        with "Sorry"
    -- quit -- commented this out in the example to avoid unpleasant surprises
  else
    -- this line is also added for the example
    answer "Screen size is OK!"
  end if
end checkForScreenSize
