script "revHyperCardLibrary"
-- OXT-Beyond: the end of an imported HyperCard stack's message path.
--
-- revHyperCardFixScripts (revhypercardscriptlibrary.livecodescript) puts
-- this script in the substack "HyperCard Library" of a stack imported
-- with File > Import Stack and makes that substack the stack's behavior,
-- so that it comes after the stack's own script, where HyperCard's Home
-- stack and HyperCard itself were. The scripts it rewrites call these
-- handlers for the parts of HyperCard this engine does not have. A
-- stack's own handler of the same name comes first, as in HyperCard.
--
-- What each does here, rather than in HyperCard, is said beside it.

-- A menu choice: HyperCard sent doMenu for each one, and a stack's
-- "on doMenu" handler is called hcDoMenu after the import (no handler here
-- can be called doMenu). A choice that reaches here does what the
-- engine's doMenu command does with it.
on hcDoMenu pItem, pMenu
   doMenu pItem
   return the result
end hcDoMenu

-- HyperCard's version, which scripts compare with numbers ("the version
-- < 2"): that of HyperCard 2.4.1, the last
function hcVersion
   return "2.4.1"
end hcVersion

-- HyperCard's long version, as HyperCard 2.4.1 gave it
function hcLongVersion
   return "02418000"
end hcLongVersion

-- Whether HyperCard was in the background (MultiFinder): never here
function hcSuspended
   return false
end hcSuspended

-- reset menubar put HyperCard's own menus back; there are none here
on hcResetMenubar
end hcResetMenubar

-- go home: the Home stack, if one is open or can be found by name, as
-- HyperCard's was in every stack's path
on hcGoHome
   if there is a stack "Home" then
      go stack "Home"
      return the result
   end if
   return "Can't find the Home stack"
end hcGoHome

-- palette "Name", "h,v": open the palette (the importer makes each PLTE
-- resource a substack of that name) with its top left at h,v
on hcPalette pName, pLocation
   if there is not a stack pName then return "Can't find palette" && pName
   palette stack pName
   if pLocation is not empty then set the topLeft of stack pName to pLocation
   return empty
end hcPalette

-- open report printing: HyperCard's report templates are not imported
on hcOpenReportPrinting pWith
   return "Report printing is not supported"
end hcOpenReportPrinting

-- dial ... with modem: there is no modem to dial
on hcDial pNumber, pModemCommands
   return "dial with modem is not supported"
end hcDial

-- put ... into menu ... with menuMsg: HyperCard 2.2's menus, which this
-- engine's menus do not take yet
on hcPutIntoMenu pItems, pPreposition, pMenu, pMessages
   return "HyperCard menus are not supported yet"
end hcPutIntoMenu

-- create menu, delete menu: HyperCard 2.2's menus, as above
on hcCreateMenu pMenu
   return "HyperCard menus are not supported yet"
end hcCreateMenu

on hcDeleteMenu pMenu
   return "HyperCard menus are not supported yet"
end hcDeleteMenu
