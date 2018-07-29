cm = get_cm(); events = get_events(); iem = _G.iem


core:add_listener(
    "ImperiumEffectsTurnStart",
    "FactionTurnStart",
    function(context)
        return iem:has_faction(context:faction():name())
    end,
    function(context)
        local faction = context:faction():name() --:string
        local imperium_level = context:faction():imperium_level() --:number
        iem:log("Tracked faction ["..faction.."] at imperium level ["..imperium_level.."] ")
        if iem:has_effect_for_faction_at_imperium(faction, imperium_level) then
            local effect = iem:get_effect_for_faction_at_imperium(faction, imperium_level)
            if not context:faction():has_effect_bundle(effect) then
                iem:log("applied imperium bundle ["..effect.."] to ["..faction.."] ")
                cm:apply_effect_bundle(effect, faction, 0)
            end
        end
        if iem:has_callback_for_faction_at_imperium(faction, imperium_level) then
            if not cm:get_saved_value("imperium_callbacks_"..faction..imperium_level.."_occured") == true then
                iem:do_callback_for_faction_at_imperium(faction, imperium_level)
            end
        end
    end,
    true
)