--Log script to text
--v function(text: string | number | boolean | CA_CQI)
local function RCLOG(text)
    local ftext = "GEOPOLITICS" 

    if not __write_output_to_logfile then
        return;
    end

    local logText = tostring(text)
    local logContext = tostring(ftext)
    local logTimeStamp = os.date("%d, %m %Y %X")
    local popLog = io.open("warhammer_expanded_log.txt","a")
    --# assume logTimeStamp: string
    popLog :write("LE:  [".. logTimeStamp .. "]:  "..logText .. "  \n")
    popLog :flush()
    popLog :close()
end

--v function()
local function RCSESSIONLOG()
    if not __write_output_to_logfile then
        return;
    end
    local logTimeStamp = os.date("%d, %m %Y %X")
    --# assume logTimeStamp: string

    local popLog = io.open("warhammer_expanded_log.txt","w+")
    popLog :write("NEW LOG ["..logTimeStamp.."] \n")
    popLog :flush()
    popLog :close() 
end
RCSESSIONLOG()



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
    for unit, _ in pairs(self:get_queue_counts()) do
        self._queueCounts[unit] = 0
    end
end

--v function(self: RECRUITER_CHARACTER)
function recruiter_character.wipe_army(self)
    for unit, _ in pairs(self:get_army_counts()) do
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
    self:log("Applying Restrictions for character ["..tostring(self:cqi()).."] and unit ["..unitID.."] ")
    local localRecruitmentTable = {"units_panel", "main_units_panel", "recruitment_docker", "recruitment_options", "recruitment_listbox", "local1", "unit_list", "listview", "list_clip", "list_box"};
    local localUnitList = find_uicomponent_from_table(core:get_ui_root(), localRecruitmentTable);
    if is_uicomponent(localUnitList) then
        local unitCard = find_uicomponent(localUnitList, unitID);	
        if is_uicomponent(unitCard) then
            if self:is_unit_restricted(unitID) == true then
                self:log("Locking Unit Card ["..unitID.."]")
                unitCard:SetInteractive(false)
                --unitCard:SetVisible(false)
            else
                self:log("Unlocking! Unit Card ["..unitID.."]")
                unitCard:SetInteractive(true)
                -- unitCard:SetVisible(true)
            end
        else 
            self:log("Unit Card isn't a component!")
        end
    else
        self:log("WARNING: Could not find the component for the unit list!. Is the panel closed?")
    end

    local globalRecruitmentTable = {"units_panel", "main_units_panel", "recruitment_docker", "recruitment_options", "recruitment_listbox", "global", "unit_list", "listview", "list_clip", "list_box"};
    local globalUnitList = find_uicomponent_from_table(core:get_ui_root(), globalRecruitmentTable);
    if is_uicomponent(globalUnitList) then
        local unitCard = find_uicomponent(globalUnitList, unitID);	
        if is_uicomponent(unitCard) then
            if self:is_unit_restricted(unitID) then
                self:log("Locking Unit Card ["..unitID.."]")
                unitCard:SetInteractive(false)
                --  unitCard:SetVisible(false)
            else
                self:log("Unlocking! Unit Card ["..unitID.."]")
                unitCard:SetInteractive(true)
                -- unitCard:SetVisible(true)
            end
        else 
            self:log("Unit Card isn't a component!")
        end
    else
        self:log("WARNING: Could not find the component for the global recruitment list!. Is the panel closed? Does the Player not have global recruitment?")
    end 

end

--v function(self: RECRUITER_CHARACTER)
function recruiter_character.enforce_all_restrictions(self)
    for unit, _ in pairs(self:get_unit_restrictions()) do
        self:enforce_unit_restriction(unit)
    end
end



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




recruiter_manager.init()


