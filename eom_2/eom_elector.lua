local eom_elector = {} --# assume eom_elector: EOM_ELECTOR

--v function(model: EOM, name_key: ELECTOR_NAME, starting_loyalty: number, starting_state: string) --> EOM_ELECTOR
function eom_elector.new(model, name_key, starting_loyalty, starting_state)
    local self = {}
    setmetatable(self, {
        __index = eom_elector
    }) --# assume self: EOM_ELECTOR

    self._model = model
    self._name = name_key
    self._homeRegions = model:get_elector_home_regions(name_key)
    self._loyalty = cm:get_saved_value("eom_elector_"..name_key.."_loyalty")  or starting_loyalty
    self._state = cm:get_saved_value("eom_elector_"..name_key.."_state") or starting_state

    self._hatedFactions = {} --:map<string, number>

    return self
end

--v function(self: EOM_ELECTOR, change_value: number, message_event_key: string?)
function eom_elector.change_loyalty(self, change_value, message_event_key)

    local old_loyalty = self._loyalty
    local new_loyalty = old_loyalty + change_value
    if new_loyalty < 0 then
        new_loyalty = 0
    elseif new_loyalty > 999 then
        new_loyalty = 999
    end

    if message_event_key then
        cm:show_message_event(
            self._model._emperor, "","","", true, 591 
        )
    end

    cm:set_saved_value("eom_elector_"..self._name.."_loyalty", new_loyalty)

end



