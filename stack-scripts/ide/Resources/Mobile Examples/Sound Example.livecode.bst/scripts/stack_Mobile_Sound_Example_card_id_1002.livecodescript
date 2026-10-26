script "stack_Mobile_Sound_Example_card_id_1002"
-- Stack file: ide/Resources/Mobile Examples/Sound Example.livecode
-- Object: stack "Mobile Sound Example" > card (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

-- Play the given sound on our 'background' channel
on setBackgroundSound pSound
   iphonePlaySoundOnChannel getSound(pSound), "Background", "looping"
end setBackgroundSound

-- Play the given sound on our 'transient' channel
on playTransientSound pSound
   iphonePlaySoundOnChannel getSound(pSound), "Transient", "now"
end playTransientSound

-- Pause the queued sound channel
on pauseQueuedSounds
   iphonePausePlayingOnChannel "Queue"
end pauseQueuedSounds

-- Resume the queued sound channel
on resumeQueuedSounds
   iphoneResumePlayingOnChannel "Queue"
end resumeQueuedSounds

-- Clear the currently queued sounds, and stop the channel playing
on clearQueuedSounds
   put empty into field "Queue"
   iphoneStopPlayingOnChannel "Queue"
end clearQueuedSounds

-- Add a sound to our queue, making sure we schedule one if
-- required.
on addQueuedSound pSound
   if the number of lines in field "Queue" < 2 then
      iphonePlaySoundOnChannel getSound(pSound), "Queue", "next"
   end if
   put pSound & return after field "Queue"
end addQueuedSound

-- Sent when a sound finishes. We use this to schedule the next
-- sound from the queue.
on soundFinishedOnChannel pChannel, pSound
   if pChannel is not "Queue" then
      exit soundFinishedOnChannel
   end if
   
   delete line 1 of field "Queue"
   if the number of lines of field "Queue" > 1 then
      iphonePlaySoundOnChannel getSound(line 2 of field "Queue"), "Queue", "next"
   end if
end soundFinishedOnChannel

-- Change the volume of the given channel.
on setChannelVolume pChannel, pVolume
   iphoneSetSoundChannelVolume pChannel, pVolume
end setChannelVolume

-- Work out the absolute path to the given sound - checks for
-- both WAV files and MP3 files.
function getSound pName
   if pName is "(none)" then
      return empty
   end if
   get specialFolderPath("engine") & slash & "Sounds" & slash & pName & ".wav"
   if there is a file it then
      return it
   end if
   get specialFolderPath("engine") & slash & "Sounds" & slash & pName & ".mp3"
   if there is a file it then
      return it
   end if
   return empty
end getSound

-- Keep the current queue listing up to date - simply outputs the
-- list of queues and any sounds they are playing, or will play.
on idle
   if the environment is not "mobile" then
      exit idle
   end if
   
   local tText
   set the itemDelimiter to slash
   repeat for each line tChannel in iphoneSoundChannels()
      put tChannel & return after tText
      get iphoneSoundOnChannel(tChannel)
      if it is not empty then
         put tab & ".../" & item -3 to -1 of it & return after tText
      end if
      get iphoneNextSoundOnChannel(tChannel)
      if it is not empty then
         put tab & ".../" & item -3 to -1 of it & return after tText
      end if
   end repeat
   set the text of field "Channels" to tText
end idle
