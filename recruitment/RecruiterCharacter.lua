--ui utility
--v function(index: number) --> string
local function GetQueuedUnit(index)
    local queuedUnit = find_uicomponent(core:get_ui_root(), "main_units_panel", "units", "QueuedLandUnit " .. index);
    if not not queuedUnit then
        queuedUnit:SimulateMouseOn();
        local unitInfo = find_uicomponent(core:get_ui_root(), "UnitInfoPopup", "tx_unit-type");
        local rawstring = unitInfo:GetStateText();
        local infostart = string.find(rawstring, "unit/") + 5;
        local infoend = string.find(rawstring, "]]") - 1;
        local QueuedUnitName = string.sub(rawstring, infostart, infoend)
        return QueuedUnitName
    else
        return nil
    end
end











local recruiter_character = {} --# assume recruiter_character: RECRUITER_CHARACTER

--v function(manager: RECRUITER_MANAGER,cqi: CA_CQI) --> RECRUITER_CHARACTER
function recruiter_character.new(manager, cqi)
    local self = {}
    setmetatable(self, {
        __index = recruiter_character,
        __tostring = function() return "RECRUITER_CHARACTER" end
    })--# assume self: RECRUITER_CHARACTER
    self._cqi = cqi
    self._manager = manager
    self._armyCounts = {} --:map<string, number>
    self._queueCounts = {} --:map<string, number>
    self._restrictedUnits = {} --:map<string, boolean>

    self._staleQueueFlag = true --:boolean
    self._staleArmyFlag = true --:boolean
    
    return self
end

--v function(self: RECRUITER_CHARACTER, text: any) 
function recruiter_character.log(self, text)

end

--v function(self: RECRUITER_CHARACTER) --> CA_CQI
function recruiter_character.cqi(self)
    return self._cqi
end

--v function(self: RECRUITER_CHARACTER) --> RECRUITER_MANAGER
function recruiter_character.manager(self)
    return self._manager
end

--v function(self: RECRUITER_CHARACTER) --> map<string, number>
function recruiter_character.get_army_counts(self)
    return self._armyCounts
end

--v function(self: RECRUITER_CHARACTER) --> map<string, number>
function recruiter_character.get_queue_counts(self)
    return self._queueCounts
end

--v function(self: RECRUITER_CHARACTER) --> map<string, boolean>
function recruiter_character.get_unit_restrictions(self)
    return self._restrictedUnits
end


--stale queues and armies

--v function(self: RECRUITER_CHARACTER) --> boolean
function recruiter_character.is_queue_stale(self)
    return self._staleQueueFlag
end

--v function(self: RECRUITER_CHARACTER) --> boolean
function recruiter_character.is_army_stale(self)
    return self._staleArmyFlag
end

--v function(self: RECRUITER_CHARACTER)
function recruiter_character.set_queue_stale(self)
    self._staleQueueFlag = true
end

--v function(self: RECRUITER_CHARACTER)
function recruiter_character.set_army_stale(self)
    self._staleArmyFlag = true
end

--v function(self: RECRUITER_CHARACTER)
function recruiter_character.set_queue_fresh(self)
    self._staleQueueFlag = false
end

--v function(self: RECRUITER_CHARACTER)
function recruiter_character.set_army_fresh(self)
    self._staleArmyFlag = false
end

--v function(self: RECRUITER_CHARACTER)
function recruiter_character.wipe_queue(self)
    for unit, quantity in pairs(self:get_queue_counts()) do
        self._queueCounts[unit] = 0
    end
end

--v function(self: RECRUITER_CHARACTER)
function recruiter_character.wipe_army(self)
    for unit, quantity in pairs(self:get_army_counts()) do
        self._armyCounts[unit] = 0
    end
end




--v function(self: RECRUITER_CHARACTER, unitID: string)
function recruiter_character.add_unit_to_army(self, unitID)
    if self._armyCounts[unitID] == nil then
        self._armyCounts[unitID] = 0 
    end
    self._armyCounts[unitID] = self:get_army_counts()[unitID] + 1;
end

--v function(self: RECRUITER_CHARACTER, unitID: string)
function recruiter_character.add_unit_to_queue(self, unitID)
    if self._queueCounts[unitID] == nil then
        self._queueCounts[unitID] = 0 
    end
    self._queueCounts[unitID] = self:get_queue_counts()[unitID] + 1;
end

--v function(self: RECRUITER_CHARACTER)
function recruiter_character.refresh_army(self)
    self:wipe_army()
    local army = cm:get_character_by_cqi(self:cqi()):military_force():unit_list()
    for i = 0, army:num_items() - 1 do
        local unitID = army:item_at(i):unit_key()
        self:add_unit_to_army(unitID)
    end
    self:set_army_fresh()
end



--v function(self: RECRUITER_CHARACTER)
function recruiter_character.refresh_queue(self)
    self:wipe_queue()
    local unitPanel = find_uicomponent(core:get_ui_root(), "main_units_panel")
    if not unitPanel then
        return
    end
    for i = 0, 18 do
        local unitID = GetQueuedUnit(i)
        if unitID then
            self:add_unit_to_queue(unitID)
        else
            self:log("Found no unit at ["..i.."], ending the refresh queue loop!")
        end
    end
    self:set_queue_fresh()
end

--v function(self:RECRUITER_CHARACTER, unitID: string) --> number
function recruiter_character.get_unit_count_in_army(self, unitID)
    if self:get_army_counts()[unitID] == nil then
        self._armyCounts[unitID] = 0
    end
    return self:get_army_counts()[unitID]
end

--v function(self:RECRUITER_CHARACTER, unitID: string) --> number
function recruiter_character.get_unit_count_in_queue(self, unitID)
    if self:get_queue_counts()[unitID] == nil then
        self._queueCounts[unitID] = 0
    end
    if self:is_queue_stale() then
        return 0 
    end
    return self:get_queue_counts()[unitID]
end


--checks for stale information, refreshes it, then returns the count
--v function(self: RECRUITER_CHARACTER, unitID: string) --> number
function recruiter_character.get_unit_count(self, unitID)
    if self:is_queue_stale() then
        self:refresh_queue()
    end
    --will not provide any information about the queue if the queue is stale and the queue refresh fails.
    local queue_count = self:get_unit_count_in_queue(unitID)
    if self:is_army_stale() then
        self:refresh_army() 
    end
    local army_count = self:get_unit_count_in_army(unitID)
    return army_count + queue_count
end


--v function(self: RECRUITER_CHARACTER, unitID: string, restricted: boolean)
function recruiter_character.set_unit_restriction(self, unitID, restricted)
    self._restrictedUnits[unitID] = restricted
end

--v function(self: RECRUITER_CHARACTER, unitID: string) --> boolean
function recruiter_character.is_unit_restricted(self, unitID)
    if self:get_unit_restrictions()[unitID] == nil then
        self._restrictedUnits[unitID] = false
    end
    return self:get_unit_restrictions()[unitID]
end

--v function(self: RECRUITER_CHARACTER, unitID: string)
function recruiter_character.enforce_unit_restriction(self, unitID)


end

--v function(self: RECRUITER_CHARACTER)
function recruiter_character.enforce_all_restrictions(self)
    for unit, restriction in pairs(self:get_unit_restrictions()) do
        self:enforce_unit_restriction(unit)
    end
end


return {
    new = recruiter_character.new
}