script "org.openxtalk.plugin.xtalkassistant-window"
-- OXT-Beyond: the behavior of the xTalk Assistant's window (the stack
-- "revXTalkAssistant", which the plugin's main stack builds when the window
-- is first opened). It lays the controls out and hands every click to the
-- main stack, org.openxtalk.plugin.xtalkassistant, which does the work.
-- Here "me" is the window.

constant kMain = "org.openxtalk.plugin.xtalkassistant"
constant kMargin = 8
constant kRowHeight = 23
constant kPromptHeight = 72
constant kSendWidth = 72
constant kStatusHeight = 18

on preOpenStack
   xtawLayout the width of me, the height of me
   pass preOpenStack
end preOpenStack

on resizeStack pNewWidth, pNewHeight
   xtawLayout pNewWidth, pNewHeight
   pass resizeStack
end resizeStack

on closeStack
   dispatch "xtaWindowClosed" to stack kMain
   pass closeStack
end closeStack

private command xtawLayout pWidth, pHeight
   local tLeft, tRight, tTop, tBottom, tX
   put kMargin into tLeft
   put pWidth - kMargin into tRight
   lock screen

   -- Top row: provider, model, the model list, and the menu of the rest
   put kMargin into tTop
   set the rect of button "Provider" of me to tLeft, tTop, tLeft + 150, tTop + kRowHeight
   set the rect of button "More" of me to tRight - 70, tTop, tRight, tTop + kRowHeight
   set the rect of button "Models" of me to tRight - 70 - kMargin - 70, tTop, tRight - 70 - kMargin, tTop + kRowHeight
   set the rect of button "Model" of me to tLeft + 150 + kMargin, tTop, tRight - 2 * (70 + kMargin), tTop + kRowHeight

   -- Bottom up: the status line, the prompt and Send, then the row of
   -- actions on the answer
   put pHeight - kMargin into tBottom
   set the rect of field "Status" of me to tLeft, tBottom - kStatusHeight, tRight, tBottom
   put tBottom - kStatusHeight - kMargin into tBottom
   set the rect of field "Prompt" of me to tLeft, tBottom - kPromptHeight, tRight - kSendWidth - kMargin, tBottom
   set the rect of button "Send" of me to tRight - kSendWidth, tBottom - kPromptHeight, tRight, tBottom - kPromptHeight + 2 * kRowHeight
   put tBottom - kPromptHeight - kMargin into tBottom
   set the rect of button "Include" of me to tLeft, tBottom - kRowHeight, tLeft + 200, tBottom
   set the rect of button "New" of me to tRight - 100, tBottom - kRowHeight, tRight, tBottom
   put tRight - 100 - kMargin into tX
   set the rect of button "Insert" of me to tX - 100, tBottom - kRowHeight, tX, tBottom

   set the rect of field "Conversation" of me to tLeft, kMargin + kRowHeight + kMargin, tRight, tBottom - kRowHeight - kMargin
   unlock screen
end xtawLayout

on mouseUp pButton
   if pButton is not 1 then
      pass mouseUp
   end if
   switch the short name of the target
      case "Send"
         dispatch "xtaSendPrompt" to stack kMain
         break
      case "Insert"
         dispatch "xtaInsertCode" to stack kMain
         break
      case "New"
         dispatch "xtaNewConversation" to stack kMain
         break
      case "Models"
         dispatch "xtaChooseModels" to stack kMain
         break
      case "Include"
         dispatch "xtaSetIncludeScript" to stack kMain with the hilite of the target
         break
      default
         pass mouseUp
   end switch
end mouseUp

on menuPick pItem
   switch the short name of the target
      case "Provider"
         dispatch "xtaSetProviderByName" to stack kMain with pItem
         break
      case "Model"
         dispatch "xtaSetModel" to stack kMain with pItem
         break
      case "More"
         dispatch "xtaMoreMenuPick" to stack kMain with pItem
         break
      default
         pass menuPick
   end switch
end menuPick

-- A model name typed into the combo box
on closeField
   if the short name of the target is "Model" then
      dispatch "xtaSetModel" to stack kMain with the label of the target
   end if
   pass closeField
end closeField

-- Return starts a new line in the prompt; Command-Return (Control-Return on
-- Windows and Linux) or Enter sends it.
on returnInField
   if the short name of the target is "Prompt" and the commandKey is down then
      dispatch "xtaSendPrompt" to stack kMain
   else
      pass returnInField
   end if
end returnInField

on enterInField
   if the short name of the target is "Prompt" then
      dispatch "xtaSendPrompt" to stack kMain
   else
      pass enterInField
   end if
end enterInField
