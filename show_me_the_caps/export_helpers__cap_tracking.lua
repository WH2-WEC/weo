local ct = _G.ct
local rm = _G.rm


--v function(faction: CA_FACTION)
local function CapTrackTurnStart(faction)
    --first, refresh buildings for the faction
    local region_list = faction:region_list()
    for i = 0, region_list:num_items() - 1 do
        local region = region_list:item_at(i)
        if not region:settlement():is_null_interface() then
            ct:get_region(region:name()):evaluate_buildings(region:settlement():slot_list())
            -- add each buildings cap contributions for every unit
            for building, _ in pairs(ct:get_region(region:name())._buildings) do
                for unit, contribution in pairs(ct:get_building(building)._unitEffects) do
                    local ct_fact = ct:get_faction(faction:name())
                    if ct_fact._buildingCapBonus[unit] == nil then
                        ct_fact._buildingCapBonus[unit] = 0
                    end
                    ct_fact._buildingCapBonus[unit] = ct_fact._buildingCapBonus[unit] + contribution
                end
            end
        end
    end
    --next, evaluate how many units the factions have
    ct:get_faction(faction:name()):evaluate_current_values(faction:character_list())
end

--v function(faction: CA_FACTION)
local function CapTrackGetQueueSizes(faction)
    local ct_fact = ct:get_faction(faction:name())
    ct_fact._queueCounts = {}
    for cqi, RecruiterCharacter in pairs(rm._recruiterCharacters) do
        if cm:get_character_by_cqi(cqi):faction():name() == faction:name() then
            for unit, quantity in pairs(RecruiterCharacter:get_queue_counts()) do
                if ct_fact._queueCounts[unit] == nil then
                    ct_fact._queueCounts[unit] = 0
                end
                ct_fact._queueCounts[unit] = ct_fact._queueCounts[unit] + quantity
            end
        end
    end
end




core:add_listener(
    "FactionTurnStartCapTracking",
    "FactionTurnStart",
    function(context)
        return context:faction():is_human()
    end,
    function(context)
        CapTrackTurnStart(context:faction())
    end,
    true
)


events.FirstTickAfterWorldCreated[#events.FirstTickAfterWorldCreated+1] = function()
    local factions = cm:get_human_factions()
    for i = 1, #factions do
        CapTrackTurnStart(cm:get_faction(factions[i]))
    end
end