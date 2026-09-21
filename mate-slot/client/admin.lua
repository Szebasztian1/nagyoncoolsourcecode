SlotAdmin = {}

local function dbg(msg)
    if Config.Debug then
        print(("[mate-slot:admin] %s"):format(msg))
    end
end

RegisterCommand("slotadmin", function(source, args)
    local sub = args[1]

    if sub == "reset" then
        SlotSession:ForceReset()
        dbg("slotadmin reset — session force-reset")
    elseif sub == "leave" then
        SlotSession:ForceLeave()
        dbg("slotadmin leave — force leave triggered")
    else
        dbg(("slotadmin — unknown subcommand: %s"):format(tostring(sub)))
    end
end, false)

dbg("Admin module loaded")
