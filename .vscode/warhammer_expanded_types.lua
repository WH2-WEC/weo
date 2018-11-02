
--# assume global class LLR_MANAGER
--# assume global class LLR_LORD


--# assume global class CIM
--# assume global class CIP


--# assume global class KOU_MODEL

--# assume global class RECRUITER_MANAGER
--# assume global class RECRUITER_CHARACTER
--# type global RM_UIPROFILE = {_image: string, _text: string}

---Geopolitics system
--# assume global class GEOPOLITIC_FACTION
--# assume global class GEOPOLITIC_REGION
--# assume global class GEOPOLITIC_BLACKLIST
--# assume global class GEOPOLITICAL_MANAGER
--# assume global class GEOPOLITIC_LOADER


--provinces
--# assume global class PROVINCE_REGISTER

--region detail
--# assume global class REGION_DETAIL
--# assume global class PM
--# type global FAITH_TYPE = "own" | "foreign"
--# type global TAX_DETAIL_ENUM = {
--# _bundle: string, _UIEffects: {vector<string>, vector<string>, vector<string>, vector<string>, vector<string>},
--# _wealthEffects: {number, number, number, number, number},
--# _unitProdModifier: {number, number, number, number, number}
--# }
--# type global WEC_FAITH_KEY = 
--# "hum_sigmar" | "hum_ulric" | "hum_manann" | "hum_myrmidia " | "hum_taal" | "hum_lady" | "hum_ursun" | "hum_morr" | "hum_shallya"
--# | "elf_asuryan" | "elf_hoeth" | "elf_cults" | "elf_khaine" | "elf_kurnous" | "elf_isha" | "elf_loec" | "elf_anath_reama" | "elf_hekarti"
--# | "dwf_miners" | "dwf_bakers" | "dwf_slayers" | "dwf_engineers" | "dwf_smiths" | "dwf_sea" |
--# "lzd_sotek" 
--# type global FAITH_DETAIL_ENUM = {
--# _ownUI: vector<string>, _foreignUI: vector<string>,
--# _canBeForeign: boolean, _key: WEC_FAITH_KEY,
--# _wealthEffect: {_own: number, _foreign: number}, _ownUnitProd: map<string, number>
--# }



--imperium
--# assume global class IMPERIUM_EFFECTS_MANAGER


--tech unlocks
--# assume global class TECH_UNLOCK


--lord unlocks
--# assume global class CUSTOM_LORD_UNLOCK







--# assume global class LOREFUL_EMPIRES_MANAGER


--# type global SPAWN_INFO = {
--# region: string, forename: string, surname: string, subtype: string, army: string, x: number, y: number, is_faction_leader: boolean
--#}
--# assume global class DEV_TOOL_MANAGER



--# assume global class SCRIPTED_MISSION_CONTROLLER

--# assume global class SCRIPTED_MISSION
--# type global SCRIPTED_MISSION_OBJECTIVE = {
--# _event: string, _callback: (function(context: WHATEVER) --> boolean ) | boolean, _scriptkey: string?
--#}
--# type global MISSION_INFO_TABLE = {
--# _key: string, _scriptedObjectives: (vector<SCRIPTED_MISSION_OBJECTIVE>)?, 
--# _successCallback: (function())?, _additionalOperations: (function(mm: MISSION_MANAGER))?
--# }

