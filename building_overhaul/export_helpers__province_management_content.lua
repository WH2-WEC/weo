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
    UIEffects = {
        [900] = {"[[col:green]] +10 Wealth[[/col]]",
                "[[col:green]] +25 Unit Generation for Sigmarite Units [[/col]]"}
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
    UIEffects = {
        [50] = {"[[col:green]] 0 [[/col]]",
                "[[col:green]] 0 [[/col]]"}
    }
} --:RELIGION_DETAIL
pm:add_tax_level_for_subculture("wh_main_sc_emp_empire", 3, emp_detail_3)

pm:add_building_wealth_effect("wh_main_special_settlement_altdorf_1_emp", 4)
pm:add_building_wealth_effect("wh_main_emp_port_1", 1)


pm:create_religion("hum_sigmar", sigmar_detail)
pm:create_religion("hum_manann", manann_detail)
pm:add_building_religion_effect("wh_main_special_settlement_altdorf_1_emp", "hum_sigmar", 1000)
pm:add_building_religion_effect("wh_main_emp_port_1", "hum_manann", 50)