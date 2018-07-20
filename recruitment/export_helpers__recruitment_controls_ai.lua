--ai systems to enforce a proxy of recruitment controls on the AI

--v function(unit_totals: map<string, number>, unitID: string)
local function increment_unit_total(unit_totals, unitID)
    if unit_totals[unitID] == nil then
        unit_totals[unitID] = 0
    end
    unit_totals[unitID] = unit_totals[unitID] + 1
end


--v function(faction:CA_FACTION)
local function rm_ai_evaluation(faction)
    rm:log("AI CHECKS ["..faction:name().."]")
    local character_list = faction:character_list()
    for i = 0, character_list:num_items() - 1 do
        local character = character_list:item_at(i)
        if cm:char_is_mobile_general_with_army(character) then
            local unit_list = character:military_force():unit_list()
            local unit_totals = {} --:map<string, number>
            local group_totals = {} --:map<string, number>
            for j = 0, unit_list:num_items() - 1 do
                increment_unit_total(unit_totals, unit_list:item_at(j):unit_key())
                for k = 1, #rm:get_groups_for_unit(unit_list:item_at(j):unit_key()) do
                    increment_unit_total(group_totals, rm:get_groups_for_unit(unit_list:item_at(j):unit_key())[k])
                end
            end
            for unitID, quantity in pairs(unit_totals) do
                local quantity_difference = quantity - rm:get_quantity_limit_for_unit(unitID) 
                if quantity_difference == 0 then
                    rm:log("AI limiting ["..tostring(character:cqi()).."] for unit ["..unitID.."] ")
                    cm:apply_effect_bundle_to_characters_force("wec_unit_caps_"..unitID.."_limiter", character:cqi(), 0, true)
                elseif quantity_difference > 0 then 
                    cm:apply_effect_bundle_to_characters_force("wec_unit_caps_"..unitID.."_limiter", character:cqi(), 0, true)
                    for i = 1, quantity_difference do
                        rm:log("AI limiting ["..tostring(character:cqi()).."] for unit ["..unitID.."] ")
                        cm:remove_unit_from_character(cm:char_lookup_str(character), unitID);
                    end
                else
                    rm:log("AI unlimiting ["..tostring(character:cqi()).."] for unit ["..unitID.."] ")
                    if character:military_force():has_effect_bundle("wec_unit_caps_"..unitID.."_limiter") then
                        cm:remove_effect_bundle_from_characters_force("wec_unit_caps_"..unitID.."_limiter", character:cqi())
                    end
                end
            end
            for groupID, quantity in pairs(group_totals) do
                local quantity_difference = quantity - rm:get_quantity_limit_for_group(groupID)
                if quantity_difference >= 0 then
                    rm:log("AI limiting ["..tostring(character:cqi()).."] for unit ["..groupID.."] ")
                    for m = 1, #rm:get_units_in_group(groupID) do
                        local unitID = rm:get_units_in_group(groupID)[m]
                        cm:apply_effect_bundle_to_characters_force("wec_unit_caps_"..unitID.."_limiter", character:cqi(), 0, true)
                    end
                else 
                    rm:log("AI unlimiting ["..tostring(character:cqi()).."] for unit ["..groupID.."] ")
                    for m = 1, #rm:get_units_in_group(groupID) do
                        local unitID = rm:get_units_in_group(groupID)[m]
                        if character:military_force():has_effect_bundle("wec_unit_caps_"..unitID.."_limiter") then
                            cm:remove_effect_bundle_from_characters_force("wec_unit_caps_"..unitID.."_limiter", character:cqi())
                        end
                    end
                end
            end
        end
    end
end



core:add_listener(
    "RecruitmentControlsAI",
    "FactionTurnStart",
    function(context)
        return not context:faction():is_human()
    end,
    function(context)
        rm_ai_evaluation(context:faction())
    end,
    true
)