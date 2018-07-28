
--Log script to text
--v function(text: string | number | boolean | CA_CQI)
local function IEMLOG(text)
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
local function IEMSESSIONLOG()
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
IEMSESSIONLOG()


--prototype for iem
local imperium_effects_manager = {} --# assume imperium_effects_manager: IMPERIUM_EFFECTS_MANAGER

--instantiate a new iem object
--v function() 
function imperium_effects_manager.init()
    local self = {}
    setmetatable(self, {
        __index = imperium_effects_manager,
        __tostring = function() return "IMPERIUM_EFFECTS_MANAGER" end
    })
    --# assume self: IMPERIUM_EFFECTS_MANAGER

    self._trackedFactions = {} --:map<string, boolean>
    self._imperiumEffects = {} --:map<string, map<number, string>>
    self._imperiumCallbacks = {} --:map<string, map<number, function()>>


    _G.iem = self

end

--tunnel to log
--v function(self: IMPERIUM_EFFECTS_MANAGER, text: any) 
function imperium_effects_manager.log(self, text)
    IEMLOG(tostring(text))
end

--checks if a faction is tracked
--v function(self: IMPERIUM_EFFECTS_MANAGER, faction_key: string) --> boolean
function imperium_effects_manager.has_faction(self, faction_key)
    return not not self._trackedFactions[faction_key]
end


--checks if we have an effect for a faction
--v function(self: IMPERIUM_EFFECTS_MANAGER, faction_key: string, imperium_level: number) --> boolean
function imperium_effects_manager.has_effect_for_faction_at_imperium(self, faction_key, imperium_level) 
    if self._imperiumEffects[faction_key] == nil then
        self._imperiumEffects[faction_key] = {}
    end
    return not not self._imperiumEffects[faction_key][imperium_level]
end


--checks if we have a callback for a faction
--v function(self: IMPERIUM_EFFECTS_MANAGER, faction_key: string, imperium_level: number) --> boolean
function imperium_effects_manager.has_callback_for_faction_at_imperium(self, faction_key, imperium_level)
    if self._imperiumCallbacks[faction_key] == nil then
        self._imperiumCallbacks[faction_key] = {}
    end
    return not not self._imperiumCallbacks[faction_key][imperium_level]
end

--gets the effect for a faction at an imperium level
--v function(self: IMPERIUM_EFFECTS_MANAGER, faction_key: string, imperium_level: number) --> string
function imperium_effects_manager.get_effect_for_faction_at_imperium(self, faction_key, imperium_level) 
    if self._imperiumEffects[faction_key] == nil then
        self._imperiumEffects[faction_key] = {}
    end
    return self._imperiumEffects[faction_key][imperium_level]
end



--triggers the function for a faction at their imperium level
--v function(self: IMPERIUM_EFFECTS_MANAGER, faction_key: string, imperium_level: number)
function imperium_effects_manager.do_callback_for_faction_at_imperium(self, faction_key, imperium_level)
    if self._imperiumCallbacks[faction_key] == nil then
        self._imperiumCallbacks[faction_key] = {}
    end
    if self._imperiumCallbacks[faction_key][imperium_level] == nil then
        return
    end
    if cm:get_saved_value("imperium_callbacks_"..faction_key..imperium_level.."_occured") == true then
        self:log("Callback for Imperium Level ["..imperium_level.."] already occured")
        return
    end
    self._imperiumCallbacks[faction_key][imperium_level]()  
    cm:set_saved_value("imperium_callbacks_"..faction_key..imperium_level.."_occured", true)
end

--adds a faction to be tracked.
--v function(self: IMPERIUM_EFFECTS_MANAGER, faction_key: string) 
function imperium_effects_manager.track_faction(self, faction_key)
    self._trackedFactions[faction_key] = true
    if self._imperiumEffects[faction_key] == nil then
        self._imperiumEffects[faction_key] = {}
    end
    if self._imperiumCallbacks[faction_key] == nil then
        self._imperiumCallbacks[faction_key] = {}
    end
end


--adds a bundle to that faction at that imperium level
--v function(self: IMPERIUM_EFFECTS_MANAGER, faction_key: string, imperium_level: number, effect_bundle: string)
function imperium_effects_manager.add_imperium_effect_for_faction_at_level(self, faction_key, imperium_level, effect_bundle)
    if not self:has_faction(faction_key) then
        self:log("The Imperium effects manager does not have this faction! Track it with iem:track_faction() before calling this function!")
        return
    end
    self._imperiumEffects[faction_key][imperium_level] = effect_bundle
end

--adds a callback to that faction at that imperium level
--v function(self: IMPERIUM_EFFECTS_MANAGER,  faction_key: string, imperium_level: number, callback: function()  )
function imperium_effects_manager.add_imperium_callback_for_faction_at_level(self, faction_key, imperium_level, callback)
    if not is_function(callback) then
        self:log("ERROR: Tried to add a non function callback to a faction imperium level!!")
        return
    end
    if not self:has_faction(faction_key) then
        self:log("The Imperium effects manager does not have this faction! Track it with iem:track_faction() before calling this function!")
        return
    end
    if cm:get_saved_value("imperium_callbacks_"..faction_key..imperium_level.."_occured") == true then
        self:log("already triggered imperium callback for ["..faction_key.."] at level ["..imperium_level.."], refusing addition of another callback")
        return
    end
    self._imperiumCallbacks[faction_key][imperium_level] = callback
end






imperium_effects_manager.init()




