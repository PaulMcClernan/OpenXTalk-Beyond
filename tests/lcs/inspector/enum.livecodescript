script "TestInspectorEnum"
-- OXT-Beyond: tests of the Property Inspector's menu of a property's
-- values, the editor com.livecode.pi.enum
-- (ide/Toolset/palettes/inspector/editors/com.livecode.pi.enum.behavior.livecodescript,
-- on the editors' own behavior, revinspectoreditorbehavior.livecodescript),
-- made as the Inspector makes one: a group whose option menu "pulldown"
-- calls valueChanged on menuPick, with the property's info. An option can
-- be "Label|value", and the value can be empty: iconGravity's empty value
-- read as a blank line in its menu (tperry2x, openxtalk.org p=25419), and
-- its list in propertyInfo.tsv gives it the label Default. The menu shows
-- the labels (with the Inspector's language names the values, but the
-- label of an empty value), the label of the value the property has, and a
-- pick sets the value of the option picked. An option with no "|" (the
-- Scrollbar width's 12 and Standard, the empty line iconGravity's list had)
-- is shown and set as it is, as before, and so is every option of a list a
-- script makes ("execute:", the main stacks), whose "|" can be in a
-- stack's name. Where the objects inspected have different values, a new
-- editor shows nothing, as before, not Default.

constant kEnumBehavior = "com.livecode.pi.enum.behavior"
constant kStack = "TestInspectorEnumStack"

-- The language names (gRevLanguageNames) as the test found them, and the
-- behaviors' stacks it found in memory, which it leaves there
local sLanguageNames, sFound

on TestSetup
   global gRevLanguageNames
   put gRevLanguageNames into sLanguageNames
   put false into gRevLanguageNames
   put there is a stack "revInspectorEditorBehavior" into sFound["revInspectorEditorBehavior"]
   put there is a stack kEnumBehavior into sFound[kEnumBehavior]
   -- The editors' behavior, which the enum behavior's stack names, then
   -- the enum behavior
   get the long id of stack (TestGetIDERepositoryPath() & "/Toolset/palettes/inspector/behaviors/revinspectoreditorbehavior.livecodescript")
   get the long id of stack (TestGetIDERepositoryPath() & "/Toolset/palettes/inspector/editors/com.livecode.pi.enum.behavior.livecodescript")
   -- What an editor tells the Inspector (editorValueChanged): the property
   -- and its value, a line each, in the stack's cChanged
   create stack kStack
   set the script of stack kStack to "on editorValueChanged pProperty, pValue" & return & \
         "set the cChanged of me to the cChanged of me & pProperty & " & quote & "=" & quote & " & pValue & return" & return & \
         "end editorValueChanged"
end TestSetup

on TestTeardown
   global gRevLanguageNames
   put sLanguageNames into gRevLanguageNames
   if there is a stack kStack then delete stack kStack
   if there is a stack kEnumBehavior and sFound[kEnumBehavior] is not true then
      delete stack kEnumBehavior
   end if
   if there is a stack "revInspectorEditorBehavior" and sFound["revInspectorEditorBehavior"] is not true then
      delete stack "revInspectorEditorBehavior"
   end if
end TestTeardown

--------------------------------------------------------------------------------
-- Helpers

-- An editor of the property pProperty whose options are pOptions (a line
-- each, as the Inspector has them from the commas of a .tsv row), made
-- and initialized as the Inspector makes one: its long id
private function makeEditor pProperty, pOptions
   local tInfo, tEditor, tMenu
   set the defaultStack to kStack
   create group pProperty
   put the long id of it into tEditor
   create button "pulldown" in group pProperty of card 1 of stack kStack
   put the long id of it into tMenu
   set the style of tMenu to "menu"
   set the menuMode of tMenu to "option"
   set the script of tMenu to "on menuPick pItemName" & return & "valueChanged" & return & "end menuPick"
   set the behavior of tEditor to the long id of stack kEnumBehavior
   put pProperty into tInfo["property_name"]
   put pOptions into tInfo["options"]
   put false into tInfo["read_only"]
   set the editorPropertyInfo of tEditor to tInfo
   dispatch "editorInitialize" to tEditor
   return tEditor
end makeEditor

-- What the editor pEditor shows for the value pValue, as the Inspector
-- shows a property's value: its menu's label
private function shown pEditor, pValue
   set the editorValue of pEditor to pValue
   dispatch "editorUpdate" to pEditor
   return the label of button "pulldown" of pEditor
end shown

-- Picks the line pLine of the menu of the editor pEditor as a click on it
-- does (MCButton::mup: the menu's label becomes the line, then the menu
-- gets menuPick), and returns what the editor then told the Inspector
private function picked pEditor, pLine
   local tMenu, tItem
   put the long id of button "pulldown" of pEditor into tMenu
   put line pLine of the text of tMenu into tItem
   set the cChanged of stack kStack to empty
   set the label of tMenu to tItem
   dispatch "menuPick" to tMenu with tItem
   return the cChanged of stack kStack
end picked

-- The lines of pText on one line, for a diagnostic
private function joined pText
   replace return with "\n" in pText
   return "[" & pText & "]"
end joined

--------------------------------------------------------------------------------
-- Tests

-- iconGravity's options, as propertyInfo.tsv has them: the empty value
-- has the label Default
on TestEnumEmptyValueLabel
   local tEditor
   put makeEditor("iconGravity", "Default|" & return & "left" & return & "top" & return & "topLeft") into tEditor
   TestDiagnostic "menu" && joined(the text of button "pulldown" of tEditor)
   TestAssert "the menu has Default for the empty value", \
         the text of button "pulldown" of tEditor is ("Default" & return & "left" & return & "top" & return & "topLeft")
   TestAssert "the empty value shows Default", shown(tEditor, empty) is "Default"
   TestAssert "a value shows itself", shown(tEditor, "topLeft") is "topLeft"
   TestAssert "a pick of left sets left", picked(tEditor, 2) is ("iconGravity=left" & return)
   TestAssert "left shows left", shown(tEditor, "left") is "left"
   TestAssert "a pick of Default sets the value empty", picked(tEditor, 1) is ("iconGravity=" & return)
end TestEnumEmptyValueLabel

-- theme's options, "Native|native": the menu shows the labels, the value
-- shows its label, and a pick sets the value
on TestEnumLabels
   local tEditor
   put makeEditor("theme", "Native|native" & return & "Legacy Look-and-Feel|legacy") into tEditor
   TestDiagnostic "menu" && joined(the text of button "pulldown" of tEditor)
   TestAssert "the menu has the labels", \
         the text of button "pulldown" of tEditor is ("Native" & return & "Legacy Look-and-Feel")
   TestAssert "legacy shows its label", shown(tEditor, "legacy") is "Legacy Look-and-Feel"
   TestAssert "a pick of Native sets native", picked(tEditor, 1) is ("theme=native" & return)
   TestAssert "native shows its label", shown(tEditor, "native") is "Native"
   TestAssert "a pick of Legacy Look-and-Feel sets legacy", picked(tEditor, 2) is ("theme=legacy" & return)
end TestEnumLabels

-- With the Inspector's language names, the menu shows the values, but an
-- empty value its label
on TestEnumLanguageNames
   global gRevLanguageNames
   local tEditor
   put true into gRevLanguageNames
   put makeEditor("theme", "Native|native" & return & "Legacy Look-and-Feel|legacy") into tEditor
   TestDiagnostic "menu" && joined(the text of button "pulldown" of tEditor)
   TestAssert "the menu has the values", the text of button "pulldown" of tEditor is ("native" & return & "legacy")
   TestAssert "legacy shows legacy", shown(tEditor, "legacy") is "legacy"
   TestAssert "a pick of native sets native", picked(tEditor, 1) is ("theme=native" & return)
   put makeEditor("iconGravity", "Default|" & return & "left") into tEditor
   TestDiagnostic "menu" && joined(the text of button "pulldown" of tEditor)
   TestAssert "the menu has Default for the empty value", the text of button "pulldown" of tEditor is ("Default" & return & "left")
   TestAssert "the empty value shows Default", shown(tEditor, empty) is "Default"
   TestAssert "a value shows itself", shown(tEditor, "left") is "left"
   TestAssert "a pick of Default sets the value empty", picked(tEditor, 1) is ("iconGravity=" & return)
end TestEnumLanguageNames

-- With the language names never set (gRevLanguageNames empty, as the
-- preference is until it is changed), the menu shows the labels, as with
-- them off
on TestEnumLanguageNamesUnset
   global gRevLanguageNames
   local tEditor
   put empty into gRevLanguageNames
   put makeEditor("iconGravity", "Default|" & return & "left") into tEditor
   TestDiagnostic "menu" && joined(the text of button "pulldown" of tEditor)
   TestAssert "the menu has Default for the empty value", the text of button "pulldown" of tEditor is ("Default" & return & "left")
   TestAssert "the empty value shows Default", shown(tEditor, empty) is "Default"
   TestAssert "left shows left", shown(tEditor, "left") is "left"
   TestAssert "a pick of Default sets the value empty", picked(tEditor, 1) is ("iconGravity=" & return)
   put makeEditor("theme", "Native|native" & return & "Legacy Look-and-Feel|legacy") into tEditor
   TestDiagnostic "menu" && joined(the text of button "pulldown" of tEditor)
   TestAssert "the menu has the labels", the text of button "pulldown" of tEditor is ("Native" & return & "Legacy Look-and-Feel")
   TestAssert "legacy shows its label", shown(tEditor, "legacy") is "Legacy Look-and-Feel"
end TestEnumLanguageNamesUnset

-- When the objects inspected have different values, the Inspector marks
-- the editor conflicted and leaves its value as it was, which is empty in
-- a new editor (revinspectorgroupbehavior.livecodescript's rowData): that
-- empty value shows nothing, as before, not Default, which none of the
-- objects may have; a value the editor had shows as it did
on TestEnumConflicted
   local tEditor
   put makeEditor("iconGravity", "Default|" & return & "left" & return & "top") into tEditor
   set the editorConflicted of tEditor to true
   TestAssert "with values that differ, an empty value shows nothing", shown(tEditor, empty) is empty
   TestAssert "with values that differ, a value the editor had shows itself", shown(tEditor, "left") is "left"
   set the editorConflicted of tEditor to false
   TestAssert "with values that agree, the empty value shows Default", shown(tEditor, empty) is "Default"
end TestEnumConflicted

-- Options with no "|" are the menu, shown and set as they are, as before:
-- the Scrollbar width's, and iconGravity's as they were, with an empty
-- line for the empty value
on TestEnumPlainOptions
   local tEditor
   put makeEditor("scrollbarWidth", "12" & return & "Standard") into tEditor
   TestAssert "the menu has the options", the text of button "pulldown" of tEditor is ("12" & return & "Standard")
   TestAssert "a value with no option shows itself", shown(tEditor, 16) is "16"
   TestAssert "a pick of Standard sets Standard", picked(tEditor, 2) is ("scrollbarWidth=Standard" & return)
   TestAssert "the value 12 shows 12", shown(tEditor, 12) is "12"
   put makeEditor("iconGravity", empty & return & "left" & return & "top") into tEditor
   TestDiagnostic "menu" && joined(the text of button "pulldown" of tEditor)
   TestAssert "the menu has the empty line", the text of button "pulldown" of tEditor is (empty & return & "left" & return & "top")
   TestAssert "the empty value shows the empty line", shown(tEditor, empty) is empty
   TestAssert "top shows top", shown(tEditor, "top") is "top"
   TestAssert "a pick of the empty line sets the value empty", picked(tEditor, 1) is ("iconGravity=" & return)
end TestEnumPlainOptions

-- A list a script makes ("execute:", as the main stacks' is) is the menu,
-- shown and set as it is: a "|" in it is a stack's name's
on TestEnumComputedOptions
   local tEditor
   put makeEditor("mainStack", "execute:put" && quote & "My|Stack" & quote && "& return &" && quote & "Other" & quote && "into it") into tEditor
   TestDiagnostic "menu" && joined(the text of button "pulldown" of tEditor)
   TestAssert "the menu has the names", the text of button "pulldown" of tEditor is ("My|Stack" & return & "Other")
   TestAssert "a name with a | shows itself", shown(tEditor, "My|Stack") is "My|Stack"
   TestAssert "Other shows Other", shown(tEditor, "Other") is "Other"
   TestAssert "a pick of the name with a | sets it", picked(tEditor, 1) is ("mainStack=My|Stack" & return)
end TestEnumComputedOptions
