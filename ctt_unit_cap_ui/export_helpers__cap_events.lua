cm = get_cm(); events = get_events(); unit_cap_display = _G.unit_cap_display;



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