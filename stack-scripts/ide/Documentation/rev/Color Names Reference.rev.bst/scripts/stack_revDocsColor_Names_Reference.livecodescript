script "stack_revDocsColor_Names_Reference"
-- Stack file: ide/Documentation/rev/Color Names Reference.rev
-- Object: stack "revDocsColor Names Reference"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.


function RGBToHTML r,g,b
  if the paramCount is 1 then
    get param(1)
    put item 1 of it into r
    put item 2 of it into g
    put item 3 of it into b
  end if
  put baseConvert(r,10,16) into myRed
  if the length of myRed is 1 then put zero before myRed
  put baseConvert(g,10,16) into myGreen
  if the length of myGreen is 1 then put zero before myGreen
  put baseConvert(b,10,16) into myBlue
  if the length of myBlue is 1 then put zero before myBlue
  return "#" & myRed & myGreen & myBlue
end RGBToHTML
       
function HTMLToRGB htmlNumber
  if char 1 of htmlNumber is "#" then delete char 1 of htmlNumber
  return baseconvert(char 1 to 2 of htmlNumber,16,10) & comma \
      & baseconvert(char 3 to 4 of htmlNumber,16,10) & comma \
      & baseconvert(char 5 to 6 of htmlNumber,16,10)
end HTMLToRGB

getProp htmlColor
  if numericColor is among the lines of the customKeys of the target
  then return RGBToHTML(the numericColor of the target)
end htmlColor

on preOpenStack
   set the _ideoverride of me to true
end preOpenStack
