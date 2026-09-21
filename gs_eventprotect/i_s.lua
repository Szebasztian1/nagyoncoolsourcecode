local PEVENTS = exports["gs_eventprotect"]:GS_GetSafeEvents()

local registerNetEvent, addEventHandler = RegisterNetEvent, AddEventHandler

	function RegisterNetEvent(event, func)
		if not PEVENTS[event] then
			return registerNetEvent(event, func)
		end
        if not func then 
		    return registerNetEvent(event, func)
        end 

        exports["gs_eventprotect"]:GS_IllegalEvent(event)

        return registerNetEvent("gs:serverevent", function(token, invresource, trigevent, ...)
            if trigevent ~= event then return end 
            if exports["gs_eventprotect"]:GS_ValidateEvent(source, token, invresource, trigevent) then 
                return func(...)
            end 
        end)
	end

	function AddEventHandler(event, func)
        if not PEVENTS[event] then
			return addEventHandler(event, func)
		end 

        exports["gs_eventprotect"]:GS_IllegalEvent(event)

		return registerNetEvent("gs:serverevent", function(token, invresource, trigevent, ...)
            if trigevent ~= event then return end 
            if exports["gs_eventprotect"]:GS_ValidateEvent(source, token, invresource, trigevent) then 
                return func(...)
            end 
        end)
	end