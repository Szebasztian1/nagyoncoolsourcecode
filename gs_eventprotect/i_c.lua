local PEVENTS = exports["gs_eventprotect"]:GS_GetSafeEvents()
local triggerServerEvent = TriggerServerEvent

	function TriggerServerEvent(event, ...)
        if not PEVENTS[event] then 
            return triggerServerEvent(event, ...)
        end 
		return exports["gs_eventprotect"]:GS_TriggerServerEvent(event, ...)
	end