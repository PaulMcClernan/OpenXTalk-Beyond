script "stack_mobileTemplate_card_id_1868"
-- Stack file: ide/Resources/Start Center/samples/sample_3/mobileTemplate.livecode
-- Object: stack "mobileTemplate" > card "template" (id 1868)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on openCard
   lock screen
   set the theme of this stack to "green"
   set the headerTitle of this stack to "Mobile Template"
   set the headerButtonBackVisible of this stack to false
   set the headerButtonAddVisible of this stack to false
   set the headerButtonUploadVisible of this stack to false
   set the headerButtonDeleteVisible of this stack to false
   set the navigationSelectedItem of this stack to the cNavID of me
   
   setupCustomiseInterface
   unlock screen
end openCard

on setupCustomiseInterface
   lock screen
   // Setup the theme chooser
   local tCurrentTheme
   put the theme of this stack into tCurrentTheme
   put toUpper(char 1 of tCurrentTheme) into char 1 of tCurrentTheme
   set the label of button "theme" of me to tCurrentTheme
   
   // Setup the list of nav items
   put the navigationItems of group "nav" of me into field "navItems" of me
   
   // Setup the header button visibility check boxes
   set the hilited of button "back" of me to the headerButtonBackVisible of this stack
   set the hilited of button "add" of me to the headerButtonAddVisible of this stack
   set the hilited of button "delete" of me to the headerButtonDeleteVisible of this stack
   unlock screen
end setupCustomiseInterface
