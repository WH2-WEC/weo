--Log script to text
--v function(text: string | number | boolean | CA_CQI)
local function RCLOG(text)
    if not __write_output_to_logfile then
        return;
    end

    local logText = tostring(text)
    local logTimeStamp = os.date("%d, %m %Y %X")
    local popLog = io.open("warhammer_expanded_log.txt","a")
    --# assume logTimeStamp: string
    popLog :write("LE:  [".. logTimeStamp .. "]:  "..logText .. "  \n")
    popLog :flush()
    popLog :close()
end

--Reset the log at session start
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


--prototype for recruiter_manager
local recruiter_manager = {} --# assume recruiter_manager: RECRUITER_MANAGER

--create a new instance of rm
function recruiter_manager.init()
    local self = {}
    setmetatable(self, {
        __index = recruiter_manager,
        __tostring = function() return "RECRUITER_MANAGER" end
    }) --# assume self: RECRUITER_MANAGER
    self._recruiterCharacters = {} --:map<CA_CQI, RECRUITER_CHARACTER>
    self._currentCharacter = nil --:CA_CQI
    --quantity based limits
    self._characterUnitLimits = {} --:map<string, number>
    --unit groupings membership
    self._unitToGroupNames = {} --:map<string, vector<string>>
    self._groupToUnits = {} --:map<string, vector<string>>
    --unit group quantity limits
    self._groupUnitLimits = {} --:map<string, number>
    --check infrastructure
    self._unitChecks = {} --:map<string, vector<(function(rm: RECRUITER_MANAGER) --> (boolean, string))>>
    --unit weight
    self._unitWeights = {} --:map<string, number>
    --ui
    self._UIGroupNames = {} --:map<string, string>
    self._UIUnitProfiles = {} --:map<string, TOOLTIPIMAGE>
    --place instance in _G. 
    _G.rm = self
end

--log text
--v function(self: RECRUITER_MANAGER, text: any) 
function recruiter_manager.log(self, text)
    RCLOG(tostring(text))
end

--fully reset the model, clearing all stored data.
--v function(self: RECRUITER_MANAGER)
function recruiter_manager.full_reset(self)
    self:log("SCRIPT CALLED TO RESET THE RECRUITER MANAGER!!")
    self._recruiterCharacters = {} 
    self._currentCharacter = nil 
    --quantity based limits
    self._characterUnitLimits = {} 
    --unit groupings membership
    self._unitToGroupNames = {} 
    self._groupToUnits = {} 
    --unit group quantity limits
    self._groupUnitLimits = {} 
    --check infrastructure
    self._unitChecks = {} 
    --unit weight
    self._unitWeights = {} 
    --ui
    self._UIGroupNames = {} 
    --place instance in _G. 
    _G.rm = self
    self:log("RESET COMPLETE")
end



--logs lua errors to a file after this is called.
--v [NO_CHECK] 
--v function (self: RECRUITER_MANAGER)
function recruiter_manager.error_checker(self)
    --Vanish's PCaller
    --All credits to vanish
    --safely call a function
    --v function(func: function) --> any
    function safeCall(func)
        local status, result = pcall(func)
        if not status then
            self:log("********ERROR DETECTED***********")
            self:log(tostring(result))
            self:log(debug.traceback());
            
        end
        return result;
    end
    --pack args
    --v [NO_CHECK] function(...: any)
    function pack2(...) return {n=select('#', ...), ...} end
    --unpack args
    --v [NO_CHECK] function(t: vector<WHATEVER>) --> vector<WHATEVER>
    function unpack2(t) return unpack(t, 1, t.n) end
    
    --wrap a function in safecalls
    --v [NO_CHECK] function(f: function(), argProcessor: function()) --> function()
    function wrapFunction(f, argProcessor)
        return function(...)
            --output("start wrap ");
            local someArguments = pack2(...);
            if argProcessor then
                safeCall(function() argProcessor(someArguments) end)
            end
            local result = pack2(safeCall(function() return f(unpack2( someArguments )) end));
            --for k, v in pairs(result) do
            --    output("Result: " .. tostring(k) .. " value: " .. tostring(v));
            --end
            --output("end wrap ");
            return unpack2(result);
            end
    end
    --wrap all callbacks
    --[[ --untested
    local currentCallBack = cm.callback;
    --v [NO_CHECK] function(cm: any, callback: function(), timer: any, name: any)
    function myCallBack(cm, callback, timer, name)
        currentCallback(cm, wrapFunction(callback), timer, name)
    end
    cm.callback = MyCallBack;
    --]]
    --wrap all listeners
    local currentAddListener = core.add_listener;
    --v [NO_CHECK] function(core: any, listenerName: any, eventName: any, conditionFunc: any, listenerFunc: any, persistent: any)
    function myAddListener(core, listenerName, eventName, conditionFunc, listenerFunc, persistent)
        local wrappedCondition = nil;
        if is_function(conditionFunc) then
            --wrappedCondition =  wrapFunction(conditionFunc, function(arg) output("Callback condition called: " .. listenerName .. ", for event: " .. eventName); end);
            wrappedCondition =  wrapFunction(conditionFunc);
        else
            wrappedCondition = conditionFunc;
        end
        currentAddListener(
            core, listenerName, eventName, wrappedCondition, wrapFunction(listenerFunc), persistent
            --core, listenerName, eventName, wrappedCondition, wrapFunction(listenerFunc, function(arg) output("Callback called: " .. listenerName .. ", for event: " .. eventName); end), persistent
        )
    end
    core.add_listener = myAddListener;

end




--ui utility to get the names of the units in the queue by reading the UI.
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
        RCLOG("Found queued unit ["..QueuedUnitName.."] at ["..index.."] ")
        return QueuedUnitName
    else
        return nil
    end
end
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
-----------RECRUITER CHARACTER OBJECT---------------------

--prototype for recruiter_character
local recruiter_character = {} --# assume recruiter_character: RECRUITER_CHARACTER

--Create a new instance of recruiter character
--v function(manager: RECRUITER_MANAGER,cqi: CA_CQI) --> RECRUITER_CHARACTER
function recruiter_character.new(manager, cqi)
    local self = {}
    setmetatable(self, {
        __index = recruiter_character,
        __tostring = function() return "RECRUITER_CHARACTER" end
    })--# assume self: RECRUITER_CHARACTER
    self._cqi = cqi --stores the cqi identifier of the character
    self._manager = manager  -- stores the associated rm
    self._armyCounts = {} --:map<string, number> --stores the current number of each unit in the army
    self._queueCounts = {} --:map<string, number> --stores the current number of each unit in the queue
    self._restrictedUnits = {} --:map<string, boolean> -- stores the units currently restricted for the character
    self._UIStrings = {} --:map<string, string> --stores the string to explain why a unit is locked.
    self._staleQueueFlag = true --:boolean -- flags for the queue needing to be refreshed entirely.
    self._staleArmyFlag = true --:boolean --flags for the army needing to be refreshed entirely.
    
    return self
end

--return the cqi
--v function(self: RECRUITER_CHARACTER) --> CA_CQI
function recruiter_character.cqi(self)
    return self._cqi
end

--return the rm
--v function(self: RECRUITER_CHARACTER) --> RECRUITER_MANAGER
function recruiter_character.manager(self)
    return self._manager
end

--log text to file.
--v function(self: RECRUITER_CHARACTER, text: any) 
function recruiter_character.log(self, text)
    self:manager():log(text)
end

--get the army counts map
--v function(self: RECRUITER_CHARACTER) --> map<string, number>
function recruiter_character.get_army_counts(self)
    return self._armyCounts
end

--get the queue counts map
--v function(self: RECRUITER_CHARACTER) --> map<string, number>
function recruiter_character.get_queue_counts(self)
    return self._queueCounts
end

--get the restricted units map
--v function(self: RECRUITER_CHARACTER) --> map<string, boolean>
function recruiter_character.get_unit_restrictions(self)
    return self._restrictedUnits
end

--ui--
------

--get the ui strngs map
--v function(self: RECRUITER_CHARACTER) --> map<string, string>
function recruiter_character.get_ui_strings(self)
    return self._UIStrings
end

--v function(self: RECRUITER_CHARACTER, unitID: string) --> string
function recruiter_character.get_ui_string_for_unit(self, unitID)
    if self:get_ui_strings()[unitID] == nil then
        self._UIStrings[unitID] = ""
    end
    return self:get_ui_strings()[unitID]
end

--v function(self: RECRUITER_CHARACTER, unitID: string, UIstring: string)
function recruiter_character.set_ui_string_for_unit(self, unitID, UIstring)
    self._UIStrings[unitID] = UIstring
end


--stale queues and armies--

--returns the stale flag for queue
--v function(self: RECRUITER_CHARACTER) --> boolean
function recruiter_character.is_queue_stale(self)
    return self._staleQueueFlag
end

--returns the stale flag for armies
--v function(self: RECRUITER_CHARACTER) --> boolean
function recruiter_character.is_army_stale(self)
    return self._staleArmyFlag
end

--marks the queue for a refresh
--v function(self: RECRUITER_CHARACTER)
function recruiter_character.set_queue_stale(self)
    self._staleQueueFlag = true
end

--marks the army for a refresh
--v function(self: RECRUITER_CHARACTER)
function recruiter_character.set_army_stale(self)
    self._staleArmyFlag = true
end

--called after the refresh so it doesn't get called repeatedly.
--v function(self: RECRUITER_CHARACTER)
function recruiter_character.set_queue_fresh(self)
    self._staleQueueFlag = false
end

--called after the refresh so it doesn't get called repeatedly.
--v function(self: RECRUITER_CHARACTER)
function recruiter_character.set_army_fresh(self)
    self._staleArmyFlag = false
end

--remove all units from queue
--v function(self: RECRUITER_CHARACTER)
function recruiter_character.wipe_queue(self)
    self:log("wiped Queue for ["..tostring(self:cqi()).."] ")
    --loop through the queue, setting each unit entry to 0
    for unit, _ in pairs(self:get_queue_counts()) do 
        self._queueCounts[unit] = 0
    end
end

--remove all units from the army
--v function(self: RECRUITER_CHARACTER)
function recruiter_character.wipe_army(self)
    self:log("wiped Army for ["..tostring(self:cqi()).."] ")
    --loop through the army, setting each unit entry to 0
    for unit, _ in pairs(self:get_army_counts()) do
        self._armyCounts[unit] = 0
    end
end


--add a unit to the army
--v function(self: RECRUITER_CHARACTER, unitID: string)
function recruiter_character.add_unit_to_army(self, unitID)
    if self._armyCounts[unitID] == nil then
        --if that unit hasn't been used yet, give it a default value.
        self._armyCounts[unitID] = 0 
    end
    self._armyCounts[unitID] = self:get_army_counts()[unitID] + 1;
    self:log("Added unit ["..unitID.."] to the army of ["..tostring(self:cqi()).."]")
end

--remove a unit from the army (used by disband listener)
--v function(self: RECRUITER_CHARACTER, unitID: string)
function recruiter_character.remove_unit_from_army(self, unitID)
    self._armyCounts[unitID] = self:get_army_counts()[unitID] - 1;
    self:log("Removed unit ["..unitID.."] to the army of ["..tostring(self:cqi()).."]")
end

--add a unit to the queue
--v function(self: RECRUITER_CHARACTER, unitID: string)
function recruiter_character.add_unit_to_queue(self, unitID)
    if self._queueCounts[unitID] == nil then
        self._queueCounts[unitID] = 0 
        --if that unit hasn't been used yet, give it a default value.
    end
    self._queueCounts[unitID] = self:get_queue_counts()[unitID] + 1;
    self:log("Added unit ["..unitID.."] to the queue of ["..tostring(self:cqi()).."]")
end

--refresh the army of the character
--v function(self: RECRUITER_CHARACTER)
function recruiter_character.refresh_army(self)
    --remove the old army before starting
    self:wipe_army()
    self:log("Freshening up the army of ["..tostring(self:cqi()).."]")
    --get unit list for that character's force.
    local army = cm:get_character_by_cqi(self:cqi()):military_force():unit_list()
    for i = 0, army:num_items() - 1 do
        local unitID = army:item_at(i):unit_key()
        self:add_unit_to_army(unitID)
    end
    --set army fresh
    self:set_army_fresh()
end


--refresh the queue of the character
--v function(self: RECRUITER_CHARACTER)
function recruiter_character.refresh_queue(self)
    --remove the old queue before we start
    self:wipe_queue() 
    self:log("Freshening up the queue of ["..tostring(self:cqi()).."]")
    --check if the unit panel is open so that we can see the army. If it isn't, the function can abort with a failure message.
    --the queue will be evaluated again next time as we never set the queue fresh
    local unitPanel = find_uicomponent(core:get_ui_root(), "main_units_panel")
    if not unitPanel then
        self:log("Failed to find the main_units_panel UI element while refreshing the queue of ["..tostring(self:cqi()).."] ")
        return
    end
    --UI is written in C++, so we loop from 0
    for i = 0, 18 do
        --grab the unit ID from the queued unit tooltips url.
        local unitID = GetQueuedUnit(i) 
        --if we find a unit successfully, add to queue. Otherwise, abort the loop. 
        if unitID then
            self:add_unit_to_queue(unitID)
        else
            self:log("Found no unit at ["..i.."], ending the refresh queue loop!")
            break
        end
    end
    --set the queue fresh
    self:set_queue_fresh()
end

--get a unit count from the army of the character
--v function(self:RECRUITER_CHARACTER, unitID: string) --> number
function recruiter_character.get_unit_count_in_army(self, unitID)
    if self:get_army_counts()[unitID] == nil then
        --if the unit hasn't been used yet, give it a default value.
        self._armyCounts[unitID] = 0
    end
    return self:get_army_counts()[unitID]
end

--get the unit count from the queue of the character
--v function(self:RECRUITER_CHARACTER, unitID: string) --> number
function recruiter_character.get_unit_count_in_queue(self, unitID)
    if self:get_queue_counts()[unitID] == nil then
        --if the unit hasn't been used yet, give it a default value.
        self._queueCounts[unitID] = 0
    end
    if self:is_queue_stale() then
        --if the queue is stale, we're going to return nothing because the queue we have isn't reliable!
        self:log("get_unit_count_in_queue for called for ["..unitID.."] on character ["..tostring(self:cqi()).."], but the queue is stale!")
        return 0 
    end
    return self:get_queue_counts()[unitID]
end


--checks for stale information, refreshes it, then returns the total count accross both queue and army
--v function(self: RECRUITER_CHARACTER, unitID: string) --> number
function recruiter_character.get_unit_count(self, unitID)
    --if our queue is stale, ask for a refresh.
    if self:is_queue_stale() then
        self:refresh_queue()
    end
    --will not provide any information about the queue if the queue is stale and the queue refresh fails.
    local queue_count = self:get_unit_count_in_queue(unitID)
    --if the army is stale, ask for a refresh
    if self:is_army_stale() then
        self:refresh_army() 
    end
    local army_count = self:get_unit_count_in_army(unitID)
    --return the sum of both counts
    return army_count + queue_count
end

--set a unit to be restricted for a character
--v function(self: RECRUITER_CHARACTER, unitID: string, restricted: boolean)
function recruiter_character.set_unit_restriction(self, unitID, restricted)
    self:log("Set the unit restriction on character with cqi ["..tostring(self:cqi()).."] to ["..tostring(restricted).."] for unit ["..unitID.."]")
    self._restrictedUnits[unitID] = restricted
end

--return whether a unit is restricted for a character
--v function(self: RECRUITER_CHARACTER, unitID: string) --> boolean
function recruiter_character.is_unit_restricted(self, unitID)
    if self:get_unit_restrictions()[unitID] == nil then
        --if the unit hasn't been accessed yet, give it a default value
        self._restrictedUnits[unitID] = false
    end
    self:log("is unit restricted returning ["..tostring(self:get_unit_restrictions()[unitID]).."] for unit ["..unitID.."]")
    return self:get_unit_restrictions()[unitID]
end

--enforce the restriction for a specific unit onto the UI.
--v function(self: RECRUITER_CHARACTER, unitID: string)
function recruiter_character.enforce_unit_restriction(self, unitID)
    self:log("Applying Restrictions for character ["..tostring(self:cqi()).."] and unit ["..unitID.."] ")
    --get the local recruitment panel
    local localRecruitmentTable = {"units_panel", "main_units_panel", "recruitment_docker", "recruitment_options", "recruitment_listbox", "local1", "unit_list", "listview", "list_clip", "list_box"};
    local localUnitList = find_uicomponent_from_table(core:get_ui_root(), localRecruitmentTable);
    --if we got the panel, proceed
    if is_uicomponent(localUnitList) then
        --attach the UI suffix onto the unit name to get the name of the recruit button.
        local unit_component_ID = unitID.."_recruitable"
        --find the unit card using that name
        local unitCard = find_uicomponent(localUnitList, unit_component_ID)
        --if we got the unit card, proceed
        if is_uicomponent(unitCard) then
            --if the unit is restricted, set the card to be unclickable.
            if self:is_unit_restricted(unitID) == true then
                self:log("Locking Unit Card ["..unit_component_ID.."]")
                unitCard:SetInteractive(false)
                -- unitCard:SetVisible(false)
                local lockedOverlay = find_uicomponent(unitCard, "disabled_script");
                if not not lockedOverlay then
                    lockedOverlay:SetVisible(true)
                    lockedOverlay:SetImage("ui/custom/recruitment_controls/locked_unit.png")
                    lockedOverlay:SetTooltipText(self:get_ui_string_for_unit(unitID))
                    lockedOverlay:SetCanResizeHeight(true)
                    lockedOverlay:SetCanResizeWidth(true)
                    lockedOverlay:Resize(72, 89)
                    lockedOverlay:SetCanResizeHeight(false)
                    lockedOverlay:SetCanResizeWidth(false)
                end
                
                --unitCard:SetVisible(false)
            else
            --otherwise, set the card clickable
                self:log("Unlocking! Unit Card ["..unit_component_ID.."]")
                unitCard:SetInteractive(true)
                -- unitCard:SetVisible(true)
                local lockedOverlay = find_uicomponent(unitCard, "disabled_script");
                if not not lockedOverlay then
                    unitCard:SetTooltipText(self:get_ui_string_for_unit(unitID))
                    lockedOverlay:SetVisible(false)
                end
            end
        else 
            --if we couldn't find the card, warn the log. 
            self:log("Unit Card isn't a component!")
        end
    else
        --if we couldn't find the panel, warn the log.
        self:log("WARNING: Could not find the component for the unit list!. Is the panel closed?")
    end
    --repeat all operations, except for the global recruitment list. 
    local globalRecruitmentTable = {"units_panel", "main_units_panel", "recruitment_docker", "recruitment_options", "recruitment_listbox", "global", "unit_list", "listview", "list_clip", "list_box"};
    local globalUnitList = find_uicomponent_from_table(core:get_ui_root(), globalRecruitmentTable);
    if is_uicomponent(globalUnitList) then
        local unit_component_ID = unitID.."_recruitable"
        local unitCard = find_uicomponent(globalUnitList, unit_component_ID);	
        if is_uicomponent(unitCard) then
            if self:is_unit_restricted(unitID) then
                self:log("Locking Unit Card ["..unit_component_ID.."]")
                unitCard:SetInteractive(false)
                local lockedOverlay = find_uicomponent(unitCard, "disabled_script");
                if not not lockedOverlay then
                    lockedOverlay:SetVisible(true)
                    lockedOverlay:SetImage("ui/custom/recruitment_controls/locked_unit.png")
                    lockedOverlay:SetTooltipText(self:get_ui_string_for_unit(unitID))
                    lockedOverlay:SetCanResizeHeight(true)
                    lockedOverlay:SetCanResizeWidth(true)
                    lockedOverlay:Resize(72, 89)
                    lockedOverlay:SetCanResizeHeight(false)
                    lockedOverlay:SetCanResizeWidth(false)
                end
                --  unitCard:SetVisible(false)
            else
                self:log("Unlocking! Unit Card ["..unit_component_ID.."]")
                unitCard:SetInteractive(true)
                -- unitCard:SetVisible(true)
                local lockedOverlay = find_uicomponent(unitCard, "disabled_script");
                if not not lockedOverlay then
                    unitCard:SetTooltipText(self:get_ui_string_for_unit(unitID))
                    lockedOverlay:SetVisible(false)
                end
            end
        else 
            self:log("Unit Card isn't a component!")
        end
    else
        self:log("WARNING: Could not find the component for the global recruitment list!. Is the panel closed? Does the Player not have global recruitment?")
    end 
    cm:steal_user_input(false);
end

--loop through each unit which has a restriction entry, and enforce those entries on the UI. 
--v function(self: RECRUITER_CHARACTER)
function recruiter_character.enforce_all_restrictions(self)
    for unit, _ in pairs(self:get_unit_restrictions()) do
        self:enforce_unit_restriction(unit)
    end
end

--------------------END OF SUBOBJECT----------------------
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
-- ----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------


--get all characters in the rm
--v function(self: RECRUITER_MANAGER) --> map<CA_CQI, RECRUITER_CHARACTER>
function recruiter_manager.characters(self)
    return self._recruiterCharacters
end

--create and return a new character in the rm
--v function(self: RECRUITER_MANAGER, cqi: CA_CQI) --> RECRUITER_CHARACTER
function recruiter_manager.new_character(self, cqi)
    local new_char = recruiter_character.new(self, cqi)
    self._recruiterCharacters[cqi] = new_char
    return new_char
end

--return whether a character exists in the rm
--v function(self: RECRUITER_MANAGER, cqi: CA_CQI) --> boolean
function recruiter_manager.has_character(self, cqi)
    return not not self:characters()[cqi]
end

--get a character by cqi from the rm
--v function(self: RECRUITER_MANAGER, cqi: CA_CQI) --> RECRUITER_CHARACTER
function recruiter_manager.get_character_by_cqi(self, cqi)
    if self:has_character(cqi) then
        --if we already have that character, return it.
        return self:characters()[cqi]
    else
        --otherwise, return a new character
        self:log("Requested character with ["..tostring(cqi).."] who does not exist, creating them!")
        return self:new_character(cqi)
    end
end

--return whether the current character has ever been set
--v function(self: RECRUITER_MANAGER) --> boolean
function recruiter_manager.has_currently_selected_character(self)
    return not not self._currentCharacter
end

--return the cqi of the current character
--v function(self: RECRUITER_MANAGER) --> CA_CQI
function recruiter_manager.current_cqi(self)
    return self._currentCharacter
end

--return the current character's object
--v function(self: RECRUITER_MANAGER) --> RECRUITER_CHARACTER
function recruiter_manager.current_character(self)
    return self:get_character_by_cqi(self:current_cqi())
end

--set the current character by CQI
--v function(self: RECRUITER_MANAGER, cqi:CA_CQI)
function recruiter_manager.set_current_character(self, cqi)
    self:log("Set the current character to cqi ["..tostring(cqi).."]")
    self._currentCharacter = cqi
end

--unit grouping assignments--

-----------------------------

--get the map of units to their list of groups
--v function(self: RECRUITER_MANAGER) --> map<string, vector<string>>
function recruiter_manager.get_unit_group_names(self)
    return self._unitToGroupNames
end

--get the map of groups to their list of units
--v function(self: RECRUITER_MANAGER) --> map<string, vector<string>>
function recruiter_manager.get_unit_groups(self)
    return self._groupToUnits
end

--get the list of groups for a specific unit
--v function(self: RECRUITER_MANAGER, unitID: string) -->vector<string>
function recruiter_manager.get_groups_for_unit(self, unitID)
    if self:get_unit_group_names()[unitID] == nil then
        --if the unit has no groups, give it a default blank list
        self._unitToGroupNames[unitID] = {}
    end
    return self:get_unit_group_names()[unitID]
end

--get the list of units for a specific group
--v function(self: RECRUITER_MANAGER, groupID: string) --> vector<string>
function recruiter_manager.get_units_in_group(self, groupID)
    if self:get_unit_groups()[groupID] == nil then
        --if the group hasn't been used at all, give it a default blank list.
        self._groupToUnits[groupID] = {}
    end
    return self:get_unit_groups()[groupID]
end

--attach a group to a unit
--v function(self: RECRUITER_MANAGER, unitID: string, groupID: string)
function recruiter_manager.give_unit_group(self, unitID, groupID)
    if self:get_groups_for_unit(unitID) == nil then
        --if we haven't attached any groups to this unit before, we need to initialize the list
        self._unitToGroupNames[unitID] = {}
    end
    table.insert(self:get_groups_for_unit(unitID), groupID) 
end

--put a unit into a group list
--v function(self: RECRUITER_MANAGER, unitID: string, groupID: string)
function recruiter_manager.place_unit_in_group(self, unitID, groupID)
    if self:get_units_in_group(groupID) == nil then
        --if the group is new, we need to initialize it's list of units.
        self:log("Creating a new group ["..groupID.."]")
        self._groupToUnits[groupID] = {}
    end
    table.insert(self:get_units_in_group(groupID), unitID)
end

--group ui names--
------------------

--get the map of groups to UI names
--v function(self: RECRUITER_MANAGER) --> map<string, string>
function recruiter_manager.get_group_ui_names(self)
    return self._UIGroupNames
end

--get a specific UI name
--v function(self: RECRUITER_MANAGER, groupID: string) --> string
function recruiter_manager.get_ui_name_for_group(self, groupID)
    if self:get_group_ui_names()[groupID] == nil then
        self._UIGroupNames[groupID] = groupID
    end
    return self:get_group_ui_names()[groupID]
end

--set the UI name for a group
--v function(self: RECRUITER_MANAGER, groupID: string, UIname: string)
function recruiter_manager.set_ui_name_for_group(self, groupID, UIname)
    self._UIGroupNames[groupID] = UIname
end


--unit ui profiles--
------------------

--get the map of units to their UI
--v function(self: RECRUITER_MANAGER) --> map<string, TOOLTIPIMAGE>
function recruiter_manager.get_unit_ui_profiles(self)
    return self._UIUnitProfiles
end

--does a unit have a UI image?
--v function(self: RECRUITER_MANAGER, unitID: string) --> boolean
function recruiter_manager.unit_has_ui_image(self, unitID) 
    return not not self:get_unit_ui_profiles()[unitID]
end

--set the UI profile for a unit.
--v function(self: RECRUITER_MANAGER, unitID: string, UIprofile: TOOLTIPIMAGE)
function recruiter_manager.set_ui_profile_for_unit(self, unitID, UIprofile)
    self._UIUnitProfiles[unitID] = UIprofile
end

--get the UI profile for a unit.
--v function(self: RECRUITER_MANAGER, unitID: string) --> TOOLTIPIMAGE
function recruiter_manager.get_ui_profile_for_unit(self, unitID)
    return self:get_unit_ui_profiles()[unitID]
end
--unit weights--
----------------

--get the map of units to their weights
--v function(self: RECRUITER_MANAGER) --> map<string, number>
function recruiter_manager.get_unit_weights(self)
    return self._unitWeights
end

--get the weight of a specific unit
--v function(self: RECRUITER_MANAGER, unitID: string) --> number
function recruiter_manager.get_weight_for_unit(self, unitID)
    if self._unitWeights[unitID] == nil then
        self._unitWeights[unitID] = 1
    end
    return self._unitWeights[unitID]
end

--set the weight for a unit within their groups.
--publically available function
--v function(self: RECRUITER_MANAGER, unitID: string, weight: number)
function recruiter_manager.set_weight_for_unit(self, unitID, weight)
    if not is_string(unitID) then
        self:log("set_weight_for_unit called but the supplied unitID is not a string")
        return
    end
    if not is_number(weight) then
        self:log("set_weight_for_unit but the supplied weight was not a number!")
        return
    end
    self._unitWeights[unitID] = weight
end



--unit checks framework--
-------------------------

--get the map of units to their list of checks
--v function(self: RECRUITER_MANAGER) --> map<string, vector<(function(rm: RECRUITER_MANAGER) --> (boolean, string))>>
function recruiter_manager.get_unit_checks(self)
    return self._unitChecks
end

--get the list of checks for a specific unit
--v function(self: RECRUITER_MANAGER, unitID: string) --> vector<(function(rm: RECRUITER_MANAGER) --> (boolean, string))>
function recruiter_manager.get_checks_for_unit(self, unitID)
    if self:get_unit_checks()[unitID] == nil then
        self._unitChecks[unitID] = {}
    end
    return self:get_unit_checks()[unitID]
end

--add a function to check a specific unit
--v function(self: RECRUITER_MANAGER, unitID: string, check:(function(rm: RECRUITER_MANAGER) --> (boolean, string)))
function recruiter_manager.add_check_to_unit(self, unitID, check)
    if self:get_unit_checks()[unitID] == nil then
        --if the unit doesn't have any checks yet, we need to initialize the list
        self._unitChecks[unitID] = {}
    end
    table.insert(self:get_unit_checks()[unitID], check)
end

--carry out the checking functions for a unit
--v function(self: RECRUITER_MANAGER, unitID: string) --> (boolean, string)
function recruiter_manager.do_checks_for_unit(self, unitID)
    self:log("Doing checks for ["..unitID.."] ")
    --start looping through the list of checks for the unit. 
    --we want to mimic doing an 'or' statement except for a vector: 
    --if any condition on the list is true this function returns true
    for i = 1, #self:get_checks_for_unit(unitID) do
        local result, UIstring = self:get_checks_for_unit(unitID)[i](self)
        if result then
            --if our check returns true, end the function and return that true
            self:log("A check resulted in a restriction for ["..unitID.."]")
            return true, UIstring
        end
    end
    --if no checks succeeded, return the false
    self:log("All checks cleared with no restriction for ["..unitID.."]")
    return false, ""
end

--run checks for a unit and set the restriction.
--A smaller version of the check_unit_on_character function that is used in loops to prevent infinite looping or wasted actions.
--v function(self: RECRUITER_MANAGER, unitID: string)
function recruiter_manager.check_unit_on_individual_character_for_loop(self, unitID)
    self:log("Checking unit ["..unitID.."] on currently selected character")
    local restrict, UIstring = self:do_checks_for_unit(unitID)
    self:current_character():set_unit_restriction(unitID, restrict)
    self:current_character():set_ui_string_for_unit(unitID, UIstring)
end


--the full verbose version of checking an indivual unit and their groups.
--v function(self: RECRUITER_MANAGER, unitID: string)
function recruiter_manager.check_unit_on_character(self, unitID)
    self:log("Checking unit ["..unitID.."] on currently selected character")
    local restrict, UIstring = self:do_checks_for_unit(unitID)
    self:current_character():set_unit_restriction(unitID, restrict)
    self:current_character():set_ui_string_for_unit(unitID, UIstring)
    self:current_character():enforce_unit_restriction(unitID)
    --for each group that the unit belongs to
    for i = 1, #self:get_groups_for_unit(unitID) do
        --loop through each unit in each of those groups
        for j = 1, #self:get_units_in_group(self:get_groups_for_unit(unitID)[i]) do
            --we can ignore this unit, since we already checked it.
            if not self:get_units_in_group(self:get_groups_for_unit(unitID)[i])[j] == unitID then
                --check those units individually
                self:check_unit_on_individual_character_for_loop(self:get_units_in_group(self:get_groups_for_unit(unitID)[i])[j])
                --enforce their restrictions.
                self:current_character():enforce_unit_restriction(unitID)
            end
        end
    end
end

--checks every unit which has a check on the current character
--v function(self: RECRUITER_MANAGER)
function recruiter_manager.check_all_units_on_character(self)
    self:log("Checking all units with checks for currently selected character")
    --if a unit doesn't have any checks, it must have no limits and therefore be irrelevant. 
    --this loop will catch all useful units. 
    for unitID, _ in pairs(self:get_unit_checks()) do
        self:check_unit_on_individual_character_for_loop(unitID)
    end
    --enforce the restrictions for the units we just checked. 
    self:current_character():enforce_all_restrictions()
end

--group quantity limits--
-------------------------

--get the map of groups to their quantity limits
--v function(self: RECRUITER_MANAGER) --> map<string, number>
function recruiter_manager.get_group_quantity_limits(self)
    return self._groupUnitLimits
end

--get the quantity limit of a specific group
--v function(self: RECRUITER_MANAGER, groupID: string) -->number
function recruiter_manager.get_quantity_limit_for_group(self,groupID)
    if self:get_group_quantity_limits()[groupID] == nil then
        --if the group doesn't have a quantity set, set it to 999.
        --this won't waste time as without a checker function, this group won't factor into standard operations. 
        self._groupUnitLimits[groupID] = 999
    end
    return self:get_group_quantity_limits()[groupID]
end

--add a checking function to a group for their quantity cap.
--v function(self: RECRUITER_MANAGER, groupID: string)
function recruiter_manager.add_group_check(self, groupID)
    --define our check function
    local check = function(rm --:RECRUITER_MANAGER
    )
        --declare total
        local total = 0 --:number
        --for each unit in the group, count that unit and add to total
        for i = 1, #rm:get_units_in_group(groupID) do
            total = total + (rm:current_character():get_unit_count(rm:get_units_in_group(groupID)[i]))*(rm:get_weight_for_unit(rm:get_units_in_group(groupID)[i]))
        end
        --determine whether the total is above or equal to the group quantity limit
        local result = total >= rm:get_quantity_limit_for_group(groupID)
        rm:log("Checking quantity restriction for ["..groupID.."] resulted in ["..tostring(result).."]")
        --return the result
        return result, "This character already has the maximum number of "..rm:get_ui_name_for_group(groupID).." units. ("..rm:get_quantity_limit_for_group(groupID)..")"
    end
    --add the check to every unit in the group
    for i = 1, #self:get_units_in_group(groupID) do
        self:add_check_to_unit(self:get_units_in_group(groupID)[i], check)
    end
    --note that if a unit isn't in the group at the time quantity is set, it won't work!
end


--place a unit into a group, creating the group if necessary.
--publically available function
--v function(self: RECRUITER_MANAGER, unitID: string, groupID: string)
function recruiter_manager.add_unit_to_group(self, unitID, groupID)
    --check for errors in API functions
    if not (is_string(unitID) and is_string(groupID)) then
        self:log("ERROR: add_unit_to_group called but unitID and groupID must be a string!")
        return
    end
    --put the unit in the group
    self:place_unit_in_group(unitID, groupID)
    --assign the group to the unit
    self:give_unit_group(unitID, groupID)
     --the reason for this double tracking is to have a fast way to know what groups a unit is relevant to when checking.
    self:log("Added unit ["..unitID.."] to group ["..groupID.."]")
end

--add a quantity limit to the group. Must be called after all units are in the group already
--publically available function
--v function(self: RECRUITER_MANAGER, groupID: string, quantity: number)
function recruiter_manager.add_character_quantity_limit_for_group(self, groupID, quantity)
    --check for errors in API functions
    if not is_string(groupID) then
        self:log("add_character_quantity_limit_for_group called but the provided groupID is not a string!")
        return
    end
    if not is_number(quantity) then
        self:log("add_character_quantity_limit_for_group called but the provided quantity is not a number!")
        return
    end
    self:log("registering a limit for group ["..groupID.."] of ["..quantity.."]")
    --set the quantity limit
    self._groupUnitLimits[groupID] = quantity
    --add the necessary check
    self:add_group_check(groupID)
end


--quantity limits--
-------------------

--get the map of units to their limits
--v function(self: RECRUITER_MANAGER) --> map<string, number>
function recruiter_manager.get_quantity_limits(self)
    return self._characterUnitLimits
end

--get the limit of a specific unit
--v function(self: RECRUITER_MANAGER, unitID: string) --> number
function recruiter_manager.get_quantity_limit_for_unit(self, unitID)
    if self:get_quantity_limits()[unitID] == nil then
        --if the unit hasn't been used yet, set their quantity to 999.
        --this won't waste time because without a check added to their unit, they won't factor into standard operation.
        self._characterUnitLimits[unitID] = 999
    end
    return self:get_quantity_limits()[unitID]
end

--v function(self: RECRUITER_MANAGER, unitID: string)
function recruiter_manager.add_quantity_check(self, unitID)
    --we need to see if the count is higher or equal to allowed, then block if so.
    local check = function(rm --: RECRUITER_MANAGER
    ) 
    --see if the count for this unit is higher or equal to the quantity limit
    local result = rm:current_character():get_unit_count(unitID) >= rm:get_quantity_limit_for_unit(unitID)
    --return the result
    rm:log("Checking quantity restriction for ["..unitID.."] resulted in ["..tostring(result).."]")
    return result, "This character already has the maximum number of this unit ("..rm:get_quantity_limit_for_unit(unitID)..")"
    end
    --add this check to the model
    self:add_check_to_unit(unitID, check)
end


--public function
--v function(self: RECRUITER_MANAGER, unitID: string, quantity: number) 
function recruiter_manager.add_character_quantity_limit_for_unit(self, unitID, quantity)
    --check for errors in API functions.
    if not is_string(unitID) then
        self:log("ERROR: add_character_quantity_limit_for_unit called but the unitID was not a string!")
        return
    end
    if not is_number(quantity) then
        self:log("ERROR: add_character_quantity_limit_for_unit but the quantity was not an integer!")
        return
    end
    self:log("Registering a character quantity limit for unit ["..unitID.."] and quantity ["..quantity.."] ")
    --set the quantity limit
    self._characterUnitLimits[unitID] = quantity
    --add the checker function
    self:add_quantity_check(unitID)
end



--initialize the rm 
recruiter_manager.init()


