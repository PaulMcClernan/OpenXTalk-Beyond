script "org.openxtalk.plugin.xtalkassistant-window"
-- OXT-Beyond: the behavior of the xTalk Assistant's window (the stack
-- "revXTalkAssistant", which the plugin's main stack builds when the window
-- is first opened). It lays the controls out and hands every click to the
-- main stack, org.openxtalk.plugin.xtalkassistant, which does the work.
-- Here "me" is the window.
--
-- The window wears the xTalk Suite's look (its UI kit v2), which leaves
-- the layout to each window: a 16 pixel edge, rows of 24, gaps of 8. From
-- the top: the band with the title and the pill, the status line, the
-- row of settings, and the conversation on a panel; from the bottom: the
-- footer, the prompt and Send, the row of actions on the answer, and,
-- while the assistant asks the user something, the bar that asks it, on a
-- panel of its own that the conversation makes room for.

constant kMain = "org.openxtalk.plugin.xtalkassistant"
constant kEdge = 16
constant kGap = 8
constant kRowHeight = 24
constant kBand = 30
constant kPromptHeight = 72
constant kSendWidth = 80
constant kAskHeight = 172
constant kPillWidth = 92

on preOpenStack
   xtawLayout the width of me, the height of me
   pass preOpenStack
end preOpenStack

on resizeStack pNewWidth, pNewHeight
   xtawLayout pNewWidth, pNewHeight
   pass resizeStack
end resizeStack

-- The main stack has shown or hidden the bar that asks the user
on xtawRelayout
   xtawLayout the width of me, the height of me
end xtawRelayout

on closeStack
   dispatch "xtaWindowClosed" to stack kMain
   pass closeStack
end closeStack

private command xtawLayout pWidth, pHeight
   local tLeft, tRight, tTop, tBottom, tX, tPanelTop
   put kEdge into tLeft
   put pWidth - kEdge into tRight
   lock screen

   -- The band, the title on it and the pill at its right, then the status
   -- line under it
   set the rect of graphic "uiBand" of me to 0, 0, pWidth, kBand
   set the rect of field "uiTitle" of me to 0, the top of field "uiTitle" of me, pWidth - kEdge - kPillWidth - kGap, the bottom of field "uiTitle" of me
   set the rect of graphic "PillBg" of me to tRight - kPillWidth, 6, tRight, 24
   set the rect of field "Pill" of me to tRight - kPillWidth, the top of field "Pill" of me, tRight, the bottom of field "Pill" of me
   set the rect of field "Status" of me to tLeft, kBand + 4, tRight, kBand + 22

   -- The settings: provider, model, the model list, and the menu of the
   -- rest
   put kBand + 28 into tTop
   set the rect of button "Provider" of me to tLeft, tTop, tLeft + 150, tTop + kRowHeight
   set the rect of button "More" of me to tRight - 72, tTop, tRight, tTop + kRowHeight
   set the rect of button "Models" of me to tRight - 72 - kGap - 72, tTop, tRight - 72 - kGap, tTop + kRowHeight
   set the rect of button "Model" of me to tLeft + 150 + kGap, tTop, tRight - 2 * (72 + kGap), tTop + kRowHeight
   put tTop + kRowHeight + kGap into tPanelTop

   -- Bottom up: the footer, the prompt and Send, then the row of actions
   -- on the answer
   set the rect of field "uiFooter" of me to tLeft, pHeight - 26, tRight, pHeight - 8
   put pHeight - 34 into tBottom
   set the rect of field "Prompt" of me to tLeft, tBottom - kPromptHeight, tRight - kSendWidth - kGap, tBottom
   set the rect of button "Send" of me to tRight - kSendWidth, tBottom - kPromptHeight, tRight, tBottom - kPromptHeight + kRowHeight
   put tBottom - kPromptHeight - kGap into tBottom
   set the rect of button "Include" of me to tLeft, tBottom - kRowHeight, tLeft + 200, tBottom
   set the rect of button "New" of me to tRight - 90, tBottom - kRowHeight, tRight, tBottom
   put tRight - 90 - kGap into tX
   set the rect of button "Insert" of me to tX - 100, tBottom - kRowHeight, tX, tBottom
   put tBottom - kRowHeight - kGap into tBottom

   -- The bar that asks the user, while it is shown: what is asked, the
   -- details, and the answers, the one that says yes at the right
   if the visible of graphic "AskPanel" of me then
      set the rect of graphic "AskPanel" of me to tLeft, tBottom - kAskHeight, tRight, tBottom
      put tBottom - kAskHeight into tTop
      set the rect of field "AskTitle" of me to tLeft + 12, tTop + 10, tRight - 12, tTop + 44
      set the rect of field "AskDetail" of me to tLeft + 12, tTop + 48, tRight - 12, tBottom - 12 - kRowHeight - kGap
      put tRight - 12 into tX
      set the rect of button "AskYes" of me to tX - 90, tBottom - 12 - kRowHeight, tX, tBottom - 12
      put tX - 90 - kGap into tX
      if the visible of button "AskSession" of me then
         set the rect of button "AskSession" of me to tX - 160, tBottom - 12 - kRowHeight, tX, tBottom - 12
         put tX - 160 - kGap into tX
      end if
      set the rect of button "AskNo" of me to tX - 110, tBottom - 12 - kRowHeight, tX, tBottom - 12
      put tBottom - kAskHeight - kGap into tBottom
   end if

   -- The conversation takes the rest, on its panel
   set the rect of graphic "ConversationPanel" of me to tLeft, tPanelTop, tRight, tBottom
   set the rect of field "Conversation" of me to tLeft + 6, tPanelTop + 6, tRight - 6, tBottom - 6
   unlock screen
end xtawLayout

on mouseUp pButton
   if pButton is not 1 then
      pass mouseUp
   end if
   switch the short name of the target
      case "Send"
         -- Stop, while a question is being answered
         dispatch "xtaSendOrStop" to stack kMain
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
      -- The bar that asks the user
      case "AskYes"
         dispatch "xtaAnswerAsk" to stack kMain with "yes"
         break
      case "AskSession"
         dispatch "xtaAnswerAsk" to stack kMain with "session"
         break
      case "AskNo"
         dispatch "xtaAnswerAsk" to stack kMain with "no"
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

-- The conversation's links: Remember and Dismiss under a note an answer
-- proposes to remember, and Undo after what the assistant changed
on linkClicked pLink
   if the short name of the target is "Conversation" then
      dispatch "xtaConversationLink" to stack kMain with pLink
   else
      pass linkClicked
   end if
end linkClicked

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
