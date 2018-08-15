cm = get_cm(); events = get_events(); unit_cap_display = _G.unit_cap_display;

--stale regions

core:add_listener(
    "UnitCapUIGarrisonOccupied",
    "GarrisonOccupiedEvent",
    true,
    function(context)
        local gar_res = context:garison_residence() --: CA_GARRISON_RESIDENCE
        unit_cap_display:set_region_stale(gar_res:region():name())
    end,
    true
)

core:add_listener(
    "UnitCapsUICharacterSackedSettlement",
    "CharacterSackedSettlement",
    function(context)
        return context:garrison_residence():faction():is_human()
    end,
    function(context)
        unit_cap_display:set_region_stale(context:garrison_residence():region():name())
    end,
    true)

core:add_listener(
    "UnitCapsUIFactionJoinsConfederation",
    "FactionJoinsConfederation",
    function(context)
        return context:confederation():is_human()
    end,
    function(context)
        local region_list = context:confederation():region_list()
        for i = 0, region_list:num_items() - 1 do
            unit_cap_display:set_region_stale(region_list:item_at(i):name())
        end
    end,
    true
)

core:add_listener(
    "UnitCapsUIBuildingCompleted",
    "BuildingCompleted",
    function(context)
        return context:garrison_residence():faction():is_human()
    end,
    function(context)
        unit_cap_display:set_region_stale(context:garrison_residence():region():name())
    end,
    true
)

core:add_listener(
    "UnitCapsUIRegionSlotEvent",
    "RegionSlotEvent",
    function(context)
        return context:region_slot():faction():is_human()
    end,
    function(context)
        unit_cap_display:set_region_stale(context:region_slot():region():name())
    end,
    true
)

--skills

core:add_listener(
    "UnitCapsUICharacterConvalescedOrKilled",
    "CharacterConvalescedOrKilled",
    function(context)
        return context:character():is_human()
    end,
    function(context)
        unit_cap_display:set_skills_stale(context:character():command_queue_index())
    end,
    true
)

core:add_listener(
    "UnitCapsUICharacterSkillPoints",
    "CharacterSkillPointAllocated",
    function(context)
        return context:character():is_human()
    end,
    function(context)
        unit_cap_display:set_skills_stale(context:character():command_queue_index())
    end,
    true
)

--unit totals


