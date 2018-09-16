pm = _G.pm
local UIBUTTONNAME = "REGION_DETAILS_BUTTON"
local UIPANELNAME = "REGION_DETAILS_PANEL"

--v function(DetailsFrame: FRAME,fpd: FPD)
local function PopulatePanel(DetailsFrame, fpd)
    local fX, fY = DetailsFrame:Bounds()
    local sX, sY = core:get_screen_resolution()
    local FrameContainer = Container.new(FlowLayout.VERTICAL)
     
    --if subculture_has_religion_and_tax[cm:get_faction(cm:get_local_faction(true)):subculture()] then
        local HorizontalHolder_1 = Container.new(FlowLayout.HORIZONTAL)
            local TaxRateHolder = Container.new(FlowLayout.VERTICAL)
                local TaxRateTitleHolder = Container.new(FlowLayout.HORIZONTAL)
                    local TaxRateTitle = Image.new(UIPANELNAME.."_TAX_RATE_TITLE", DetailsFrame, "ui/custom/pmui/TaxRateTitle.png")
                    TaxRateTitle:Resize(190, 35)
                TaxRateTitleHolder:AddGap(105)
                TaxRateTitleHolder:AddComponent(TaxRateTitle)
                TaxRateTitleHolder:AddGap(105)
                local TaxSliderHolder = Container.new(FlowLayout.HORIZONTAL)
                    local IncrementButton = TextButton.new("TAXincrementButton", DetailsFrame, "TEXT", "+");
                    IncrementButton:Resize(100, 51);
                    local SliderImage = Image.new(UIPANELNAME.."_TAX_RATE_SLIDER", DetailsFrame, "ui/custom/pmui/tax_"..fpd._taxRate..".png")
                    SliderImage:Resize(190, 40)
                    local DecrementButton = TextButton.new("TAXdecrementButton", DetailsFrame, "TEXT", "-");
                    DecrementButton:Resize(100, 51);

                    IncrementButton:RegisterForClick(function()
                        SliderImage:SetImage("ui/custom/pmui/tax_"..(fpd._taxRate + 1)..".png")
                        if (fpd._taxRate + 1) == 5 then
                            IncrementButton:SetDisabled(true)
                        end
                        DecrementButton:SetDisabled(false)
                        CampaignUI.TriggerCampaignScriptEvent(cm:get_faction(cm:get_local_faction(true)):command_queue_index(), "PMUI|IncreaseTaxes|"..fpd._province)
                    end)
                    DecrementButton:RegisterForClick(function()
                        SliderImage:SetImage("ui/custom/pmui/tax_"..(fpd._taxRate - 1)..".png")
                        if (fpd._taxRate - 1) == 1 then
                            DecrementButton:SetDisabled(true)
                        end
                        IncrementButton:SetDisabled(false)
                        CampaignUI.TriggerCampaignScriptEvent(cm:get_faction(cm:get_local_faction(true)):command_queue_index(), "PMUI|DecreaseTaxes|"..fpd._province)
                    end)

                TaxSliderHolder:AddComponent(DecrementButton)
                TaxSliderHolder:AddComponent(SliderImage)
                TaxSliderHolder:AddComponent(IncrementButton)
            TaxRateHolder:AddComponent(TaxRateTitleHolder)
            TaxRateHolder:AddComponent(TaxSliderHolder)
            local ReligionHolder = Container.new(FlowLayout.VERTICAL)

        HorizontalHolder_1:AddComponent(TaxRateHolder)
        HorizontalHolder_1:AddGap(fX/10)
        HorizontalHolder_1:AddComponent(ReligionHolder)
    --end
        local HorizontalHolder_2 = Container.new(FlowLayout.VERTICAL)
            local UnitProductionHolder = Container.new(FlowLayout.VERTICAL)

            local WealthHolder = Container.new(FlowLayout.VERTICAL)
                local WealthTitleHolder = Container.new(FlowLayout.HORIZONTAL)
                    local WealthTitle = Image.new(UIPANELNAME.."_WEALTH_TITLE", DetailsFrame, "ui/custom/pmui/WealthTitle.png")
                    WealthTitle:Resize(190, 35)
                WealthTitleHolder:AddGap(105)
                WealthTitleHolder:AddComponent(WealthTitle)
                WealthTitleHolder:AddGap(105)
                local WealthDisplayHolder = Container.new(FlowLayout.HORIZONTAL)
                    local WealthDisplay = Text.new(UIPANELNAME.."_DY_WEALTH", DetailsFrame, "NORMAL", "[[col:black]]Wealth [[/col]][[col:dark_g]] "..fpd._wealth.."[[/col]]")
                    WealthDisplay:Resize(190, 40)
                    --local CurrentEffectLevel = Image.new()
                WealthDisplayHolder:AddComponent(WealthDisplay)
                local WealthFactorsBlurb = Text.new(UIPANELNAME.."_WEALTH_FACTORS_TITLE", DetailsFrame, "NORMAL", "[[col:black]]Wealth Factors: [[/col]]")
                WealthFactorsBlurb:Resize(190, 40)
                --wealth factors list
            WealthHolder:AddComponent(WealthTitleHolder)
            WealthHolder:AddComponent(WealthDisplayHolder)
            WealthHolder:AddComponent(WealthFactorsBlurb)
            
        HorizontalHolder_2:AddComponent(UnitProductionHolder)
        HorizontalHolder_2:AddGap(fX/10)
        HorizontalHolder_2:AddComponent(WealthHolder)
    if HorizontalHolder_1 then
        FrameContainer:AddComponent(HorizontalHolder_1)
    end
    --FrameContainer:AddGap(15)
    FrameContainer:AddComponent(HorizontalHolder_2)
    Util.centreComponentOnComponent(FrameContainer, DetailsFrame)   
end



--v function()
local function CreatePanel()
    local existingFrame = Util.getComponentWithName(UIPANELNAME)
    if not not existingFrame then
        --# assume existingFrame: FRAME
        existingFrame:Delete()
    end
    local ProvinceDetailsFrame = Frame.new(UIPANELNAME)
    
    --resize frame to match UI of the settlement panel
    local SettlementPanel = find_uicomponent(core:get_ui_root(), "settlement_panel")
    if not not SettlementPanel then
        local sX, sY = core:get_screen_resolution()
        local pX, pY = SettlementPanel:Dimensions()
        ProvinceDetailsFrame:Resize(pX, sY*(1/2))
        local fX, fY = ProvinceDetailsFrame:Bounds()
        local pPosX, pPosY = SettlementPanel:Position()
        ProvinceDetailsFrame:MoveTo(pPosX, pPosY - fY + 20)
        find_uicomponent(SettlementPanel, "button_focus"):PropagatePriority(50)
        --create a close button and move it to top right.

        --set the panel title.
        ProvinceDetailsFrame:SetTitle("Province Details")
        --send to the populator
        local currentFPD = pm._currentFPD
        PopulatePanel(ProvinceDetailsFrame, currentFPD)
    else
        pm:log("UI: failed to launch panel, could not find settlement panel")
        ProvinceDetailsFrame:Delete()
    end
end

local function UIOnSettlementSelected()
    local ButtonParent
    local existingElement = Util.getComponentWithName(UIBUTTONNAME)
    if not not existingElement then
        --# assume existingElement: BUTTON
        existingElement:SetVisible(true)
        existingElement:MoveTo(8, 1016)
    else
        local ButtonParent = find_uicomponent(core:get_ui_root(), "layout") --, "info_panel_holder", "primary_info_panel_holder", "info_panel_background", "ProvinceInfoPopup", "parchment_banner"
        local DetailsButton = Button.new(UIBUTTONNAME, ButtonParent, "CIRCULAR", "ui/skins/default/icon_province_details.png")
        DetailsButton:MoveTo(8, 1016)
        DetailsButton:RegisterForClick(function() CreatePanel() end)
    end
end




--listeners

core:add_listener(
    "SettlementSelectedUI",
    "SettlementSelected",
    function(context)
        return context:garrison_residence():faction():name() == cm:get_local_faction(true)
    end,
    function(context)
        cm:callback(function() 
            local existingFrame = Util.getComponentWithName(UIPANELNAME)
            if not not existingFrame then
                --# assume existingFrame: FRAME
                existingFrame:Delete()
            end
            UIOnSettlementSelected() 
        end, 0.1)
    end,
    true
)

core:add_listener(
    "SettlementSelectedUI",
    "SettlementSelected",
    function(context)
        return context:garrison_residence():faction():name() ~= cm:get_local_faction(true)
    end,
    function(context)
        cm:callback(function()
            local existingElement = Util.getComponentWithName(UIBUTTONNAME)
            if not not existingElement then
                --# assume existingElement: BUTTON
                existingElement:SetVisible(false)
            end
            local existingFrame = Util.getComponentWithName(UIPANELNAME)
            if not not existingFrame then
                --# assume existingFrame: FRAME
                existingFrame:Delete()
            end
        end, 0.1)
    end,
    true
)

core:add_listener(
    "SettlementPanelClosed", 
    "PanelClosedCampaign",
    function(context)
        return context.string == "settlement_panel"
    end,
    function(context)
        local existingElement = Util.getComponentWithName(UIBUTTONNAME)
        if not not existingElement then
            --# assume existingElement: BUTTON
            existingElement:SetVisible(false)
        end
        local existingFrame = Util.getComponentWithName(UIPANELNAME)
        if not not existingFrame then
            --# assume existingFrame: FRAME
            existingFrame:Delete()
        end
    end,
    true
)


--controller

core:add_listener(
    "TaxRateChanges",
    "UITriggerScriptEvent",
    function(context)
        return context:trigger():starts_with("PMUI|IncreaseTaxes|")
    end,
    function(context)
        local trigger = context:trigger() --:string
        local faction = cm:model():faction_for_command_queue_index(context:faction_cqi()):name()
        local province = string.gsub(trigger, "PMUI|IncreaseTaxes|", "")
        local fpd = pm._factionProvinceDetails[faction][province]
        fpd._taxRate = fpd._taxRate + 1
    end,
    true
)

core:add_listener(
    "TaxRateChanges",
    "UITriggerScriptEvent",
    function(context)
        return context:trigger():starts_with("PMUI|DecreaseTaxes|")
    end,
    function(context)
        local trigger = context:trigger() --:string
        local faction = cm:model():faction_for_command_queue_index(context:faction_cqi()):name()
        local province = string.gsub(trigger, "PMUI|DecreaseTaxes|", "")
        local fpd = pm._factionProvinceDetails[faction][province]
        fpd._taxRate = fpd._taxRate - 1
    end,
    true
)