script "stack_revDataViewControl_button_id_1008"
-- Stack file: ide/Toolset/palettes/revCore.8.livecode
-- Object: stack "revCore" > substack "revDataViewControl" > card (id 1002) > button "Test" (id 1008)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   put the long id of button "Template" into theTemplatesA["default"]
   put the long id of field "Template 2" into theTemplatesA["special"]
   set the viewProp["row style templates"] of group "DataView" to theTemplatesA
   
   repeat with i = 1 to 100
      put "Line" && i into theA["data"][i]["name"]
   end repeat
   
   set the uData of group "DataView" to theA
   dispatch "RenderView" to group "DataView"
end mouseUp
