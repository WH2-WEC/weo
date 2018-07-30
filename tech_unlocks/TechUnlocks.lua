--Log script to text
--v function(text: string | number | boolean | CA_CQI)
local function TULOG(text)
    if not __write_output_to_logfile then
        return;
    end

    local logText = tostring(text)
    local logTimeStamp = os.date("%d, %m %Y %X")
    local popLog = io.open("warhammer_expanded_log.txt","a")
    --# assume logTimeStamp: string
    popLog :write("TU:  [".. logTimeStamp .. "]:  "..logText .. "  \n")
    popLog :flush()
    popLog :close()
end

local tech_unlock = {} --# assume tech_unlock: TECH_UNLOCK


--v function(faction_key: string, tech_key: string, unlock_event: string, condition: function(context: WHATEVER, faction: string) --> boolean)
function tech_unlock.new(faction_key, tech_key, unlock_event, condition)
if cm:get_saved_value("tech_unlocks_"..tech_key) == true then
    TULOG("Not setting up any listener for ["..tech_key.."]; it has already been unlocked!")
    return
end
    cm:lock_technology(faction_key, tech_key)
    core:add_listener(
        "TechUnlocks"..tech_key,
        unlock_event,
        function(context)
           return condition(context, faction_key) 
        end,
        function(context)
            cm:unlock_technology(faction_key, tech_key)
            cm:set_saved_value("tech_unlocks_"..tech_key, true)
        end,
        false)
end
