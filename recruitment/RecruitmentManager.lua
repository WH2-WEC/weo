local recruiter_manager = {} --# assume recruiter_manager: RECRUITER_MANAGER

function recruiter_manager.init()
    local self = {}
    setmetatable(self, {
        __index = recruiter_manager,
        __tostring = function() return "RECRUITER_MANAGER" end
    }) --# assume self: RECRUITER_MANAGER
    self._recruiterCharacters = {} --:map<CA_CQI, RECRUITER_CHARACTER>
    self._currentCharacter = nil --:CA_CQI

    self._characterUnitLimits = {} --:map<string, number>
    
    self._unitChecks = {} --:map<string, vector<(function(rm: RECRUITER_MANAGER) --> boolean)>>

    _G.rm = self
end
--v function(self: RECRUITER_MANAGER, text: any) 
function recruiter_manager.log(self, text)

end

local recruiter_character = require("recruitment/RecruiterCharacter")

--v function(self: RECRUITER_MANAGER) --> map<CA_CQI, RECRUITER_CHARACTER>
function recruiter_manager.characters(self)
    return self._recruiterCharacters
end

--v function(self: RECRUITER_MANAGER, cqi: CA_CQI) --> RECRUITER_CHARACTER
function recruiter_manager.new_character(self, cqi)
    local new_char = recruiter_character.new(self, cqi)
    self._recruiterCharacters[cqi] = new_char
    return new_char
end

--v function(self: RECRUITER_MANAGER, cqi: CA_CQI) --> boolean
function recruiter_manager.has_character(self, cqi)
    return not not self:characters()[cqi]
end

--v function(self: RECRUITER_MANAGER, cqi: CA_CQI) --> RECRUITER_CHARACTER
function recruiter_manager.get_character_by_cqi(self, cqi)
    if self:has_character(cqi) then
        return self:characters()[cqi]
    else
        self:log("Requested character with ["..tostring(cqi).."] who does not exist, creating them!")
        return self:new_character(cqi)
    end
end

--v function(self: RECRUITER_MANAGER) --> boolean
function recruiter_manager.has_currently_selected_character(self)
    return not not self._currentCharacter
end

--v function(self: RECRUITER_MANAGER) --> CA_CQI
function recruiter_manager.current_cqi(self)
    return self._currentCharacter
end


--v function(self: RECRUITER_MANAGER) --> RECRUITER_CHARACTER
function recruiter_manager.current_character(self)
    return self:get_character_by_cqi(self:current_cqi())
end

--v function(self: RECRUITER_MANAGER, cqi:CA_CQI)
function recruiter_manager.set_current_character(self, cqi)
    self._currentCharacter = cqi
end


--unit checks framework

--v function(self: RECRUITER_MANAGER) --> map<string, vector<(function(rm: RECRUITER_MANAGER) --> bool)>>
function recruiter_manager.get_unit_checks(self)
    return self._unitChecks
end

--v function(self: RECRUITER_MANAGER, unitID: string) --> vector<(function(rm: RECRUITER_MANAGER) --> bool)>
function recruiter_manager.get_checks_for_unit(self, unitID)
    if self:get_unit_checks()[unitID] == nil then
        self._unitChecks[unitID] = {}
    end
    return self:get_unit_checks()[unitID]
end

--v function(self: RECRUITER_MANAGER, unitID: string, check:(function(rm: RECRUITER_MANAGER) --> bool))
function recruiter_manager.add_check_to_unit(self, unitID, check)
    if self:get_unit_checks()[unitID] == nil then
        self._unitChecks[unitID] = {}
    end
    table.insert(self:get_unit_checks()[unitID], check)
end

--v function(self: RECRUITER_MANAGER, unitID: string) --> boolean
function recruiter_manager.do_checks_for_unit(self, unitID)
    for i = 1, #self:get_checks_for_unit(unitID) do
        if self:get_checks_for_unit(unitID)[i](self) then
            return true
        end
    end
    return false
end

--v function(self: RECRUITER_MANAGER, unitID: string)
function recruiter_manager.check_unit_on_character(self, unitID)
    local restrict = self:do_checks_for_unit(unitID)
    self:current_character():set_unit_restriction(unitID, restrict)
end

--v function(self: RECRUITER_MANAGER)
function recruiter_manager.check_all_units_on_character(self)
    for unitID, _ in pairs(self:get_unit_checks()) do
        self:check_unit_on_character(unitID)
    end
end


--quantity limits

--v function(self: RECRUITER_MANAGER) --> map<string, number>
function recruiter_manager.get_quantity_limits(self)
    return self._characterUnitLimits
end

--v function(self: RECRUITER_MANAGER, unitID: string) --> number
function recruiter_manager.get_quantity_limit_for_unit(self, unitID)
    if self:get_quantity_limits()[unitID] == nil then
        self._characterUnitLimits[unitID] = 999
    end
    return self:get_quantity_limits()[unitID]
end

--v function(self: RECRUITER_MANAGER, unitID: string)
function recruiter_manager.add_quantity_check(self, unitID)
    --we need to see if the count is higher or equal to allowed, then block if so.
    local check = function(rm --: RECRUITER_MANAGER
    ) return rm:current_character():get_unit_count(unitID) >= rm:get_quantity_limit_for_unit(unitID)
    end
    --add this check to the model
    self:add_check_to_unit(unitID, check)
end



--v function(self: RECRUITER_MANAGER, unitID: string, quantity: number) 
function recruiter_manager.add_character_quantity_limit_for_unit(self, unitID, quantity)
    self:log("Registering a character quantity limit for unit ["..unitID.."] and quantity ["..quantity.."] ")
    self._characterUnitLimits[unitID] = quantity
    self:add_quantity_check(unitID)
end







