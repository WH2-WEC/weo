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
    
    self._unitChecks = {} --:map<string, vector<(function(rc: RECRUITER_CHARACTER) --> boolean)>>

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

--v function(self: RECRUITER_MANAGER, unitID: string) 
function recruiter_manager.add_character_quantity_limit_for_unit(self, unitID)

end







