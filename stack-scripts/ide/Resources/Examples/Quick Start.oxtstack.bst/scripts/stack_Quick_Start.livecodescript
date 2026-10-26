script "stack_Quick_Start"
-- Stack file: ide/Resources/Examples/Quick Start.oxtstack
-- Object: stack "Quick Start"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--Quick Start v1.5, Terry Little ©2024, All Rights Reserved
--This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License 
--as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
--This program is distributed in the hope that it will be useful, but without any warranty; without even the implied warranty of 
--merchantability or fitness for a particular purpose. See the GNU General Public License for more details. <http://www.gnu.org/licenses/>.

on preOpenCard
   put "("& the number of this cd &")"&& the short name of this cd into fld "Title"
   if there is a fld "Info" then set the vScroll of fld "Info" to "0"  --top
   if there is a btn "Narrator" then set the cLine of btn "Narrator" to "1"  --start over, custom prop
end preOpenCard
