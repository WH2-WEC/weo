

rm:error_checker()
--v function(panel: string, index: number) --> (string, boolean)
local function GetUnitNameInExchange(panel, index)
    local Panel = find_uicomponent(core:get_ui_root(), "unit_exchange", panel)
    if not not Panel then
        local armyUnit = find_uicomponent(Panel, "units", "UnitCard" .. index);
        if not not armyUnit then
            armyUnit:SimulateMouseOn();
            local unitInfo = find_uicomponent(core:get_ui_root(), "UnitInfoPopup", "tx_unit-type");
            local rawstring = unitInfo:GetStateText();
            local infostart = string.find(rawstring, "unit/") + 5;
            local infoend = string.find(rawstring, "]]") - 1;
            local armyUnitName = string.sub(rawstring, infostart, infoend)
            rm:log("Found unit ["..armyUnitName.."] at ["..index.."] ")
            local is_transfered = false --:boolean
            local transferArrow = find_uicomponent(armyUnit, "exchange_arrow")
            if not not transferArrow then 
                is_transfered = transferArrow:Visible()
            end
            return armyUnitName, is_transfered
        else
            return nil, false
        end
    end
    return nil, false
end

--v function(reason: string)
local function LockExchangeButton(reason)
    local ok_button = find_uicomponent(core:get_ui_root(), "unit_exchange", "hud_center_docker", "ok_cancel_buttongroup", "button_ok")
    if not not ok_button then
        ok_button:SetInteractive(false)
        ok_button:SetImage("ui/skins/default/icon_disband.png")
    else
        rm:log("ERROR: could not find the exchange ok button!")
    end
end

--v function()
local function UnlockExchangeButton()
    local ok_button = find_uicomponent(core:get_ui_root(), "unit_exchange", "hud_center_docker", "ok_cancel_buttongroup", "button_ok")
    if not not ok_button then
        ok_button:SetInteractive(true)
        ok_button:SetImage("ui/skins/default/icon_check.png")
    else
        rm:log("ERROR: could not find the exchange ok button!")
    end
end

--v function(first_army_count: map<string, number>, second_army_count:map<string, number>) --> (boolean, string)
local function are_armies_valid(first_army_count, second_army_count)

    for unitID, count in pairs(first_army_count) do
        if count > rm:get_quantity_limit_for_unit(unitID) then
            return false, "Too many individual restricted units in an army!"
        end
        local groups = rm:get_groups_for_unit(unitID)
        for i = 1, #groups do
            local grouped_units = rm:get_units_in_group(groups[i])
            local group_total = 0 --:number
            for j = 1, #grouped_units do
                if first_army_count[grouped_units[j]] == nil then
                    first_army_count[grouped_units[j]] = 0
                end
                group_total = group_total + (first_army_count[grouped_units[j]] * rm:get_weight_for_unit(grouped_units[j]))
            end
            if group_total > rm:get_quantity_limit_for_group(groups[i]) then
                return false, "Too many units from group "..rm:get_ui_name_for_group(groups[i]).." in an army!"
            end
        end
    end

    for unitID, count in pairs(second_army_count) do
        if count > rm:get_quantity_limit_for_unit(unitID) then
            return false, "Too many individual restricted units in an army!"
        end
        local groups = rm:get_groups_for_unit(unitID)
        for i = 1, #groups do
            local grouped_units = rm:get_units_in_group(groups[i])
            local group_total = 0 --:number
            for j = 1, #grouped_units do
                if second_army_count[grouped_units[j]] == nil then
                    second_army_count[grouped_units[j]] = 0
                end
                group_total = group_total + (second_army_count[grouped_units[j]] * rm:get_weight_for_unit(grouped_units[j]))
            end
            if group_total > rm:get_quantity_limit_for_group(groups[i]) then
                return false, "Too many units from group "..rm:get_ui_name_for_group(groups[i]).." in an army!"
            end
        end
    end
    return true, "valid"
end

--v function() --> (map<string, number>, map<string, number>)
local function count_armies()
    local first_army_count = {} --:map<string, number>
    local second_army_count = {} --:map<string, number>

    for i = 1, 20 do
        local unitID, is_transfer = GetUnitNameInExchange("main_units_panel_1", i)
        if not not unitID then
            if is_transfer then
                if second_army_count[unitID] == nil then
                    second_army_count[unitID] = 0
                end
                second_army_count[unitID] = second_army_count[unitID] + 1
            else
                if first_army_count[unitID] == nil then
                    first_army_count[unitID] = 0
                end
                first_army_count[unitID] = first_army_count[unitID] + 1
            end
        end
    end

    for i = 1, 20 do
        local unitID, is_transfer = GetUnitNameInExchange("main_units_panel_2", i)
        if not not unitID then
            if not is_transfer then
                if second_army_count[unitID] == nil then
                    second_army_count[unitID] = 0
                end
                second_army_count[unitID] = second_army_count[unitID] + 1
            else
                if first_army_count[unitID] == nil then
                    first_army_count[unitID] = 0
                end
                first_army_count[unitID] = first_army_count[unitID] + 1
            end
        end
    end

    return first_army_count, second_army_count
end





core:add_listener(
    "RecruiterManagerOnExchangePanelOpened",
    "PanelOpenedCampaign",
    function(context) 
        return context.string == "unit_exchange"; 
    end,
    function(context)
        cm:callback(function() --do this on a delay so the panel has time to fully open before the script tries to read it!
           -- print_all_uicomponent_children(find_uicomponent(core:get_ui_root(), "unit_exchange"))

            local first_army, second_army = count_armies()
            local valid_armies, reason = are_armies_valid(first_army, second_army)
            if valid_armies then
                UnlockExchangeButton()
            else
                rm:log("locking exchange button for reason ["..reason.."] ")
                LockExchangeButton(reason)
            end
        end, 0.1)
    end,
    true
)


core:add_listener(
    "RecruiterManagerOnExchangeOptionClicked",
    "ComponentLClickUp",
    function(context)
       return not not string.find(context.string, "UnitCard") 
    end,
    function(context)
       rm:log("refreshing army validity")
       cm:callback( function()
            local first_army, second_army = count_armies()
            local valid_armies, reason = are_armies_valid(first_army, second_army)
            if valid_armies then
                UnlockExchangeButton()
            else
                rm:log("locking exchange button for reason ["..reason.."] ")
                LockExchangeButton(reason)
            end
        end, 0.1)
    end,
    true);


core:add_listener(
    "RecruiterManagerOnExchangePanelClosed",
    "PanelClosedCampaign",
    function(context)
        return context.string == "unit_exchange"
    end,
    function(context)
        rm:log("Exchange panel closed, setting armies stale!")
        for cqi, character in pairs(rm:characters()) do
            character:set_army_stale()
        end
    end,
    true
)