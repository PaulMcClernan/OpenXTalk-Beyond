script "stack_revStandaloneProgress_group_id_1005"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > substack "revStandaloneProgress" > card (id 1002) > group "Loader" (id 1005)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local sLoading, sColormapModified
on startLoading
  if sColormapModified is not true then
    calculateColormap
  end if
  put true into sLoading
  doLoading
end startLoading


on doLoading
  if sLoading then
    local tPreviousColor, tCurrentColor
    put the textColor of graphic "line,0" of me into tPreviousColor
    repeat with x = 1 to the cNumber of me
      get "line",(x mod the cNumber of me)
      put the textColor of graphic it of me into tCurrentColor
      set the textColor of graphic it of me to tPreviousColor
      put tCurrentColor into tPreviousColor
    end repeat
    send "doLoading" to me in (the cDelay of me) milliseconds
  end if
end doLoading
 
on stopLoading
  put false into sLoading
end stopLoading

# The following code crashes the engine.
# I will leave this in for now so that we can debug and fix.
--on calculateColormap
--  lock screen
--  lock cursor
--  local tMinGray, tOldTool, tOldPencolor
--  put the tool into tOldTool
--  put the penColor into tOldPencolor
--  choose dropper tool
--  click at the loc of me
--  put trunc(average(the penColor)) into tMinGray
--  do "choose" && tOldTool
--  set the penColor to tOldPencolor
--  subtract 10 from tMinGray
--  local tModifiedColormap
--  repeat for each line tColor in the cColorMap of me
--    if tColor is empty then next repeat
--    if item 1 of tColor is item 2 of tColor and item 2 of tColor is item 3 of tColor and item 1 of tColor > tMinGray then
--      put tMinGray,tMinGray,tMinGray & return after tModifiedColorMap
--    else
--      put tColor & return after tModifiedColormap
--    end if
--  end repeat
--  delete the last char of tModifiedColormap
--  set the cColormap of me to tModifiedColormap
--  unlock cursor
--  unlock screen
--  put true into sColormapModified
--end calculateColormap

-- Fixes different gray backgrounds, making sure differences are visible..
on calculateColormap
  local tCount
  if the platform is "macos" then -- we can just set the default
    put 1 into tCount
    repeat for each line tColor in the cColormap of me
      set the textColor of graphic tCount of me to tColor
      add 1 to tCount
    end repeat
  else
    local tSample, tBottom, tImage, tGray
    put the bottom of me into tBottom
    put tBottom, tBottom, tBottom + 1, tBottom + 1 into tSample
    import snapshot from rect tSample of this card
    -- We assume the card is gray, thus only need one channel:
    put charToNum(char 2 of the imageData of the last image) into tGray
    subtract 30 from tGray
    --local tModifiedColormap
    put 1 into tCount
    repeat for each line tColor in the cColorMap of me
      if tColor is empty then next repeat
      if item 1 of tColor is item 2 of tColor and item 2 of tColor is item 3 of tColor and item 1 of tColor > tGray then
        set the textColor of graphic tCount of me to tGray,tGray,tGray
      else
        set the textColor of graphic tCount of me to tColor
      end if
      add 1 to tCount
    end repeat
    delete the last image
  end if
  put true into sColormapModified
end calculateColormap
