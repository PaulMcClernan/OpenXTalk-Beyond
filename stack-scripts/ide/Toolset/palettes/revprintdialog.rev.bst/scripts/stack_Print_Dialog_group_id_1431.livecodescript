script "stack_Print_Dialog_group_id_1431"
-- Stack file: ide/Toolset/palettes/revprintdialog.rev
-- Object: stack "Print Dialog" > card (id 1002) > group "Print Target" (id 1442) > group "Printer List" (id 1431)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

# Main interface, refreshes and updates the list of printers according to pPrinterNames and pDefaultPrinter
command update pPrinterNames, pPrinterName
  
  local tScroll
  put the vScroll of me into tScroll
  
  lock screen
  
  cleanControls
  
  local tTop, tLeft
  put 0 into tTop
  put the left of me into tLeft
  
  local tSize
  repeat for each line tPrinterName in pPrinterNames
    put createPrinter(tLeft, tTop, tPrinterName) into tSize
    add item 1 of tSize to tLeft
    
    # Assuming that all printers are the same width.
    if tLeft + item 1 of tSize >= the right of me then
      add item 2 tSize to tTop
      put the left of me into tLeft
    end if
    
  end repeat
  
  set the cHilitedPrinter of me to the long id of group pPrinterName of me
  
  set the vScroll of me to tScroll
  
  unlock screen
end update

# Removes all "mutable" controls, i.e. those that were created by createPrinter.
private command cleanControls
  repeat with x = the number of groups of me down to 1
    if the cPrinter of group x of me is "true" then
      delete group x of me
    end if
  end repeat
end cleanControls

private function templatePrinter
  return the long id of group "Template Printer" this card
end templatePrinter

# Creates a mutable "printer" object with top pTop and left pLeft, with name pName. The printer is set as the default
# if pDefault is true. The function returns the size of the created printer (width,height).
private function createPrinter pLeft, pTop, pName
  local tPrinter
  
  copy templatePrinter() to me
  local tName
  put createPrinterName(pName) into tName
  set the name of it to tName
  put the long id of control tName of me into tPrinter
   
  set the topleft of tPrinter to pLeft, pTop
  set the cName of tPrinter to pName
  set the cPrinter of tPrinter to true
  set the cantDelete of tPrinter to false
  set the visible of tPrinter to true
  
  
  return the width of tPrinter & comma & the height of tPrinter
end createPrinter

private function createPrinterName pName
  return pName
end createPrinterName

command unhiliteAllPrinters
  repeat with x = 1 to the number of controls of me
    if the cPrinter of control x of me then
      set the cHilite of control x of me to false
    end if
  end repeat
end unhiliteAllPrinters

private function resolvePrinterFromControl pControl
  if the cPrinter of pControl then
    return the long id of pControl
  end if
  
  if the cPrinter of the owner of pControl then
    return the long id of the owner of pControl
  end if
  
  return empty
end resolvePrinterFromControl


on mouseUp
  local tPrinter
  put resolvePrinterFromControl(the long id of the target) into tPrinter
  
  # When selecting a different printer will clear all errors
  errorClearDo
  
  if tPrinter is not empty then
    set the cHilitedPrinter of me to tPrinter
  end if
  
  set the printerName to the cActualValue of tPrinter
  updateControls
end mouseUp


local sHilitedPrinter

setProp cHilitedPrinter pPrinter
  unhiliteAllPrinters
  if pPrinter is not empty then
    set the cHilite of pPrinter to true
    put pPrinter into sHilitedPrinter
  else
    put empty into sHilitedPrinter
  end if
end cHilitedPrinter

getProp cHilitedPrinter
  return sHilitedPrinter
end cHilitedPrinter

# Used by the card to get the currently selected printer
getProp cHilitedPrinterName
  if there is no sHilitedPrinter then
    return empty
  end if
  
  return the cName of sHilitedPrinter
end cHilitedPrinterName


















