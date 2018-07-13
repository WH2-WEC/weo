cm = get_cm(); events = get_events(); gpm = _G.gpm;


core:add_listener(
    "GeopoliticsTurnStart",
    "FactionTurnStart",
    true,
    function(context)
        local faction_object = context:faction() --:CA_FACTION
        gpm:log("Faction ["..faction_object:name().."] is starting their turn! ")
        local geo_faction = gpm:get_faction(faction_object:name())
        if geo_faction:has_region_changed() then
            gpm:assemble_obtained_properties_for_faction(faction_object)
        end
        gpm:evaluate_all_relations_for_faction(faction_object)
        gpm:apply_bundles_for(faction_object:name())
        gpm:log("Finished Evaluating Faction ["..faction_object:name().."] ")
    end,
    true)


core:add_listener(
    "GeopoliticsRegionOwnershipChangeOccupied",
    "GarrisonOccupiedEvent",
    true,
    function(context)
        local war_list = context:character():faction():factions_at_war_with() --:CA_FACTION_LIST
        local conquering_faction = context:character():faction() --:CA_FACTION
        gpm:get_faction(conquering_faction:name()):set_region_changed()
        for i = 0, war_list:num_items() do
            local current_faction_key = war_list:item_at(i):name()
            gpm:get_faction(current_faction_key):set_region_changed()
        end
    end,
    true)

core:add_listener(
    "GeopoliticsRegionOwnershipChangeConfederation",
    "FactionJoinsConfederation",
    true,
    function(context)
        local confed_name = context:confederation():name() --:string
        gpm:get_faction(confed_name):set_region_changed()
    end,
    true)