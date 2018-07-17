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


--v function(self: RECRUITER_CHARACTER, unitID: string)
function recruiter_character.add_unit_to_army(self, unitID)
    if self:get_army_counts()[unitID] == nil then
        self:get_army_counts()[unitID] = 0 
    end
    self._armyCounts[unitID] = self:get_army_counts()[unitID] + 1;
end

--v function(self: RECRUITER_CHARACTER, unitID: string)
function recruiter_character.add_unit_to_queue(self, unitID)
    if self:get_queue_counts()[unitID] == nil then
        self:get_queue_counts()[unitID] = 0 
    end
    self._queueCounts[unitID] = self:get_queue_counts()[unitID] + 1;
end

--v function(self: RECRUITER_CHARACTER)
function recruiter_character.refresh_army(self)
--TODO
self:set_army_fresh()
end

--v function(self: RECRUITER_CHARACTER)
function recruiter_character.refresh_queue(self)
--TODO
self:set_queue_fresh()
end