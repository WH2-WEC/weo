--adds new units to Drunk Flamingo's TT-based unit caps script


rm = _G.rm; cm = get_cm();
local zombiestanks = {
{"wh_emp_steam_tank_deliverance", "emp_rare", 3},
{"wh_emp_steam_tank_alter", "emp_rare", 3},
{"wh_emp_steam_tank_sigmar", "emp_rare", 3},
{"wh_emp_steam_tank_implacable", "emp_rare", 3},
{"wh_emp_steam_tank_invincible", "emp_rare", 3},
{"wh2_skv_rat_tank", "skv_rare", 3}
}--:vector<{string, string, number?}>

local prefix_to_subculture = {
    bst = "wh_dlc03_sc_bst_beastmen",
    wef = "wh_dlc05_sc_wef_wood_elves",
    brt = "wh_main_sc_brt_bretonnia",
    chs = "wh_main_sc_chs_chaos",
    dwf = "wh_main_sc_dwf_dwarfs",
    emp = "wh_main_sc_emp_empire",
    grn = "wh_main_sc_grn_greenskins",
    ksl = "wh_main_sc_ksl_kislev",
    nor = "wh_main_sc_nor_norsca",
    teb = "wh_main_sc_teb_teb",
    vmp = "wh_main_sc_vmp_vampire_counts",
    tmb = "wh2_dlc09_sc_tmb_tomb_kings",
    def = "wh2_main_sc_def_dark_elves",
    hef = "wh2_main_sc_hef_high_elves",
    lzd = "wh2_main_sc_lzd_lizardmen",
    skv = "wh2_main_sc_skv_skaven"
}--:map<string, string>
    


local groups = {} --:map<string, boolean>
if not not rm then
    for i = 1, #zombiestanks do
	local units = zombiestanks
        if units[i][3] then
            rm:set_weight_for_unit(units[i][1], units[i][3])
        end
        groups[units[i][2]] = true;
        rm:add_unit_to_group(units[i][1], units[i][2])

        if string.find(units[i][2], "_core") then
            local prefix = string.gsub(units[i][2], "_core", "")
            rm:whitelist_unit_for_subculture(units[i][1], prefix_to_subculture[prefix])
            rm:set_ui_profile_for_unit(units[i][1], {
                _text = "This unit is a Core Unit. \n Armies may have an unlimited number of Core Units.",
                _image = "ui/custom/recruitment_controls/common_units.png"
            })
        end
        if string.find(units[i][2], "_special") then
            local prefix = string.gsub(units[i][2], "_special", "")
            rm:whitelist_unit_for_subculture(units[i][1], prefix_to_subculture[prefix])
            local weight = units[i][3] --# assume weight: number
            rm:set_ui_profile_for_unit(units[i][1], {
                _text = "This unit is a Special Unit and costs[[col:green]] "..weight.." [[/col]]points. \n Armies may have up to 10 Points worth of Special Units. ",
                _image = "ui/custom/recruitment_controls/special_units_"..weight..".png"
            })
        end
        if string.find(units[i][2], "_rare") then
            local prefix = string.gsub(units[i][2], "_rare", "")
            rm:whitelist_unit_for_subculture(units[i][1], prefix_to_subculture[prefix])
            local weight = units[i][3] --# assume weight: number
            rm:set_ui_profile_for_unit(units[i][1], {
                _text = "This unit is a Rare Unit and costs[[col:green]] "..weight.." [[/col]]points. \n Armies may have up to 5 Points worth of Rare Units. ",
                _image = "ui/custom/recruitment_controls/rare_units_"..weight..".png"
            })
        end
    end
end

