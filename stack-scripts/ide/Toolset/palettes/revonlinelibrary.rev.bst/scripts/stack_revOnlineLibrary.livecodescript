script "stack_revOnlineLibrary"
-- Stack file: ide/Toolset/palettes/revonlinelibrary.rev
-- Object: stack "revOnlineLibrary"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

# Description
#   Launches the revOnline content browser (i.e. the gui)
command revGoOnline
   set the _ideoverride of stack "revonline" to true
   go stack "revOnline"
end revGoOnline

# Returns
#   The url of the revOnline CGI server
function revOnlineCGIUrl
   global gREVUseTestServer
   if gREVUseTestServer then
      return "https://10.2.1.26/cgi-bin/revonline.rev"
   else
      if revOnlinePrefGet("useSSL") then
         //return "https://developer.runrev.com/cgi-bin/revonline_4.0.rev"
         return "https://developer.runrev.com/revonline.irev"
      else
         //return "http://developer.runrev.com/cgi-bin/revonline_4.0.rev"
          return "http://developer.runrev.com/revonline.irev"
      end if
   end if
end revOnlineCGIUrl

# Returns
#   The url of the revOnline secure CGI server
function revOnlineSecureCGIUrl
   global gREVUseTestServer
   if gREVUseTestServer then
      return "https://10.2.1.26/cgi-bin/revonline_secure.rev"
   else
      if line 4 of revLicenseInfo is "enterprise" then
         //return "https://secure.runrev.com/cgi-bin/revonline_secure.rev"
         return "https://developer.runrev.com/revonline_secure.irev"
      else
         # Temporary measure as ssl is an enterprise feature
         //return "http://secure.runrev.com/cgi-bin/revonline_secure.rev"
         return "http://developer.runrev.com/revonline_secure.irev"
      end if
   end if
end revOnlineSecureCGIUrl

local sSessionId
local sUserEmail
local sPassword
local sUserId
local sDisplayName

# Returns
#   The revOnline session id, or empty if the user is not logged in. Note that just because a sessionId is returned, it doesn't
#   mean the user is definitely logged in, as the session may have expired and not been updated since.
function revOnlineSession
   --   if the text of field "SessionId" of me is not empty then
   --      return the text of field "SessionId" of me
   --   else
   return sSessionId
   --   end if 
end revOnlineSession

function revOnlineId
   return sUserId
end revOnlineId

function revOnlineDisplayName
   return sDisplayName
end revOnlineDisplayName

function revOnlineEmail
   return sUserEmail
end revOnlineEmail

# Parameters
#   pUsername : the email address to log in as 
#   pHash : the hashed password
#   pCallback: the name of the command to send when done
#   pCallbackTarget : the object to send the callback to
#   pLock : optional. If true, then the login is done in a locking manner, bypassing the normal queue mechanism.
# Description
#   Attempts to log the user specified by pUsername and pHash into revOnline.
#   When done, the callback is sent, with a single parameter, containing either the session id, or an error message.
#   If pLock is true, then pCallback and pCallbackTarget are ignored, and the result is returned directly instead.
command revOnlineLogin pUsername, pHash, pCallback, pCallbackTarget, pLock
   local tExternalCallback
   put revCallbackCreate(pCallbackTarget, pCallback) into tExternalCallback
   
   local tInternalCallback
   put revCallbackCreate(the long id of me, "revOnlineLoginCallback") into tInternalCallback
   revCallbackAddParameter tInternalCallback, tExternalCallback
   revCallbackAddParameter tInternalCallback, pUsername
   
   local tRequest
   put "createSession" into tRequest["action"]
   put pUsername into tRequest["parameters"]["email"]
   put pHash into tRequest["parameters"]["password"]
   
   # OK-2009-01-17 - Log in not possible until after the stacks list has finished updating. The reason for this problem is 
   # that the login is done via a modal window which won't go away until it has received its callback from the server. The modal
   # window blocks any other code executing, which means that the queue stops working until the window is closed. This means
   # that any requests the window makes to the queue while its open will not be executed.
   if pLock then
      local tResult
      revOnlineQueryServerLocking tRequest, true, "get"
      put the result into tResult
      
      if item 1 of tResult is "cgierror" then
         put empty into sSessionId
         return false
      else if tResult is not an array and tResult is empty then
         put empty into sSessionid
         return "no connection"
      else
         put pUsername into sUserEmail
         put tResult["session_id"] into sSessionId
         put tResult["user_id"] into sUserId
         put tResult["display_name"] into sDisplayName
         return true
      end if
   else
      revOnlineQueryServer tRequest, true, "get", tInternalCallback
      # OK-2009-09-16 : Allow cancelling of login requests
      --return empty
      return the result
   end if
end revOnlineLogin

# Description
#   Displays the Revolution login dialog, and returns the outcome. This will be either "cancelled" or "success"
command revOnlineShowLoginDialog
   modal stack "revOnlineLoginDialog"
   return the cResult of stack "revOnlineLoginDialog"
end revOnlineShowLoginDialog

command revOnlineShowCreateAccountDialog
   modal stack "revOnlineCreateAccountDialog"
   return the cResult of stack "revOnlineCreateAccountDialog"
end revOnlineShowCreateAccountDialog

command revOnlineShowChangePasswordDialog
   set the loc of stack "revOnlineChangePasswordDialog" to the screenLoc
   modal stack "revOnlineChangePasswordDialog"
   return the cResult of stack "revOnlineChangePasswordDialog"
end revOnlineShowChangePasswordDialog


# Internal callback, should not be called outside this library
command revOnlineLoginCallback pCallback, pUserEmail, pResult
   if item 1 of pResult is "cgierror" then
      revCallbackAddParameter pCallback, "false"
      put empty into sSessionId
   else
      revCallbackAddParameter pCallback, "true"
      put pResult["session_id"] into sSessionId
      put pResult["user_id"] into sUserId
      put pResult["display_name"] into sDisplayName
   end if
   
   put pUserEmail into sUserEmail
   revCallbackApplyLast pCallback
end revOnlineLoginCallback

command revOnlineLogout pCallback, pCallbackTarget
   local tExternalCallback
   put revCallbackCreate(pCallbackTarget, pCallback) into tExternalCallback
   
   local tInternalCallback
   put revCallbackCreate(the long id of me, "revOnlineLogoutCallback") into tInternalCallback
   revCallbackAddParameter tInternalCallback, tExternalCallback
   
   local tRequest
   put "destroySession" into tRequest["action"]
   put revOnlineSession() into tRequest["parameters"]["sessionid"]
   revOnlineQueryServer tRequest, true, "get", tInternalCallback
end revOnlineLogout

command revOnlineLogoutCallback pCallback, pResult
   if pResult is "true" then
      put empty into sSessionId
      put empty into sUserEmail
      put empty into sUserId
      put empty into sDisplayName
   else
   end if
   revCallbackAddParameter pCallback, pResult
   revCallbackApplyLast pCallback
end revOnlineLogoutCallback

command revOnlineChangePassword pSessionId, pOld, pNew, pCallback, pCallbackTarget
   local tRequest
   put "changePassword" into tRequest["action"]
   put pSessionId into tRequest["parameters"]["sessionId"]
   put pOld into tRequest["parameters"]["oldPassword"]
   put pNew into tRequest["parameters"]["newPassword"]
   
   local tCallback
   put revCallbackCreate(pCallbackTarget, pCallback) into tCallback
   revOnlineQueryServer tRequest, true, "get", tCallback
end revOnlineChangePassword

# OK-2009-09-16
#   pSessionId : Obtained from revOnlineSession() after logging in
#   pCallback : name of command.  Passed 2 parameters. pSuccess, whether or not the signup succeeded. pId, the affiliate id,
#  (or error string if pSuccess was false).
#  pCallbackTarget : long id of object to send callback to.
command revOnlineAffiliateSignup pSessionId, pCallback, pCallbackTarget
   local tRequest
   put "affiliateSignup" into tRequest["action"]
   put pSessionId into tRequest["parameters"]["sessionId"]
   
   # Create a callback to this library first so we can wrap the cgi return value nicely
   local tInternalCallback
   put revCallbackCreate(the long id of me, "revOnlineAffiliatesSignupCallback") into tInternalCallback
   
   # Create a callback to send back to the original caller. This is passed as a parameter to the internal callback,
   # so it knows where to send the stuff to.
   local tExternalCallback
   put revCallbackCreate(pCallbackTarget, pCallback) into tExternalCallback
   revCallbackAddParameter tInternalCallback, tExternalCallback
   
   # Send the query and return a request id, which allows us to cancel it.
   revOnlineQueryServer tRequest, false, "get",  tInternalCallback
   return the result
end revOnlineAffiliateSignup

# Internal callback, don't call this from outside the library
command revOnlineAffiliatesSignupCallback pCallback, pResult
   if pResult["success"] then
      revOnlinePrefSet "affiliateId", pResult["id"]
   end if
   revCallbackAddParameter pCallback, pResult["success"]
   revCallbackAddParameter pCallback, pResult["id"]
   revCallbackApplyLast pCallback
end revOnlineAffiliatesSignupCallback

command revOnlineShowAffiliatesSignupDialog
   # OK-2009-09-16: Due to bug 8274, this won't work. The dialog ends up at the location of the current topStack instead.
   # I worked around it by setting the loc of the stack in its preOpenStack event.
   --set the loc of stack "revOnlineAffiliateSignupDialog" to the screenLoc
   modal stack "revOnlineAffiliateSignupDialog"
   return the cResult of stack "revOnlineAffiliateSignupDialog"
end revOnlineShowAffiliatesSignupDialog

local sAccountFailureCallbackTarget
local sAccountFailureCallback

command revOnlineRequestAccount pEmail, pCallback, pCallbackTarget
   # Temporary measure
   if line 3 of the revLicenseInfo is not "evaluation" then
      local tExternalCallback
      put revCallbackCreate(pCallbackTarget, pCallback) into tExternalCallback
      
      local tInternalCallback
      put revCallbackCreate(the long id of me, "revOnlineRequestAccountCallback") into tInternalCallback
      revCallbackAddParameter tInternalCallback, tExternalCallback
      
      if pEmail is not empty then
         local tRequest
         put "accountRequest" into tRequest["action"]
         put pEmail into tRequest["parameters"]["email"]
         revOnlineQueryServer tRequest, false, "get", tInternalCallback
      else
         revCallbackAddParameter tInternalCallback, "Empty email address"
         revCallbackApplyLast tInternalCallback
      end if
   else
      # Temporary
      send sAccountFailureCallback to sAccountFailureCallbackTarget
   end if
end revOnlineRequestAccount


# Temporary measure
command revOnlineSetAccountFailureCallback pCallback, pTarget
   put pTarget into sAccountFailureCallbackTarget
   put pCallback into sAccountFailureCallback
end revOnlineSetAccountFailureCallback

command revOnlineRequestAccountCallback pCallback, pResult
   local tResult
   if item 1 of pResult is "cgierror" then
      put false into tResult
   else
      put pResult into tResult
   end if
   
   revCallbackAddParameter pCallback, tResult
   revCallbackApplyLast pCallback
end revOnlineRequestAccountCallback

command revOnlineDeleteAccount pSessionId, pPassword, pCallback, pCallbackTarget
   local tRequest
   put "deleteUser" into tRequest["action"]
   put pSessionId into tRequest["parameters"]["sessionId"]
   put pPassword into tRequest["parameters"]["password"]
   
   local tCallback
   put revCallbackCreate(pCallbackTarget, pCallback) into tCallback
   revOnlineQueryServer tRequest, true, "get", tCallback
end revOnlineDeleteAccount

command revOnlineResetPassword pEmail, pCallback, pCallbackTarget
   local tInternalCallback
   put revCallbackCreate(the long id of me, "revOnlineResetPasswordCallback") into tInternalCallback
   
   local tExternalCallback
   put revCallbackCreate(pCallbackTarget, pCallback) into tExternalCallback
   revCallbackAddParameter tInternalCallback, tExternalCallback
   
   local tRequest
   put "resetPassword" into tRequest["action"]
   put the text of field "email" into tRequest["parameters"]["email"]
   revOnlineQueryServer tRequest, true, "get", tInternalCallback
end revOnlineResetPassword

command revOnlineResetPasswordCallback pCallback, pResult
   local tResult
   if item 1 of pResult is "cgierror" then
      put false into tResult
   else
      put pResult into tResult
   end if
   
   revCallbackAddParameter pCallback, tResult
   revCallbackApplyLast pCallback
end revOnlineResetPasswordCallback

# Parameters
#   pRequest : an array with keys "action" and "parameters" to send to the cgi
#   pSecure : whether or not to call the secure cgi server or the normal one
#   pMethod : whether to use get or post
#   pCallback : the handle of the callback to send when done.
#   pCache : whether or not to cache the query when it comes back. Defaults to false if not given.
#   pAddToFront : whether the request has priority over the rest of the queue
# Description
#   This is the central point through which all requests to the revOnline servers are made. All it does
#   is send off the array pRequest to the appropriate place and then dispatch pCallback with the output.
#   Note that this command uses a queuing system, so multiple requests may be sent without waiting for 
#   previous ones to finish. In normal operation, callbacks should be received in the order their request was made.
command revOnlineQueryServer pRequest, pSecure, pMethod, pCallback, pCache, pAddToFront
   # Add the request to a queue
   local tRequestDetails
   put pRequest into tRequestDetails["request"]
   put pSecure into tRequestDetails["secure"]
   put pMethod into tRequestDetails["method"]
   put pCallback into tRequestDetails["callback"]
   put pCache into tRequestDetails["cache"]
   
   local tRequestId
   revOnlineQueueAdd tRequestDetails, pAddToFront
   put the result into tRequestId
   
   # OK-2009-02-03 : Bug 7606 - When revOnlineQueryServer is called, this probably means that the user
   # has instigated the query, so we assume that they want us to attempt to connect again, regardless
   # of whatever errors might have been encountered.
   revOnlineSetConnectionError false
   
   # Attempt to dispatch the next queued request, of course this may not be the request we just queued up...
   revOnlineQueueDispatch
   
   # Returning the request id here enables the caller to cancel the request at some later point if required.
   return tRequestId
end revOnlineQueryServer

# Parameters
#   As revOnlineQueryServer but without pAddToFront and pCallback as not applicable
# Description
#   As revOnlineQueryServer except does the query immediately, bypassing the queue.
command revOnlineQueryServerLocking pRequest, pSecure, pMethod, pCache
   # OK-2009-02-03 : Bug 7606 - When revOnlineQueryServer is called, this probably means that the user
   # has instigated the query, so we assume that they want us to attempt to connect again, regardless
   # of whatever errors might have been encountered.
   revOnlineSetConnectionError false
   rvoQueryServerDoLocking pRequest, pSecure, pMethod, pCache
   return the result
end revOnlineQueryServerLocking

local sRequestQueue
local sPendingRequests

# Description
#   This creates a unique identifier for each server request that is queued. This id may then
#   be returned to the caller and can be used to cancel the request and remove it from the queue.
private function queueGenerateRequestId
   local tId
   repeat 32 times
      put any char of "abcdefghijklnmopqrstuvwxyz0123456789_ " after tId
   end repeat
   put the milliseconds after tId
   return tId
end queueGenerateRequestId

# Parameters
#   pRequestDetails : an array containing the request and its details, described below
# Description
#   Adds the specified request to the request queue (at the end)
#   The pRequestDetails array contains the following keys
#      "request" - the array to be sent to the server ("action" and "parameters")
#      "secure" - whether or not its a secure request
#      "method" - the request method, get or post
#      "callback" - the handle to the callback to send when done
#   pAddToFront - if true adds request to front of queue to give it priority
command revOnlineQueueAdd pRequestDetails, pAddToFront
   local tRequestId
   put queueGenerateRequestId() into tRequestId
   put pRequestDetails into sPendingRequests[tRequestId]
   if sRequestQueue is empty then
      put tRequestId  into sRequestQueue
   else if pAddToFront is true then
      put tRequestId & return before sRequestQueue
   else
      put return & tRequestId after sRequestQueue
   end if
   
   return tRequestId
end revOnlineQueueAdd

# Parameters
#   pRequestId : as returned by revOnlineQueryServer, a unique request identifier
# Description
#   Removes the specified request from the queue. Note that if the request has already been dispatched to 
#   the server it will already have been removed from the queue, and calling this command will have no effect.
command revOnlineQueueCancel pRequestId
   delete variable sPendingRequests[pRequestId]
   set the wholeMatches to true
   get lineOffset(pRequestId, sRequestQueue)
   if it <> 0 then
      delete line it of sRequestQueue
   end if
   set the wholeMatches to false
end revOnlineQueueCancel

local sRequestIsRunning = "false"

# Description
#   Attempts to dispatch the next request in the queue. If there is already a request pending then it will do nothing
command revOnlineQueueDispatch
   if sRequestIsRunning then
      exit revOnlineQueueDispatch
   end if
   
   if the number of lines of sRequestQueue = 0 then
      exit revOnlineQueueDispatch
   end if
   
   local tRequestId
   put line 1 of sRequestQueue into tRequestId
   
   local tRequest
   put sPendingRequests[tRequestId] into tRequest
   
   delete line 1 of sRequestQueue
   delete variable sPendingRequests[tRequestId]
   
   put true into sRequestIsRunning
   rvoQueryServerDo tRequest["request"], tRequest["secure"], tRequest["method"], tRequest["callback"], tRequest["cache"]
end revOnlineQueueDispatch

# Description
#   Clears the request queue completely.
command revOnlineQueueClear
   put empty into sRequestQueue
   delete variable sPendingRequests
end revOnlineQueueClear

local sLastCallback
local sLastRequest
local sCacheLastRequest

local sStatusMessage
local sStatusTarget

# Parameters
#   pRequest : an array with keys "action" and "parameters" to send to the cgi
#   pSecure : whether or not to call the secure cgi server or the normal one
#   pMethod : whether to use get or post
#   pCallback : the handle of the callback to send when done.meters
#   pCache : whether or not to cache the result of the query. Defaults to false if not given.
# Description
#   Sends the specified request to the server. Note that this must be kept private and must
#   not be called outside this library. Because libUrl cannot handle multiple urls loading at once,
#   calls to this command are controlled by a queueing system that ensures requests are not sent
#   to the server until no others are pending. Note that post requests are never cached, setting pCache
#   to true for them will have no effect. This is because post requests tend to be things like uploading to
#   the server, and it doesn't make sense to cache them.
private command rvoQueryServerDo pRequest, pSecure, pMethod, pCallback, pCache
   # OK-2009-02-03 : Bug 7606 - If there has been a connection error, don't attempt to do any more queries
   # until the user triggers something to happen. Instead, just send the callback with an empty parameter
   # as the array, and allow the next queue request to dispatch.
   if revOnlineGetConnectionError() then
      libUrlSetStatusCallback empty, empty
      
      revCallbackAddParameter pCallback, empty
      
      send "revCallbackApplyLast pCallback" to me in 0 milliseconds
      send "revOnlineResetRequestIsRunning" to me in 0 milliseconds
      send "revOnlineQueueDispatch" to me in 0 milliseconds
      # TH - attempt to improve recovery after connection failure
      resetall
      exit rvoQueryServerDo
   end if
   
   
   local tUrl
   if pSecure then
      put revOnlineSecureCGIUrl() into tUrl
   else
      put revOnlineCGIUrl() into tUrl
   end if
   libUrlSetSSLVerification false
   
   local tEncodedArray
   put revOnlineEncodeArray(pRequest) into tEncodedArray
   
   put tEncodedArray into sLastRequest
   put (pCache is "true") into sCacheLastRequest
   
   if pMethod is "post" then
      local tUrlData, tResult, tSend
      lock cursor
      set the cursor to watch
      # New progress bar stuff for downloading
      if pRequest["action"] is "setStackData" then
         libUrlSetStatusCallback sStatusMessage, sStatusTarget
      end if      
      
      local tOldHeaders
      put the httpHeaders into tOldHeaders
      set the httpHeaders to "Content-Type: text/plain"
      
      post tEncodedArray to url tUrl
      
      set the httpHeaders to tOldHeaders
      
      # Result contains errors
      put the result into tResult
      put it into tUrlData
      unlock cursor
      
      local tArray
      if tResult is not empty then
         # This probably means there is a problem with the network connection, so we set an error flag
         # to prevent other queries from trying to access the network, and send the callback with an empty
         # array. 
         revOnlineSetConnectionError true
         revCallbackAddParameter pCallback, empty
      else
         # Proceed as normal...
         put revOnlineDecodeArray(tUrlData) into tArray
         revCallbackAddParameter pCallback, tArray["result"]
      end if
      
      # Need to reset the progressbar variables
      libUrlSetStatusCallback empty, empty
      
      send "revCallbackApplyLast pCallback" to me in 0 milliseconds
      send "revOnlineResetRequestIsRunning" to me in 0 milliseconds
      send "revOnlineQueueDispatch" to me in 0 milliseconds
   else
      put pCallback into sLastCallback
      # Check if the request has been cached, if so, return from the cache instead of loading the url
      local tCachedValue
      put revOnlineCacheGet(tEncodedArray) into tCachedValue
      if tCachedValue is not empty then
         put revOnlineDecodeArray(tCachedValue) into tArray
         revCallbackAddParameter pCallback, tArray["result"]
         send "revCallbackApplyLast pCallback" to me in 0 milliseconds
         send "revOnlineResetRequestIsRunning" to me in 0 milliseconds
         send "revOnlineQueueDispatch" to me in 0 milliseconds
         exit rvoQueryServerDo
      end if
      
      put "?request=" & tEncodedArray after tUrl
      libUrlSetSSLVerification false
      # Don't allow libUrl to cache the urls itself, as we want to control which ones get cached.
      # It probably doesn't cache them anyway as they are all CGI requests.
      unload url tUrl
      
      # New progress bar stuff for downloading
      if pRequest["action"] is "fetchStackProperty" and pRequest["parameters"]["propertyName"] is "data" then
         libUrlSetStatusCallback sStatusMessage, sStatusTarget
      end if
      
      load url tUrl with message "revOnlineQueryServerCallback"
   end if
end rvoQueryServerDo

command revOnlineSetStatusCallback pMessage, pTarget
   put pMessage into sStatusMessage
   put pTarget into sStatusTarget
end revOnlineSetStatusCallback

# Parameters
#   The same as rvoQueryServerDo minus callback which is not required.
# Description
#   As rvoQueryServerDo, except locking.
private command rvoQueryServerDoLocking pRequest, pSecure, pMethod, pCache
   local tUrl
   if pSecure then
      put revOnlineSecureCGIUrl() into tUrl
   else
      put revOnlineCGIUrl() into tUrl
   end if
   libUrlSetSSLVerification false
   
   local tEncodedArray
   put revOnlineEncodeArray(pRequest) into tEncodedArray
   
   if pMethod is "post" then
      local tUrlData, tResult, tSend
      
      lock cursor
      set the cursor to watch
      post tEncodedArray to url tUrl
      
      # Result contains errors
      put the result into tResult
      put it into tUrlData
      
      unlock cursor
      
      # Instead of applying the callback here as normal, we simply return the result directly to the caller
      local tArray
      if tResult is not empty then
         revOnlineSetConnectionError true
         return empty
      else
         revOnlineSetConnectionError false
         put revOnlineDecodeArray(tUrlData) into tArray
         return tArray["result"]
      end if
   else
      # Check if the request has been cached, if so, return from the cache instead of loading the url
      local tCachedValue
      put revOnlineCacheGet(tEncodedArray) into tCachedValue
      if tCachedValue is not empty then
         put revOnlineDecodeArray(tCachedValue) into tArray
         return tArray["result"]
      end if
      
      put "?request=" & tEncodedArray after tUrl
      libUrlSetSSLVerification false
      
      lock cursor
      set the cursor to watch
      
      # Don't allow libUrl to cache the urls itself, as we want to control which ones get cached.
      # It probably doesn't cache them anyway as they are all CGI requests.
      unload url tUrl
      
      local tServerResponse
      put url tUrl into tServerResponse
      put the result into tResult
      unlock cursor
      
      if tResult is not empty then
         revOnlineSetConnectionError true
      else
         revOnlineSetConnectionError false
         put empty into tArray
         try
            put revOnlineDecodeArray(tServerResponse) into tArray
         catch tError
            # Server didnt return a valid array, a bug in the cgi script...
         end try
      end if
      
      # Add the request to the cache if applicable
      if not revOnlineGetConnectionError() and pCache then
         revOnlineCacheAdd pRequest, tEncodedArray, tArray["action"]
      end if
      
      return tArray["result"]
   end if
end rvoQueryServerDoLocking

# This is an internal command and should not be called from outside this library. It cannot be made private
# because it has to be sent in time.
command revOnlineResetRequestIsRunning
   put false into sRequestIsRunning
end revOnlineResetRequestIsRunning

# OK-2009-02-03 : Bug 7606 - This variable will contain true if a connection error was encountered by the last query executed.
local sConnectionError = "false"

function revOnlineGetConnectionError
   return sConnectionError
end revOnlineGetConnectionError

local sConnectionErrorCallback
local sConnectionErrorCallbackTarget

command revOnlineSetConnectionErrorCallback pCallback, pTarget
   put pTarget into sConnectionErrorCallbackTarget
   put pCallback into sConnectionErrorCallback
end revOnlineSetConnectionErrorCallback

command revOnlineSetConnectionError pValue
   --log "Setting connection error :" & pValue
   if pValue is true and pValue is not sConnectionError then
      if sConnectionErrorCallback is not empty then
         try
            send sConnectionErrorCallback to sConnectionErrorCallbackTarget
         end try
      end if
   end if
   put pValue into sConnectionError
end revOnlineSetConnectionError

# This is an internal command and should not be called from outside this library
command revOnlineQueryServerCallback pUrl, pStatus
   unlock cursor
   
   local tArray
   local tEncodedArray
   put url pUrl into tEncodedArray
   
   # OK-2009-02-03 : Bug 7606 - Detect if the url was successfully loaded or not
   if pStatus is "timeout" or pStatus is "error" or pStatus is empty then
      
      # TH - Occasionally get an error message but with valid data in pUrl, temporary fix
      try
         put revOnlineDecodeArray(tEncodedArray) into tArray
      end try
      if the keys of tArray is empty then
         revOnlineSetConnectionError true
      else
         revOnlineSetConnectionError false
      end if
      
      # TH
      --revOnlineSetConnectionError false
   else
      revOnlineSetConnectionError false
   end if
   
   # Need to unset callbacks for progressbar
   libUrlSetStatusCallback empty, empty
   
   # Add the request to the cache if applicable
   if not revOnlineGetConnectionError() and sCacheLastRequest then
      get revOnlineDecodeArray(tEncodedArray)
      revOnlineCacheAdd sLastRequest, tEncodedArray, it["action"]
   end if
   
   try
      if not revOnlineGetConnectionError() then
         put revOnlineDecodeArray(tEncodedArray) into tArray
      else
         put empty into tArray
      end if
      
      revCallbackAddParameter sLastCallback, tArray["result"]
      revCallbackApplyLast sLastCallback
   catch tError
      log "The following server error was encountered:"
      log "---------------------------------------------------------"
      log "pUrl: " & pUrl
      log "pStatus: " & pStatus
      log "UrlData: " & tEncodedArray
      log "sLastCallback: " & sLastCallback
      log "Error: " & tError
      log "---------------------------------------------------------"
   end try
   
   # Ensure that only a single request to the server runs at a time.
   put false into sRequestIsRunning
   revOnlineQueueDispatch
end revOnlineQueryServerCallback

local sRequestCount
local sTotalRequestSize
local sUncompressedRequestSize

--constant kUseCompression = "false"
constant kUseCompression = "true"

# Description
#   This function takes a Revolution array and serializes it into a urlEncoded binary string
function revOnlineEncodeArray pArray
   # OK-2009-01-31 : Temporarily we calculate both the compressed and normal
   # data, so that we can compare their sizes and work out if compression is actually
   # helping. Unfortunately it seems that it makes a much smaller difference than hoped.
   local tCompressed, tNormal
   // AL-2014-08-18: [[ Bug 12547 ]] Encode array for revOnline in 6.x format
   put urlEncode(base64Encode(compress(arrayEncode(pArray, "6.0")))) into tCompressed
   put urlEncode(base64Encode(arrayEncode(pArray, "6.0"))) into tNormal
   
   add the length of tCompressed to sTotalRequestSize
   add the length of tNormal to sUncompressedRequestSize
   add 1 to sRequestCount
   
   if kUseCompression then
      return tCompressed
   else
      return tNormal
   end if
end revOnlineEncodeArray

# Description
#   This function converts a urlEncoded binary string containg a serialized Revolution array back into the original array.
function revOnlineDecodeArray pEncodedArray
   local tArray
   if kUseCompression then
      put arrayDecode(decompress(base64Decode(urlDecode(pEncodedArray)))) into tArray
   else
      put arrayDecode(base64Decode(urlDecode(pEncodedArray))) into tArray
   end if
   
   # For simplicity, just rebuild the original string the array and find out what its size would have been
   # in both cases.
   local tCompressed, tNormal
   // AL-2014-08-18: [[ Bug 12547 ]] Encode array for revOnline in 6.x format
   put urlEncode(base64Encode(compress(arrayEncode(tArray, "6.0")))) into tCompressed
   put urlEncode(base64Encode(arrayEncode(tArray, "6.0"))) into tNormal
   
   add the length of tCompressed to sTotalRequestSize
   add the length of tNormal to sUncompressedRequestSize
   add 1 to sRequestCount
   
   return tArray
end revOnlineDecodeArray

function revOnlineAverageDataSize
   return "With compression: " & sTotalRequestSize / sRequestCount & return & \
          "Without compression: " & sUncompressedRequestSize / sRequestCount
end revOnlineAverageDataSize

command revOnlinePickRandomStack pCallback
   local tQuery
   put "randomStack" into tQuery["action"]
   
   local tInternalCallback
   put revCallbackCreate(the long id of me, "revOnlinePickRandomStackCallback") into tInternalCallback
   
   revCallbackAddParameter tInternalCallback, pCallback
   revOnlineQueryServer tQuery, false, "get", tInternalCallback, false, false
end revOnlinePickRandomStack

command revOnlinePickRandomStackCallback pCallback, pStackId
   revCallbackAddParameter pCallback, pStackId
   revCallbackApplyLast pCallback
end revOnlinePickRandomStackCallback


#########################################################################
# Callback library
# At the time of writing, this library was only used by revOnline, hence its inclusion in this script. However
# the methods have been prefixed simply with "rev" as they may be used in other places if they are useful
#########################################################################

# Holds whether or not the callback library has been initialized
local sgCallbackInitialised

# Holds an array of callbacks, including their targets and parameters
local sgCallbacks

# Holds the last callback handle that was allocated, allowing unique handles to be generated each time
local sgCallbackLastHandle

# Holds an array of cancelled callbacks, this is checked whenever a callback is about to be sent.
local sgCancelledCallbacks

private function errorString pString
   return "rvoerr," & pString
end errorString

# Description
#   Initialises the callback library
command revCallbackInitialise
   if sgCallbackInitialised is true then
      exit revCallbackInitialise
   end if
   
   put empty into sgCallbacks
   put 0 into sgCallbackLastHandle
   
   put true into sgCallbackInitialised
end revCallbackInitialise

# Description
#   Should be called when the library is unloaded, although it currently does nothing.
command revCallbackFinalise
   if sgCallbackInitialised is not true then
      exit revCallbackFinalise
   end if
   
   put false into sgCallbackInitialised --as not init anylonger
end revCallbackFinalise

# Parameters
#   pObject : the target of the callback to be created, i.e which object it will be sent to
#   pMessage : the name of the command / message to send
#   <any other parameters> : these become parameters sent to the callback target
# Returns
#   A unique handle that identifies the callback created. This handle is required to edit, activate and destroy the callback.
function revCallbackCreate pObject, pMessage
   local tArray
   put pObject into tArray["object"]
   put pMessage into tArray["message"]
   
   local tArguments, tIndex
   
   local tParamNumber
   put 1 into tParamNumber
   repeat with tIndex = 3 to the paramCount
      local tValue
      put param(tIndex) into tValue
      put tValue into tArray["arguments"][tParamNumber]
   end repeat
   
   add 1 to sgCallbackLastHandle
   put tArray into sgCallbacks[sgCallbackLastHandle]
   
   # return the index of where in the array the callback info is stored
   return sgCallbackLastHandle
end revCallbackCreate

# Parameters
#   pHandle : a callback handle as returned by revCallbackCreate
# Description
#   Destroys the callback by simply removing it from the sgCallbacks array.
command revCallbackDestroy pHandle
   delete variable sgCallbacks[pHandle]
end revCallbackDestroy

# Parameters
#   pHandle : a callback handle as returned by revCallbackCreate
# Description
#   Cancels the specified callback. This does not delete it, it simply means that the callback
#   will not be sent again. The callback may be deleted at some later point, when no references to it
#   linger anywhere.
command revCallbackCancel pHandle
   put "true" into sgCancelledCallbacks[pHandle]
end revCallbackCancel

# Parameters
#   pHandle : a callback handle as returned by revCallbackCreate
# Description
#   Sends the specified callback to its target, with whatever parameters are currently associated with it (and any new ones added)
on revCallbackApply pHandle
   if sgCancelledCallbacks[pHandle] then
      exit revCallbackApply
   end if
   
   local tArguments, tArgumentCount, tIndex, tArgumentString
   put 1 into tArgumentCount
   
   # Go through the parameters array for the callback, and add each parameter's value
   # to the tArguments array.
   repeat with x = 1 to (item 2 of line 1 of the extents of sgCallbacks[pHandle]["arguments"])
      put sgCallbacks[pHandle]["arguments"][x] into tArguments[tArgumentCount]
      put "tArguments[" & tArgumentCount & "]," after tArgumentString
      add 1 to tArgumentCount
   end repeat
   
   # Go through any extra arguments passed to this command, and add them to the array.
   repeat with tIndex = 2 to the paramCount
      put param(tIndex) into tArguments[tArgumentCount]
      put "tArguments[" & tArgumentCount & "]," after tArgumentString
      add 1 to tArgumentCount
   end repeat
   delete the last char of tArgumentString
   
   local tMessage, tTarget
   put sgCallbacks[pHandle]["message"] && tArgumentString into tMessage
   put sgCallbacks[pHandle]["object"] into tTarget
   
   # At the moment this line may throw an error if the message or target don't exist
   send tMessage to tTarget
   return the result
end revCallbackApply


# Parameters
#   pHandle : a callback handle as returned by revCallbackCreate
# Description
#   Sends the specified callback to its target, with whatever parameters are currently associated with it, then destroys the callback.
#   Note that any additional parameters are ignored here, rather than passed to the callback target, its probably possible to fix this,
#   but a little awkward. The problem can easily be worked round by simply calling revCallbackApply then revCallbackDestroy directly.
on revCallbackApplyLast pHandle
   revCallbackApply pHandle
   revCallbackDestroy pHandle
end revCallbackApplyLast

# Allows adding parameters to an existing callback.

# Parameters
#   pHandle : a callback handle as returned by revCallbackCreate
#   pValue : the value of the new parameter to add
#   pNumber : the parameter number, if empty, the default is to add the new parameter after any existing ones.
# Description
#   Adds the specified parameter to a callback
on revCallbackAddParameter pHandle, pValue, pNumber
   if not revCallbackExists(pHandle) then
      return errorString("callback_not_found")
   end if
   
   local tArgumentCount
   put item 2 of line 1 of the extents of sgCallbacks[pHandle]["arguments"] into tArgumentCount
   
   if (pNumber is empty) or (pNumber > tArgumentCount) or (pNumber < 0) then
      # If no parameter number is specified, or the specified number invalid,
      # we just put the new value at the end of the list of parameters.
      put pValue into sgCallbacks[pHandle]["arguments"][tArgumentCount + 1]
   else
      # Otherwise, we get the old parameters array, and copy it into a new one, but moving
      # all parameters with index greater or equal to pNumber down by one. Then replace
      # the old parameters array with this new one.
      local tOldParameters, tNewParameters
      put sgCallbacks[pHandle]["arguments"] into tOldParameters
      repeat for each key tKey in tOldParameters
         if tKey >= pNumber then
            put tOldParameters[tKey] into tNewParameters[tKey + 1]
         else
            put tOldParameters[tKey] into tNewParameters[tKey]
         end if
      end repeat
      
      put pValue into tNewParameters[pNumber]
      put tNewParameters into sgCallbacks[pHandle]["arguments"]
   end if
end revCallbackAddParameter

# Parameters
#   pHandle : a callback handle as returned by revCallbackCreate
#   pNumber : the parameter number to modify
#   pValue : the new parameter value
# Description
#   Sets the value of the specified existing parameter to pValue
on revCallbackSetParameter pHandle, pNumber, pValue
   if not revCallbackExists(pHandle) then
      return errorString("callback_not_found")
   end if
   
   local tArgumentCount
   put item 2 of line 1 of the extents of sgCallbacks[pHandle]["arguments"] into tArgumentCount
   
   if (pNumber is empty) or (pNumber > tArgumentCount) or (pNumber < 0) then
      return errorString("invalid_parameter_index")
   end if
   
   put pValue into sgCallbacks[pHandle]["arguments"][pNumber]
end revCallbackSetParameter

# Parameters
#   pHandle : a callback handle as returned by revCallbackCreate
#   pNumber : the number of the parameter to retrieve
# Returns
#   The current value of the specified parameter, or an error string if not found.
function revCallbackGetParameter pHandle, pNumber
   local tCallback, tValue
   
   if not revCallbackExists(pHandle) then
      return errorString("callback_not_found")
   end if
   
   local tArgumentCount
   put item 2 of line 1 of the extents of sgCallbacks[pHandle]["arguments"] into tArgumentCount
   
   if (pNumber is empty) or (pNumber > tArgumentCount) or (pNumber < 0) then
      return errorString("invalid_parameter_index")
   end if
   
   return sgCallbacks[pHandle]["arguments"][pNumber]
end revCallbackGetParameter

# Parameters
#   pHandle : a callback handle as returned by revCallbackCreate
# Returns
#   Whether or not the specified callback is known.
function revCallbackExists pHandle
   return pHandle is among the keys of sgCallbacks
end revCallbackExists

# Parameters
#   pHandle : a callback handle as returned by revCallbackCreate
# Returns
#   Returns true or false depending on whether the callback is valid, according to:
#   1) The target is not empty
#   2) The message is not empty (no point sending an empty message!)
#   3) The target exists (we are not pointing at something that doesnt exist).
#   4) The message points to a handler that exists (this is checked in a little bit of a crude way).
function revCallbackValid pHandle
   local tMessage, tTarget
   put line 1 of sgCallbacks[pHandle] into tTarget
   put line 2 of sgCallbacks[pHandle] into tMessage
   return tTarget is not empty and tMessage is not empty and exists(tTarget) and ((("on" && tMessage) is among the lines of the script of tTarget ) or ("command " & tMessage is among the lines of the script of tTarget))
end revCallbackValid

# Parameters
#   pHandle : a callback handle as returned by revCallbackCreate
# Returns
#   All the details stored for the specified callback. This function is for debugging purposes only.
#   The return value will be an array.
function revCallbackDetails pHandle
   return sgCallbacks[pHandle]
end revCallbackDetails

# Parameters
#   pHandle : a callback handle as returned by revCallbackCreate
# Description
#   Outputs all information about the specified callback to the message box.
command revCallbackLog pHandle
   logArray sgCallbacks[pHandle]
end revCallbackLog


#########################################################################
# RevOnline Preferences
#########################################################################

local sPrefs

command revOnlinePrefSet pPref, pValue
   put pValue into sPrefs[pPref]
   revOnlinePrefSave
end revOnlinePrefSet

function revOnlinePrefGet pPref
   if pPref is among the keys of sPrefs then
      return sPrefs[pPref]
   else
      return revOnlinePrefGetDefault(pPref)
   end if
end revOnlinePrefGet

private function revOnlinePrefGetDefault pPref
   switch pPref
      case "rememberEmail"
         return true
      break
      case "rememberPassword"
         return false
      break
      case "viewMode"
         return "grid"
      break
      case "cacheMaxSize"
         # This is in bytes
         return 1000 * 1024
      break
      case "cacheValidity"
         # This is in seconds, and repesents how old a cache entry needs to be before it gets deleted
         # Note that younger cache items may still be removed if the cache becomes too large
         return 1000
      break
      case "mode"
         return "grid"
      break
      case "view type"
         return "stack"
      break
      case "stack id"
         return "empty"
      break
      case "user id"
         return "empty"
      break
      case "password"
         return "empty"
      break
      case "width"
         return "927"
      break
      case "height"
         return "522"
      break
      case "location"
         return (the screenloc)
      break
      case "textonlymode"
         return false
      break
      case "stacksPerPage"
         return 10
      break
      case "useSSL"
         return "false"
      break         
      case "cache"
      case "cachesize"
      case "cachetimestamps"
      case "cacheactions"
         return empty
      break
   end switch
end revOnlinePrefGetDefault

command revOnlinePrefSave
   set the cRevOnlinePrefs of stack "revPreferences" to sPrefs
end revOnlinePrefSave

command revOnlinePrefLoad
   put the cRevOnlinePrefs of stack "revPreferences" into sPrefs
end revOnlinePrefLoad





#########################################################################
# Cache library
#########################################################################

local sCache
local sCacheSize
local sCacheTimestamps

local sCacheActions

# Parameters
#   pKey : An identifier for the cache item. If this collides with an existing cache item, the old one will be replaced
#   pData : The data to be cached
# Description
#   Adds the specified request to the cache, which is stored in memory. If the cache has become too large,
#   then older items will be cleared to make space. *NOTE: pKey must not contain any tab or return chars*
command revOnlineCacheAdd pKey, pData, pAction
   # First, insert the data into the cache
   put pData into sCache[pKey]
   put sCacheSize + the length of pData into sCacheSize
   put the seconds into sCacheTimestamps[pKey]
   
   if pAction is not empty then
      put true into sCacheActions[pAction][pKey]
   end if
   
   # Then remove any expired or excess items from the cache.
   # After this step is complete, the cache will have a maximum size of revOnlinePrefGet("cacheMaxSize")
   # The assumption is made here that cacheClean will never remove the item we just added unless the max
   # cache size is 0.
   cacheClean
end revOnlineCacheAdd

# Parameters
#   pKey : the identifer for the cache item to remove. 
#  Description
#   Removes the specified item from the cache. If this item doesn't exist in the cache, will have no effect.
command revOnlineCacheRemove pKey, pDontClearActions
   local tLength
   put the length of sCache[pKey] into tLength
   delete variable sCache[pKey]
   delete variable sCacheTimestamps[pKey]
   
   if not pDontClearActions then
      repeat for each key tAction in sCacheActions
         delete variable sCacheActions[tAction][pKey]
      end repeat
   end if
   
   subtract tLength from sCacheSize
end revOnlineCacheRemove

# Parameters
#   pAction : the name of a server action
# Description
#   Removes all cache entries that match the specified action. Be careful using this, it could be slow
#   with a large cache size
command revOnlineCacheRemoveAction pAction
   repeat for each key tKey in sCacheActions[pAction]
      revOnlineCacheRemove tKey, true
   end repeat
   delete variable sCacheActions[pAction]
end revOnlineCacheRemoveAction

# Description
#   Clears the entire revOnline cache.
command revOnlineCacheClear
   delete variable sCache
   delete variable sCacheTimestamps
   put 0 into sCacheSize
end revOnlineCacheClear

# Might be useful for debugging but probably not needed
function revOnlineCacheSize
   return sCacheSize
end revOnlineCacheSize

# Parameters
#   pKey : the identifier for the cache item to retrieve
# Description
#   Returns the cached value for pKey. This will be empty if the item is not cached, or if it has expired.
function revOnlineCacheGet pKey
   local tAge
   local tTimeTest
   put sCacheTimestamps[pKey] into tTimeTest
   put the seconds - sCacheTimestamps[pKey] into tAge
   if tAge > revOnlinePrefGet("cacheValidity") then
      revOnlineCacheRemove pKey
      return empty
   else
      return sCache[pKey]
   end if
end revOnlineCacheGet

# Description
#   First removes any expired items from the cache. Then, if the cache is bigger than it should be,
#   removes any excess items.
private command cacheClean
   # First get a list of all the cache entries and timestamps. This is stored in the sCacheTimestamps array
   local tTimestamps
   put sCacheTimestamps into tTimestamps
   combine tTimestamps with return and tab
   set the itemDelimiter to tab
   sort tTimestamps ascending numeric by item 2 of each
   
   # Next, remove any expired items from the cache, keeping tCleanedTimestamps up to date
   local tAge, tLineNumber, tCleanedTimestamps
   put 1 into tLineNumber
   repeat for each line tLine in tTimestamps
      put the seconds - item 2 of tLine into tAge
      if tAge > revOnlinePrefGet("cacheValidity") then
         revOnlineCacheRemove (item 1 of tLine)
      else
         put line tLineNumber to -1 of tTimestamps into tCleanedTimestamps
      end if
      add 1 to tLineNumber
   end repeat
   
   # Finally remove any excess entires if the cache is still over-full. As tCleanedTimestamps should be up to date
   # and ordered, we can simply delete from the top (i.e the oldest cache entries) until the cache is back to the size it should be.
   repeat until sCacheSize <= revOnlinePrefGet("cacheMaxSize") or the number of lines of tCleanedTimestamps = 0
      revOnlineCacheRemove item 1 of line 1 of tCleanedTimestamps
      delete line 1 of tCleanedTimestamps
   end repeat
end cacheClean

command revOnlineCacheLoad
   # Load saved cache
   put revOnlinePrefGet("cache") into sCache
   put revOnlinePrefGet("cachesize") into sCacheSize
   put revOnlinePrefGet("cachetimestamps") into sCacheTimestamps
   put revOnlinePrefGet("cacheactions") into sCacheActions   
end revOnlineCacheLoad

command revOnlineCacheSave
   # Save cache in pref
   revOnlinePrefSet "cache", sCache
   revOnlinePrefSet "cachesize", sCacheSize
   revOnlinePrefSet "cachetimestamps", sCacheTimestamps
   revOnlinePrefSet "cacheactions", sCacheActions   
end revOnlineCacheSave

#########################################################################
# Logging / debugging
#########################################################################

private command log pMessage
      local tMessage
   --   put "BEGIN revOnlineLibrary message" & return into tMessage
   --   put tab & "----------------------------------------" & return after tMessage
   --   put tab & pMessage & return after tMessage
   --   put tab & "Context: " & return after tMessage
   --   get the executionContexts
   --   replace return with return & tab in it
   --   put tab & it & return after tMessage
   --   put tab & "----------------------------------------" & return after tMessage
   --   put "END revOnlineLibrary message" after tMessage
   
   put pMessage into tMessage
   put tMessage & return after msg
end log




