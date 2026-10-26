script "stack_macOS_Tools_Tester_button_id_1960"
-- Stack file: ide/Extensions/org.openxtalk.library.macosnativeapptools/samples/MacOS-Native-Tools-Tester.oxtstack
-- Object: stack "macOS Tools Tester" > card (id 1002) > button "getNSWindowFrameRect( WinID )" (id 1960)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

-- Sent when the mouse is released after clicking
-- pMouseButton specifies which mouse button was pressed
on mouseUp pMouseButton
   answer "pick an IDE stack:" with "Menubar Toolbar" or "Tools Palette"
   if it contains "Toolbar" then
      put getNSWindowFrameRect( the windowID of stack "revMenubar") into tRect
      put "menubar NSWindow frame rect " && tRect
      put cr & "menubar xTalk stack left: " & the left of stack "revMenubar" & \
            ",screen height - bottom: " & the last item of screenRect() - the bottom of stack "revMenubar" & \
            ",width: " & the width of stack "revMenubar" & \
            ",height: " & the height of stack "revMenubar" \
            after msg
   else
      put getNSWindowFrameRect( the windowID of stack "revTools") into tRect
      put "tools palette NSWindow frame rect " && tRect
      put cr & "tools palette xTalk stack left: " & the left of stack "revTools" & \
            ",screen height - bottom: " & the last item of screenRect() - the bottom of stack "revTools" & \
            ",width: " & the width of stack "revTools" & \
            ",height: " & the height of stack "revTools" \
            after msg
   end if
   
end mouseUp
