local subculture_default_units = {
    ["wh_dlc03_sc_bst_beastmen"] = "wh_dlc03_bst_inf_gor_herd_0",
    ["wh_dlc05_sc_wef_wood_elves"] = "wh_dlc05_wef_inf_eternal_guard_1",
    ["wh_main_sc_brt_bretonnia"] = "wh_main_brt_cav_knights_of_the_realm",
    ["wh_main_sc_chs_chaos"] = "wh_main_chs_inf_chaos_warriors_0",
    ["wh_main_sc_dwf_dwarfs"] = "wh_main_dwf_inf_longbeards",
    ["wh_main_sc_emp_empire"] = "wh_main_emp_inf_halberdiers",
    ["wh_main_sc_grn_greenskins"] = "wh_main_grn_inf_orc_big_uns",
    ["wh_main_sc_grn_savage_orcs"] = "wh_main_grn_inf_savage_orc_big_uns",
    ["wh_main_sc_ksl_kislev"] = "wh_main_emp_inf_halberdiers",
    ["wh_main_sc_nor_norsca"] = "wh_main_nor_inf_chaos_marauders_0",
    ["wh_main_sc_teb_teb"] = "wh_main_emp_inf_halberdiers",
    ["wh_main_sc_vmp_vampire_counts"] = "wh_main_vmp_inf_crypt_ghouls",
    ["wh2_dlc09_sc_tmb_tomb_kings"] = "wh2_dlc09_tmb_inf_nehekhara_warriors_0",
    ["wh2_main_sc_def_dark_elves"] = "wh2_main_def_inf_black_ark_corsairs_0",
    ["wh2_main_sc_hef_high_elves"] = "wh2_main_hef_inf_spearmen_0",
    ["wh2_main_sc_lzd_lizardmen"] = "wh2_main_lzd_inf_saurus_warriors_1",
    ["wh2_main_sc_skv_skaven"]  = "wh2_main_skv_inf_stormvermin_0"
}--:map<string, string>













--ai systems to enforce a proxy of recruitment controls on the AI

--v function(unit_totals: map<string, number>, unitID: string)
local function increment_unit_total(unit_totals, unitID)
    if unit_totals[unitID] == nil then
        unit_totals[unitID] = 0
    end
    unit_totals[unitID] = unit_totals[unitID] + 1
end

--v function(group_totals: map<string, number>, groupID: string, weight: number)
local function increment_group_total(group_totals, groupID, weight)
    if group_totals[groupID] == nil then
        group_totals[groupID] = 0
    end
    group_totals[groupID] = group_totals[groupID] + (1* weight)
end

--v function(character: CA_CHAR, groupID: string, difference: number)
local function limit_character(character, groupID, difference)

    local unit_list = character:military_force():unit_list()
    for j = 0, unit_list:num_items() - 1 do
        local unit = unit_list:item_at(j):unit_key()
        local groups_list = rm:get_groups_for_unit(unit)
        for k = 1, #groups_list do
            if groups_list[k] == groupID then
                cm:remove_unit_from_character(cm:char_lookup_str(character:cqi()), unit)
                cm:grant_unit_to_character(character:cqi(), subculture_default_units[character:faction():subculture()])
                if rm:get_weight_for_unit(unit) >= difference then
                    return
                end
            end
        end
    end
end





--v function(character: CA_CHAR)
local function rm_ai_character(character)

    if cm:char_is_mobile_general_with_army(character) then
        local unit_list = character:military_force():unit_list()
        local unit_totals = {} --:map<string, number>
        local group_totals = {} --:map<string, number>
        for j = 0, unit_list:num_items() - 1 do
            local unit = unit_list:item_at(j):unit_key()
            local groups_list = rm:get_groups_for_unit(unit)
            for k = 1, #groups_list do
                increment_group_total(group_totals, groups_list[k], rm:get_weight_for_unit(unit))
            end
        end
        for groupID, quantity in pairs(group_totals) do
            local limit = rm:get_quantity_limit_for_group(groupID)
            if quantity > limit then
                limit_character(character, groupID, quantity - limit)
            end
        end
    end
end


--v function(faction:CA_FACTION)
local function rm_ai_evaluation(faction)
    if faction:name() == "rebels" then
        return
    end

    rm:log("AI CHECKS ["..faction:name().."]")
    local character_list = faction:character_list()
    for i = 0, character_list:num_items() - 1 do
        local character = character_list:item_at(i)
        rm_ai_character(character)
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