
local first_army_count = {} --:map<string, number>
local first_army_index = {} --:vector<string>
local first_army_group_count = {} --:map<string, number>
local second_army_index = {} --:vector<string>
local second_army_count = {} --:map<string, number>
local second_army_group_count = {} --:map<string, number>
local first_army_selected = {} --:map<number, boolean>
local second_army_selected = {} --:map<number, boolean>


rm:error_checker()
--v function(panel: string, index: number) --> string
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
            return armyUnitName
        else
            return nil
        end
    end
    return nil
end

--v function(panel: string, index: number)
local function lock_unit_from_transfer(panel, index)
    local armyUnit = find_uicomponent(core:get_ui_root(), "unit_exchange", panel, "units", "UnitCard" .. index);
    if not not armyUnit then
        armyUnit:SetInteractive(false)
        --[[
        if Util then
            if not Util.getComponentWithName("cui_profile_marker_"..panel.."_"..index) then
                local ProfileIcon = Image.new("cui_profile_marker_"..panel.."_"..index, armyUnit, "ui/custom/recruitment_controls/locked_unit.png")
                ProfileIcon:PositionRelativeTo(armyUnit, 20, 30)
                ProfileIcon:GetContentComponent():SetTooltipText("The other army is at their limit for this unit!")
                ProfileIcon:Resize(50, 60)
            else
                local ProfileIcon = Util.getComponentWithName("cui_profile_marker_"..panel.."_"..index) --# assume ProfileIcon: IMAGE
                ProfileIcon:SetImage("ui/custom/recruitment_controls/locked_unit.png")
                ProfileIcon:GetContentComponent():SetTooltipText("The other army is at their limit for this unit!")
                ProfileIcon:Resize(50, 60)
            end
            
            
            if not not Util.getComponentWithName("cui_profile_marker_"..panel.."_"..index) then
                local ProfileIcon = Util.getComponentWithName("cui_profile_marker_"..panel.."_"..index) --# assume ProfileIcon: IMAGE
                ProfileIcon:GetContentComponent():SetTooltipText("The other army is at their limit for this unit!")
            end
        else
            rm:log("UIMF is not installed!")
        end
        --]]
    end
end

--v function(panel: string, index: number)
local function unlock_unit_from_transfer(panel, index)
    local armyUnit = find_uicomponent(core:get_ui_root(), "unit_exchange", panel, "units", "UnitCard" .. index);
    if not not armyUnit then
        armyUnit:SetInteractive(true)
    end
end


--v function(unitID: string, count_of_other_army: map<string, number>, group_count_of_other_army:map<string, number>) --> boolean
local function should_restrict_unit_from_transfer(unitID, count_of_other_army, group_count_of_other_army)
    rm:log("Checking transfer restrictions for unit ["..unitID.."] ")
    local groups = rm:get_groups_for_unit(unitID)
    for j = 1, #groups do
        if group_count_of_other_army[groups[j]] == nil then
            group_count_of_other_army[groups[j]] = 0
        end
        if group_count_of_other_army[groups[j]] + rm:get_weight_for_unit(unitID) - 1 >= rm:get_quantity_limit_for_group(groups[j]) then
            rm:log("Should lock unit ["..unitID.."] from being transferred to the other army!")
            return true
        end
    end
    if count_of_other_army[unitID] == nil then
        count_of_other_army[unitID] = 0 
    end
    if count_of_other_army[unitID] >= rm:get_quantity_limit_for_unit(unitID) then
        rm:log("Should lock unit ["..unitID.."] from being transferred to the other army!")
        return true
    end
    rm:log("Should NOT lock unit ["..unitID.."] from being transferred to the other army!")
    return false
end





core:add_listener(
    "RecruiterManagerOnRecruitPanelOpened",
    "PanelOpenedCampaign",
    function(context) 
        return context.string == "unit_exchange"; 
    end,
    function(context)
        cm:callback(function() --do this on a delay so the panel has time to fully open before the script tries to read it!
           -- print_all_uicomponent_children(find_uicomponent(core:get_ui_root(), "unit_exchange"))

           second_army_index = {} 
           second_army_count = {} 
           second_army_group_count = {}
           first_army_count = {}
           first_army_index = {}
           first_army_group_count = {} 
           first_army_selected = {}
           second_army_selected = {}
            for i = 1, 20 do
                local unitID = GetUnitNameInExchange("main_units_panel_1", i)
                if is_string(unitID) then
                    if first_army_count[unitID] == nil then 
                        first_army_count[unitID] = 0
                    end
                    first_army_count[unitID] = first_army_count[unitID] + 1
                    local groups = rm:get_groups_for_unit(unitID)
                    for k = 1, #groups do
                        if first_army_group_count[groups[k]] == nil then 
                            first_army_group_count[groups[k]] = 0
                        end
                        first_army_group_count[groups[k]] = first_army_group_count[groups[k]] + (1 *rm:get_weight_for_unit(unitID) )
                    end
                    table.insert(first_army_index, unitID)
                    rm:log("added unit ["..unitID.."] to a count! ")
                    if rm:unit_has_ui_profile(unitID) then
                        
                        local unit_profile = rm:get_ui_profile_for_unit(unitID)
                        --[[
                        if Util then 
                            if not not Util.getComponentWithName("cui_profile_marker_main_units_panel_1_"..i) then
                                Util.getComponentWithName("cui_profile_marker_main_units_panel_1_"..i):Delete()
                            end
                            if not Util.getComponentWithName("cui_profile_marker_main_units_panel_1_"..i) then
                                local iconParent = find_uicomponent(core:get_ui_root(), "unit_exchange", "main_units_panel_1", "units", "UnitCard"..i)
                                local ProfileIcon = Image.new("cui_profile_marker_main_units_panel_1_"..i, iconParent, unit_profile._image)
                                ProfileIcon:PositionRelativeTo(iconParent, 20, 30)
                                ProfileIcon:GetContentComponent():SetTooltipText(unit_profile._text)
                            end
                        else
                            rm:log("UIMF not installed!")
                        end
                        --]]
                    else
                        rm:log("Unit has no profile!")
                    end
                else
                    rm:log("Could not find a unit at ["..i.."] in an exchanging army, aborting the loop!")
                    break
                end
            end

            for i = 1, 20 do
                local unitID = GetUnitNameInExchange("main_units_panel_2", i)
                if is_string(unitID) then
                    if second_army_count[unitID] == nil then 
                        second_army_count[unitID] = 0
                    end
                    second_army_count[unitID] = second_army_count[unitID] + 1
                    local groups = rm:get_groups_for_unit(unitID)
                    for k = 1, #groups do
                        if second_army_group_count[groups[k]] == nil then 
                            second_army_group_count[groups[k]] = 0
                        end
                        second_army_group_count[groups[k]] = second_army_group_count[groups[k]] + (1 *rm:get_weight_for_unit(unitID) )
                    end
                    table.insert(second_army_index, unitID)
                    rm:log("added unit ["..unitID.."] to a count! ")
                    if rm:unit_has_ui_profile(unitID) then
                        
                        local unit_profile = rm:get_ui_profile_for_unit(unitID)
                        --[[
                        if Util then 
                            if not not Util.getComponentWithName("cui_profile_marker_main_units_panel_2_"..i) then
                                Util.getComponentWithName("cui_profile_marker_main_units_panel_2_"..i):Delete()
                            end
                            if not Util.getComponentWithName("cui_profile_marker_main_units_panel_2_"..i) then
                                local iconParent = find_uicomponent(core:get_ui_root(), "unit_exchange", "main_units_panel_2", "units", "UnitCard"..i)
                                local ProfileIcon = Image.new("cui_profile_marker_main_units_panel_2_"..i, iconParent, unit_profile._image)
                                ProfileIcon:PositionRelativeTo(iconParent, 20, 30)
                                ProfileIcon:GetContentComponent():SetTooltipText(unit_profile._text)
                            elseif not not Util.getComponentWithName("cui_profile_marker_main_units_panel_2_"..i) then
                                local ProfileIcon = Util.getComponentWithName("cui_profile_marker_main_units_panel_2_"..i) --# assume ProfileIcon: IMAGE
                                ProfileIcon:GetContentComponent():SetTooltipText(unit_profile._text)
                                ProfileIcon:SetImage(unit_profile._image)
                            end
                        else
                            rm:log("UIMF not installed!")
                        end
                        --]]
                    else
                        rm:log("Unit has no profile!")
                    end
                else
                    rm:log("Could not find a unit at ["..i.."] in an exchanging army, aborting the loop!")
                    break
                end
            end

            for i = 1, #first_army_index do
                if should_restrict_unit_from_transfer(first_army_index[i], second_army_count, second_army_group_count) then
                    lock_unit_from_transfer("main_units_panel_1", i)
                else
                    unlock_unit_from_transfer("main_units_panel_1", i)
                end
            end
            for i = 1, #second_army_index do
                if should_restrict_unit_from_transfer(second_army_index[i], first_army_count, first_army_group_count) then
                    lock_unit_from_transfer("main_units_panel_2", i)
                else
                    unlock_unit_from_transfer("main_units_panel_2", i)
                end
            end

        end, 0.1)
    end,
    true
)