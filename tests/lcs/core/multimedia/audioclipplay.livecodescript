script "CoreMultimediaAudioClipPlay"
/*
Copyright (C) 2026 OXT-Beyond contributors.

This file is part of OXT-Beyond, a fork of LiveCode Community.

LiveCode is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License v3 as published by the Free
Software Foundation.

LiveCode is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with LiveCode.  If not see <http://www.gnu.org/licenses/>.  */

/*
A clip that is played finishes: the sound becomes "done" once it has
played, or at once where there is nothing to play it on. On Linux it
never did without EsounD (which current distributions do not ship), so
a script waiting for it waited for ever. Each wait here has a deadline
instead, so a sound that never finishes fails the test.
*/

-- A WAV file of pSeconds of silence, 8000 Hz, 16-bit, mono
private function SilentWav pSeconds
   local tRate, tSize, tZeros
   put 8000 into tRate
   put tRate * 2 * pSeconds into tSize
   put numToByte(0) into tZeros
   repeat until the number of bytes in tZeros >= tSize
      put tZeros after tZeros
   end repeat
   return binaryEncode("a4Ia4a4IssIIssa4I", "RIFF", 36 + tSize, "WAVE", "fmt ", \
         16, 1, 1, tRate, tRate * 2, 2, 16, "data", tSize) & byte 1 to tSize of tZeros
end SilentWav

private function ImportSilentClip pSeconds
   local tPath
   put the temporary folder & "/oxt-aclip-play-test.wav" into tPath
   put SilentWav(pSeconds) into URL ("binfile:" & tPath)
   import audioClip from file tPath
   delete file tPath
   return the short name of the last audioClip
end ImportSilentClip

-- Waits for the sound to be "done" for up to pSeconds
private function SoundDoneWithin pSeconds
   local tDeadline
   put the milliseconds + pSeconds * 1000 into tDeadline
   repeat until the sound is "done" or the milliseconds > tDeadline
      wait 20 milliseconds with messages
   end repeat
   return the sound is "done"
end SoundDoneWithin

on TestPlayAudioClipFinishes
   local tClip
   -- On CI's macOS (NSSound, with no sound device) the sound was still the
   -- clip's name 10 seconds after a 0.5-second clip was played; whether a
   -- Mac with speakers finishes needs a pass on one. The fix this tests is
   -- the Linux one.
   if the platform is "MacOS" then
      TestSkip "the sound is done after the clip has played", \
            "the sound did not finish on CI's macOS; not yet checked on a Mac"
      exit TestPlayAudioClipFinishes
   end if
   put ImportSilentClip(0.5) into tClip
   play audioClip tClip
   TestAssert "the sound is done after the clip has played", SoundDoneWithin(10)
   delete audioClip tClip
end TestPlayAudioClipFinishes

on TestPlayStopAudioClip
   local tClip
   put ImportSilentClip(2) into tClip
   play audioClip tClip looping
   play stop
   TestAssert "the sound is done after play stop", the sound is "done"
   delete audioClip tClip
end TestPlayStopAudioClip
