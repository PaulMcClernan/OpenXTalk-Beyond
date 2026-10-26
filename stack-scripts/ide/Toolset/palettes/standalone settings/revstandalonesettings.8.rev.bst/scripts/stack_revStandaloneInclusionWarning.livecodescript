script "stack_revStandaloneInclusionWarning"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > substack "revStandaloneInclusionWarning"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenStack
   set the loc of me to the screenLoc
   
   local tWarning, tInclusion
   put "The [[tInclusion]] inclusion has a built-in implementation" && \
         "for the platform you have selected. Retaining this inclusion may impair the" && \
         "functionality of your standalone application. Do you really want to include it?" \
         into tWarning
   
   put the cInclusion of me into tInclusion
   put merge(tWarning) into field "Warning" of me
   set the hilite of button "Check" of me to false
end preOpenStack

on optionSelected pInclude
   set the cInclude of me to pInclude
   set the cSilenceWarning of me to the hilite of button "Check" of me
   close this stack
end optionSelected

on mouseUp
   local tTarget
   put the short name of the target into tTarget
   if tTarget is "Remove" or tTarget is "Include" then
      optionSelected tTarget is "Include"
   end if
end mouseUp
