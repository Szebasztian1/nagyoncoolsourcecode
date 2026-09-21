local TimecycleService = {}
TimecycleService._tickState = false

function TimecycleService:onEnteringInstance()
    NetworkOverrideClockTime(1, 0, 0)
    PauseClock(true)
    SetOverrideWeather("SUNNY")

    if not self._tickState then
        self._tickState = true

        Citizen.CreateThread(function()
            while self._tickState do
                self:onInterval()

                Citizen.Wait(60000)
            end
        end)
    end
end

function TimecycleService:onLeavingInstance()
    self._tickState = false

    NetworkClearClockTimeOverride()
    ClearOverrideWeather()
end

function TimecycleService:onInterval()
    if GetClockHours() ~= 0 then
        NetworkOverrideClockTime(1, 0, 0)
    end

    SetOverrideWeather("SUNNY")
end

return TimecycleService
