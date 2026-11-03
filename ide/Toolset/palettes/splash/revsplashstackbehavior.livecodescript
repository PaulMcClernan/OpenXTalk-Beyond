script "revSplashStackBehavior"
-- The loading bar fills by one step for each status the IDE shows: the
-- number of revInternal__setSplashStatus calls in ide/Toolset/home.livecodescript
-- (tools/ci/tests/test_branding.py counts them). A start that skips a few
-- ends a little short; the splash closes a moment later all the same.
constant kSplashSteps = 22
local sSplashSteps
on preOpenStack
   local tSplashPath
   
   lock messages
   if the systemappearance is "dark" then put revEnvironmentEditionProperty("skin") & "/splash.png" into tSplashPath
   if the systemappearance is "light" then put revEnvironmentEditionProperty("skin") & "/splash-light.png" into tSplashPath
   --
   if the systemappearance is "dark" then set the foregroundColor of this card to white
   if the systemappearance is "light" then set the foregroundColor of this card to black
   --
   set the textfont of stack "revSplash" to "(Default)"
   set the textfont of field "moreinfo" of stack "revSplash" to "(Default)"
   set the textfont of field "Status" of stack "revSplash" to "(Default)"
      set the textfont of field "Info" of stack "revSplash" to "(Text)"
   
   --
   set the filename of image "Splash" to tSplashPath
   set the id of image "Splash" to the id of stack "revIcons"
   set the location of me to the screenLoc
   set the htmlText of field "License" to revEnvironmentEditionProperty("splash_strap")
   -- OXT-Beyond, from 0.2.7-rc.6.14: the splash looks like the web IDE's
   -- loading screen (tools/web-ide/index.html). The art, drawn by
   -- Installer/oxt-beyond/branding/draw_branding.py, carries the logo,
   -- "OXT-Beyond", the release's name and the loading bar's track, all
   -- centred; under them go, centred too, "<version> · Happy hunting!"
   -- (field "moreinfo"), the bar's orange fill (graphic "progress", which
   -- the statusMessage setProp below moves on) and the loading status
   -- (field "Status"). The places are draw_branding.py's SPLASH_MOREINFO,
   -- SPLASH_TRACK and SPLASH_STATUS, and tools/ci/tests/test_branding.py
   -- holds this script to them. Field "Info", which the stack script fills
   -- with the product and version, and OpenXTalk Lite's line in "moreinfo"
   -- are not shown.
   local tVersion
   set the itemDelimiter to "/"
   put item 1 to -3 of the filename of stack "home" & "/.version" into tVersion
   set the itemDelimiter to comma
   if there is a file tVersion then
      put textDecode(url ("binfile:" & tVersion), "utf-8") into tVersion
      replace numToCodepoint(13) with empty in tVersion
      put word 1 to -1 of line 1 of tVersion into tVersion
   else
      put empty into tVersion
   end if
   if tVersion is not empty then put " " & numToCodepoint(0x00B7) & " " after tVersion
   hide field "Info" of me
   set the dontWrap of field "moreinfo" of me to true
   set the textAlign of field "moreinfo" of me to "center"
   set the textSize of field "moreinfo" of me to 13
   set the textStyle of field "moreinfo" of me to "plain"
   set the rect of field "moreinfo" of me to 0,199,591,225
   if the systemappearance is "dark" then
      set the foregroundColor of field "moreinfo" of me to 174,184,196
   else
      set the foregroundColor of field "moreinfo" of me to 91,102,114
   end if
   put tVersion & "Happy hunting!" into field "moreinfo" of me
   -- The field's text keeps the size and style it was saved with
   set the textSize of char 1 to -1 of field "moreinfo" of me to 13
   set the textStyle of char 1 to -1 of field "moreinfo" of me to "plain"
   set the foregroundColor of char 1 to -1 of field "moreinfo" of me to empty
   --
   set the dontWrap of field "Status" of me to true
   set the textAlign of field "Status" of me to "center"
   set the textSize of field "Status" of me to 11
   set the rect of field "Status" of me to 0,252,591,276
   if the systemappearance is "dark" then
      set the foregroundColor of field "Status" of me to 255,216,194
   else
      set the foregroundColor of field "Status" of me to 150,72,16
   end if
   put 0 into sSplashSteps
   splashProgressBar

   unlock messages
end preOpenStack

setProp statusMessage pMessage
   put pMessage into field "status" of me
   -- The bar is only decoration: nothing it does may stop the IDE starting
   try
      if there is a graphic "progress" of me then
         add 1 to sSplashSteps
         set the rect of graphic "progress" of me to \
               196, 242, 196 + max(3, round(199 * min(sSplashSteps, kSplashSteps) / kSplashSteps)), 245
         show graphic "progress" of me
      end if
   catch tError
   end try
end statusMessage

-- The loading bar's orange fill, over the track the art draws (196,242 to
-- 395,245, draw_branding.py's SPLASH_TRACK), made when the splash first
-- opens: the stack file is not changed, and is never saved
private command splashProgressBar
   local tDefault
   try
      if there is not a graphic "progress" of me then
         put the defaultStack into tDefault
         set the defaultStack to the short name of me
         create invisible graphic "progress"
         set the defaultStack to tDefault
      end if
      set the style of graphic "progress" of me to "roundrect"
      set the roundRadius of graphic "progress" of me to 3
      set the opaque of graphic "progress" of me to true
      set the lineSize of graphic "progress" of me to 0
      set the showBorder of graphic "progress" of me to false
      set the backgroundColor of graphic "progress" of me to 255,119,0
      set the rect of graphic "progress" of me to 196,242,199,245
      hide graphic "progress" of me
   catch tError
      if tDefault is not empty then set the defaultStack to tDefault
   end try
end splashProgressBar
