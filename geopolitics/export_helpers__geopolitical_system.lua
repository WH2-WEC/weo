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





