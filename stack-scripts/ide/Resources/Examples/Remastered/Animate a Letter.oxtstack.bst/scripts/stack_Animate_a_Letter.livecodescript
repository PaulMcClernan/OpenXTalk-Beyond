script "stack_Animate_a_Letter"
-- Stack file: ide/Resources/Examples/Remastered/Animate a Letter.oxtstack
-- Object: stack "Animate a Letter"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--Animate a Letter: Terry Little's Animate Letter v1.2, remastered for OXT-Beyond in 2026
--Animate Letter v1.2, Terry Little (c)7/2022, All Rights Reserved
--This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
--as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
--You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

--Each card's program is in the scripts of its letters (and, for the arrow keys, of its card):
--click a letter, and the panel beside the stage shows its script. The sidebar, the header and
--that panel are the groups "Frame" and "Workbench", which the script of the group "Frame" runs.

on newCard  --block new cards
   delete this card
   answer "Sorry, new cards are not allowed." with "OK" titled "Animate a Letter"
end newCard
