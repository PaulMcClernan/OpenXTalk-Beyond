script "stack_revObjectProperties_button_id_1035"
-- Stack file: ide/Toolset/palettes/revsearch.rev
-- Object: stack "revSearch" > substack "revObjectProperties" > card (id 1002) > group "Object Properties to Search In:" (id 1029) > button "specific property selector" (id 1035)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseDown
  repeat for each line l in the cREVAudioClipPropertyNames of stack "revSearch"
    put tab & l & cr after tAudio    
  end repeat
  repeat for each line l in the cREVButtonPropertyNames of stack "revSearch"
    put tab & l & cr after tButton    
  end repeat
  repeat for each line l in the cREVCardPropertyNames of stack "revSearch"
    put tab & l & cr after tCard    
  end repeat
  repeat for each line l in the cREVFieldPropertyNames of stack "revSearch"
    put tab & l & cr after tField    
  end repeat
  repeat for each line l in the cREVGraphicPropertyNames of stack "revSearch"
    put tab & l & cr after tGraphic    
  end repeat
  repeat for each line l in the cREVGroupPropertyNames of stack "revSearch"
    put tab & l & cr after tGroup    
  end repeat
  repeat for each line l in the cREVImagePropertyNames of stack "revSearch"
    put tab & l & cr after tImage    
  end repeat
  repeat for each line l in the cREVPlayerPropertyNames of stack "revSearch"
    put tab & l & cr after tPlayer    
  end repeat
  repeat for each line l in the cREVScrollbarPropertyNames of stack "revSearch"
    put tab & l & cr after tScrollbar
  end repeat
  repeat for each line l in the cREVStackPropertyNames of stack "revSearch"
    put tab & l & cr after tStack    
  end repeat
  repeat for each line l in the cREVVideoClipPropertyNames of stack "revSearch"
    put tab & l & cr after tVideo
  end repeat
    
  set the text of me to "AudioClip Properties"&cr&tAudio&"Button Properties"&cr&tButton&"Card Properties"&cr&tCard&"Field Properties"&cr&tField&"Graphic Properties"&cr&tGraphic&"Group Properties"&cr&tGroup&"Image Properties"&cr&tImage&"Player Properties"&cr&tPlayer&"Scrollbar Properties"&cr&tScrollbar&"Stack Properties"&cr&tStack&"VideoClip Properties"&cr&tVideo
    
end mouseDown

on menuPick pWhich
  set the itemDel to "|"
  delete item 1 of pWhich
  set the label of me to pWhich  
end menuPick
