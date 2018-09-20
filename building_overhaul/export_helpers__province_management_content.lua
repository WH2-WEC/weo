pm = _G.pm

pm:add_wealth_threshold_for_subculture("wh_main_sc_emp_empire", 1, "wh2_dlc10_dark_elf_fortress_gate", {
    "[[col:green]] A temporary dummy [[/col]]",
    "[[col:red]] To show how this shit works [[//col]] "
})

emp_detail_3 = {
    _level = 3,
    _UIName = "[[col:yellow]]Moderate Taxes[[/col]]",
    _UIEffects = {
        "[[col:green]] +5% Unit Generation (All Units) [[/col]]",
        "[[col:green]] +5% Income (Province Wide) [[/col]]",
        "[[col:red]] -4 Public Order[[//col]]",
        "[[col:red]] -15 Wealth[[//col]]"
    },
    _bundle = "wh2_dlc10_dark_elf_fortress_gate",
    _wealthEffects = -4,
    _unitProdEffects = 1.05
}
local sigmar_detail = {
    _name = "hum_sigmar",
    _UIName = "Cult of Sigmar",
    _UIImage = "ui/custom/religions/sigmar.png",
    _UIDescription = "The first Emperor of Man, raised to Godhood by the Ulric himself.",
    _thresholds = {900},
    _bundles = {
        [900] = "wh_dlc08_bundle_nurgle_plague"
    },
    _wealthEffects = {
        [900] = 2
    },
    _unitProdEffects = {
        [900] = {}
    },
    _UIEffects = {
        [900] = {"[[col:green]] +10 Wealth[[/col]]",
                "[[col:green]] +25 Unit Generation for Sigmarite Units [[/col]]"}
    },
    _UILevels = {
        [900] = 5
    }
} --:RELIGION_DETAIL
local manann_detail = {
    _name = "hum_manann",
    _UIName = "Cult of Manann",
    _UIImage = "ui/custom/religions/Manann.png",
    _UIDescription = "The god of the sea idk I need someone to write these shits for me.",
    _thresholds = {50},
    _bundles = {
        [50] = "wh2_dlc10_power_of_nature"
    },
    _wealthEffects = {
        [50] = 1
    },
    _unitProdEffects = {
        [50] = {}
    },
    _UIEffects = {
        [50] = {"[[col:green]] 0 [[/col]]",
                "[[col:green]] 0 [[/col]]"}
    },
    _UILevels = {
        [50] = 1
    }
} --:RELIGION_DETAIL
pm:add_tax_level_for_subculture("wh_main_sc_emp_empire", 3, emp_detail_3)

pm:add_building_wealth_effect("wh_main_special_settlement_altdorf_1_emp", 4)
pm:add_building_wealth_effect("wh_main_emp_port_1", 1)


pm:create_religion("hum_sigmar", sigmar_detail)
pm:create_religion("hum_manann", manann_detail)
pm:add_building_religion_effect("wh_main_special_settlement_altdorf_1_emp", "hum_sigmar", 1000)
pm:add_building_religion_effect("wh_main_emp_port_1", "hum_manann", 50)

EMP_BUILDING_POP_EFFECTS = {
	[0] = { ["building"] = "wh_main_emp_barracks_1", ["effect"] = "wec_script_var_pools_wh_main_emp_inf_crossbowmen", ["effect_scope"] = "building_to_faction_own", ["value"] = 5, ["value_damaged"] = 0, ["value_ruined"] = 0 },
	[1] = { ["building"] = "wh_main_emp_barracks_1", ["effect"] = "wec_script_var_pools_wh_main_emp_inf_spearmen_0", ["effect_scope"] = "building_to_faction_own", ["value"] = 10, ["value_damaged"] = 0, ["value_ruined"] = 0 },
	[2] = { ["building"] = "wh_main_emp_barracks_1", ["effect"] = "wec_script_var_pools_wh_main_emp_inf_spearmen_1", ["effect_scope"] = "building_to_faction_own", ["value"] = 10, ["value_damaged"] = 0, ["value_ruined"] = 0 },
	[3] = { ["building"] = "wh_main_emp_barracks_1", ["effect"] = "wec_script_var_pools_wh_main_emp_inf_swordsmen", ["effect_scope"] = "building_to_faction_own", ["value"] = 10, ["value_damaged"] = 0, ["value_ruined"] = 0 },
	[4] = { ["building"] = "wh_main_emp_barracks_2", ["effect"] = "wec_script_var_pools_wh_main_emp_inf_crossbowmen", ["effect_scope"] = "building_to_faction_own", ["value"] = 10, ["value_damaged"] = 0, ["value_ruined"] = 0 },
	[5] = { ["building"] = "wh_main_emp_barracks_2", ["effect"] = "wec_script_var_pools_wh_main_emp_inf_halberdiers", ["effect_scope"] = "building_to_faction_own", ["value"] = 10, ["value_damaged"] = 0, ["value_ruined"] = 0 },
	[6] = { ["building"] = "wh_main_emp_barracks_2", ["effect"] = "wec_script_var_pools_wh_main_emp_inf_spearmen_0", ["effect_scope"] = "building_to_faction_own", ["value"] = 10, ["value_damaged"] = 0, ["value_ruined"] = 0 },
	[7] = { ["building"] = "wh_main_emp_barracks_2", ["effect"] = "wec_script_var_pools_wh_main_emp_inf_spearmen_1", ["effect_scope"] = "building_to_faction_own", ["value"] = 10, ["value_damaged"] = 0, ["value_ruined"] = 0 },
	[8] = { ["building"] = "wh_main_emp_barracks_2", ["effect"] = "wec_script_var_pools_wh_main_emp_inf_swordsmen", ["effect_scope"] = "building_to_faction_own", ["value"] = 15, ["value_damaged"] = 0, ["value_ruined"] = 0 },
	[9] = { ["building"] = "wh_main_emp_barracks_3", ["effect"] = "wec_script_var_pools_wh_main_emp_inf_crossbowmen", ["effect_scope"] = "building_to_faction_own", ["value"] = 10, ["value_damaged"] = 0, ["value_ruined"] = 0 },
	[10] = { ["building"] = "wh_main_emp_barracks_3", ["effect"] = "wec_script_var_pools_wh_main_emp_inf_greatswords", ["effect_scope"] = "building_to_faction_own", ["value"] = 8, ["value_damaged"] = 0, ["value_ruined"] = 0 },
	[11] = { ["building"] = "wh_main_emp_barracks_3", ["effect"] = "wec_script_var_pools_wh_main_emp_inf_halberdiers", ["effect_scope"] = "building_to_faction_own", ["value"] = 10, ["value_damaged"] = 0, ["value_ruined"] = 0 },
	[12] = { ["building"] = "wh_main_emp_barracks_3", ["effect"] = "wec_script_var_pools_wh_main_emp_inf_spearmen_0", ["effect_scope"] = "building_to_faction_own", ["value"] = 10, ["value_damaged"] = 0, ["value_ruined"] = 0 },
	[13] = { ["building"] = "wh_main_emp_barracks_3", ["effect"] = "wec_script_var_pools_wh_main_emp_inf_spearmen_1", ["effect_scope"] = "building_to_faction_own", ["value"] = 10, ["value_damaged"] = 0, ["value_ruined"] = 0 },
	[14] = { ["building"] = "wh_main_emp_barracks_3", ["effect"] = "wec_script_var_pools_wh_main_emp_inf_swordsmen", ["effect_scope"] = "building_to_faction_own", ["value"] = 15, ["value_damaged"] = 0, ["value_ruined"] = 0 }
}--:map<integer, map<string, WHATEVER>>
for i = 0, 14 do
    local table = EMP_BUILDING_POP_EFFECTS[i]
    pm:add_building_unit_production_effect(table.building, string.gsub(table.effect, "wec_script_var_pools_", ""), table.value)
end
