script "stack_Report_Builder_scrollbar_id_1031"
-- Stack file: ide/Plugins/Report Builder.livecode
-- Object: stack "Report Builder" > card (id 1002) > group "Preview Scale" (id 1030) > scrollbar "scalescroll" (id 1031)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --scale factor for report stack (tperry 11-12-23)
   if there is a stack "Report" then
      lock screen
      set the scalefactor of stack "Report" to the thumbPosition of me
      -- wd positioning fix
      tSortScaledPos
      unlock screen
      
   end if
end mouseUp

on tSortScaledPos
   -- there is probably some clever maths I should be doing to work this out,
   -- but instead, I'm doing this:
   put the right of stack "Report Builder" into tRLoc
   put the top of stack "Report Builder" into tTLoc
   put the thumbPosition of me into tScaleOffset
   if tScaleOffset is "1.2" then 
      subtract 52 from tRLoc
      subtract 2 from tTLoc
   end if
   if tScaleOffset is "1.1" then 
      subtract 23 from tRLoc
      add 12 to tTLoc
   end if
   if tScaleOffset is "1.0" then 
      add 11 to tRLoc
      add 28 to tTLoc
   end if
   if tScaleOffset is "0.9" then 
      add 52 to tRLoc
      add 47 to tTLoc
   end  if
   if tScaleOffset is "0.8" then 
      add 104 to tRLoc
      add 71 to tTLoc
   end if
   if tScaleOffset is "0.7" then 
      add 171 to tRLoc
      add 103 to tTLoc
   end if
   if tScaleOffset is "0.6" then 
      add 261 to tRLoc
      add 144 to tTLoc
   end if
   set the top of stack "Report" to tTLoc
   set the left of stack "Report" to tRLoc
end tSortScaledPos
