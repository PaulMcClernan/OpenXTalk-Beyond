script "stack_mobileTemplate"
-- Stack file: ide/Resources/Start Center/samples/sample_3/mobileTemplate.livecode
-- Object: stack "mobileTemplate"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

###################################################################
# This is a customisable template stack.
# All the core code for the template is contained in the stack script, the header group 
# and the navigation group.
#
# Using this template 
# Stack nagivation is controlled using the nav bar. By default it contains a settings card
# which car be removed once you've familiarised yourself with the template.
#
# Use the '+' button to add extra navigation elements. The '+' button is only visible when
# your stack is running in the IDE.
#
# Once you have created a new navigation element, clicking on it will create a new card and
# set a basic script on it:
#
# on preOpenCard
#    set the theme of this stack to "green"
#    set the headerTitle of this stack to "My Title"
#    set the headerButtonBackVisible of this stack to false
#    set the headerButtonAddVisible of this stack to false
#    set the headerButtonUploadVisible of this stack to false
#    set the headerButtonDeleteVisible of this stack to false
# end preOpenCard
#
# This template 'preOpenCard' hander contains all the items that can bus customised
# You can set the following items for a given card:
# theme: Set which color theme you'd like to use (red|orange|yellow|gree|blue|purple|brown)
# headerTitle: The text is the header
# headerButtonBackVisible: whether to show the back button or not
# headerButtonAddVisible: whether to show the add button or not
# headerButtonDeleteVisible: whether to show the delete button or not
# headerButtonUploadVisible: whether to show the upload button or not
#
###################################################################
on preOpenStack
   local tNavItems
   
   if the navigationItems of group "nav" of me is empty then
      put "template,settings" into line 1 of tNavItems
      set the navigationItems of group "nav" of me to tNavItems
   else
      set the navigationItems of group "nav" of me to the navigationItems of group "nav" of me
   end if
end preOpenStack


####################################################
# RESIVING CODE 
####################################################
on resizeStack
   lock screen
   
   // Resize and place the navigation
   set the width of group "nav" of me to the width of me
   set the left of group "nav" of me to 0
   set the bottom of group "nav" of me to the height of me
   
   // Resize and place  the header
   set the width of group "header" of me to the width of me
   set the left of group "header" of me to 0
   set the top of group "header" of me to 0
   
   unlock screen
end resizeStack

####################################################
# CONTENT 
####################################################
getProp contentRect
   return 0,the bottom of group "header" of me, the width of me, the top of group "nav" of me
end contentRect

getProp contentLeft
   return 0
end contentLeft

getProp contentRight
   return the width of me
end contentRight

getProp contentTop
   return the bottom of group "header" of me
end contentTop

getProp contentBottom
   return the top of group "nav" of me
end contentBottom

####################################################
# HEADER
####################################################
setProp headerButtonBackVisible pVisibility
   if pVisibility is false then
      set the headerButtonBackVisible of group "header" of me to false
   else
      set the headerButtonBackVisible of group "header" of me to true
   end if
end headerButtonBackVisible

getProp headerButtonBackVisible
      return the headerButtonBackVisible of group "header" of me
end headerButtonBackVisible

setProp headerButtonAddVisible pVisibility
   if pVisibility is false then
      set the headerButtonAddVisible of group "header" of me to false
   else
      set the headerButtonAddVisible of group "header" of me to true
   end if
end headerButtonAddVisible

getProp headerButtonAddVisible
      return the headerButtonAddVisible of group "header"
end headerButtonAddVisible

setProp headerButtonDeleteVisible pVisibility
   if pVisibility is false then
      set the headerButtonDeleteVisible of group "header" of me to false
   else
      set the headerButtonDeleteVisible of group "header" of me to true
   end if
end headerButtonDeleteVisible

getProp headerButtonDeleteVisible
      return the headerButtonDeleteVisible of group "header" of me
end headerButtonDeleteVisible

setProp headerButtonUploadVisible pVisibility
   if pVisibility is false then
      set the headerButtonUploadVisible of group "header" of me to false
   else
      set the headerButtonUploadVisible of group "header" of me to true
   end if
end headerButtonUploadVisible

getProp headerButtonUploadVisible
      return the headerButtonUploadVisible of group "header" of me
end headerButtonUploadVisible

setProp headerTitle pText
   set the headerTitle of group "header" of me to pText
end headerTitle

getProp headerTitle
   return the headerTitle of group "header" of me
end headerTitle

####################################################
# NAVIGATION
####################################################
setProp navigationSelectedItem pCardID
   set the navigationSelectedItem of group "nav" of me to pCardID
end navigationSelectedItem

getProp navigationSelectedItem
   return the navigationSelectedItem of group "nav" of me
end navigationSelectedItem

################################################
# THEME
################################################
setprop theme pTheme
   set the cTheme of me to pTheme
   switch tolower(pTheme)
      case "red"
         set the primaryColor of me to "220,46,46"
         set the secondaryColor of me to "251,249,244"
         set the textcolor of me to "0,0,0"
         break
      case "orange"
         set the primaryColor of me to "207,122,57"
         set the secondaryColor of me to "251,249,244"
         set the textcolor of me to "0,0,0"
         break
      case "yellow"
         set the primaryColor of me to "207,198,54"
         set the secondaryColor of me to "251,249,244"
         set the textcolor of me to "0,0,0"
         break
      case "green"
         set the primaryColor of me to "175,207,54"
         set the secondaryColor of me to "251,249,244"
         set the textcolor of me to "0,0,0"
         break
      case "blue"
         set the primaryColor of me to "46,169,220"
         set the secondaryColor of me to "251,249,244"
         set the textcolor of me to "0,0,0"
         break
      case "purple"
         set the primaryColor of me to "126,54,207"
         set the secondaryColor of me to "251,249,244"
         set the textcolor of me to "0,0,0"
         break
      case "brown"
         set the primaryColor of me to "119,108,96"
         set the secondaryColor of me to "251,249,244"
         set the textcolor of me to "0,0,0"
         break
   end switch
end theme

getProp theme
   if the cTheme of me is not empty then
      return the cTheme of me
   else
      return "Red"
   end if
end theme

setProp primaryColor pColor
   lock screen
   set the navigationHighlightColor of group "nav" of me to pColor
   set the headerBackgroundColor of group "header" of me to pColor
   unlock screen
end primaryColor

getProp primaryColor
   return the headerBackgroundColor of group "header" of me
end primaryColor

setProp secondaryColor pColor
   lock screen
   set the backgroundcolor of me to pColor
   unlock screen
end secondaryColor

getProp secondaryColor pColor
   return the backgroundcolor of me
end secondaryColor
   
