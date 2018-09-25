pm = _G.pm

pm:add_wealth_threshold_for_subculture("wh_main_sc_emp_empire", 1, "wec_religion_hum_ulric_1wh_main_sc_emp_empire", {
    "[[col:green]] A temporary dummy [[/col]]",
    "[[col:red]] To show how this shit works [[//col]] "
})

local sigmar_detail = {
    _name = "hum_sigmar",
    _UIName = "Cult of Sigmar",
    _UIImage = "ui/custom/religions/sigmar.png",
    _UIDescription = "The first Emperor of Man, raised to Godhood by the Ulric himself.",
    _thresholds = {900},
    _bundles = {
        [900] = "wec_religion_hum_sigmar_5wh_main_sc_emp_empire"
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
    },
    _flatUnitProdEffect = 0
} --:RELIGION_DETAIL
local manann_detail = {
    _name = "hum_manann",
    _UIName = "Cult of Manann",
    _UIImage = "ui/custom/religions/Manann.png",
    _UIDescription = "The god of the sea idk I need someone to write these shits for me.",
    _thresholds = {50},
    _bundles = {
        [50] = "wec_religion_hum_manann_1wh_main_sc_emp_empire"
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
    },
    _flatUnitProdEffect = 0
} --:RELIGION_DETAIL

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
