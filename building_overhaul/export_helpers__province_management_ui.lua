pm = _G.pm
local UIBUTTONNAME = "REGION_DETAILS_BUTTON"
local UIPANELNAME = "REGION_DETAILS_PANEL"

--v function(SliderImage: IMAGE, fpd: FPD, subculture: string, offset: number?)
local function TaxEffectTooltip(SliderImage, fpd, subculture, offset)
    if offset == nil then
        offset = 0
    end
    --# assume offset: number
    if not not pm._taxResults[subculture] then
        local detail = pm._taxResults[subculture][fpd._taxRate + offset]
            if not not detail then
            local tt = detail._UIName .. "\n"
            for i = 1, #detail._UIEffects do
                tt = "\t"..tt..detail._UIEffects[i].."\n" 
            end
            SliderImage:GetContentComponent():SetTooltipText(tt, true)
        else
            SliderImage:GetContentComponent():SetTooltipText("No Effects", true)
        end
    else
        SliderImage:GetContentComponent():SetTooltipText("No Effects", true)
    end
end

--v function(ReligionBundle: IMAGE, fpd: FPD, religion_detail: RELIGION_DETAIL)
local function ReligionEffectTooltip(ReligionBundle, fpd, religion_detail)
    local level = fpd._religionLevels[religion_detail._name]
    local effects = religion_detail._UIEffects[level]
    local factors = fpd._UIReligionFactors[religion_detail._name]
    local name = religion_detail._UIName
    local description = religion_detail._UIDescription
    local tt = "\t[[col:yellow]]"..name.."[[/col]]\n"..description.."\n"
    if not not effects then
        for i = 1, #effects do
            tt = tt.."\t"..effects[i].."\n"
        end
    else
        tt = tt.."\t No Effects \n"
    end
    local tt = tt.."[[col:yellow]] Changes Last Turn: [[/col]]\n"
    if not not factors then
    for factor, quantity in pairs(factors) do
            if quantity == 0 then

            else
            local factor_string = factor
            if string.find(factor, "wh_") or string.find(factor, "wh2_") then
                factor_string = effect.get_localised_string(factor)
            end
            local colour = "red"
            if quantity > 0 then
                colour = "dark_g"
            end
            tt = tt.."\t"..factor_string.."\t".."[[col:"..colour.."]]"..tostring(quantity).."[[/col]]"
            end
        end
    end
    ReligionBundle:GetContentComponent():SetTooltipText(tt, true)
end

--v function(DetailsFrame: FRAME,fpd: FPD)
local function PopulatePanel(DetailsFrame, fpd)
    local fpX, fpY = DetailsFrame:Position()
    local fbX, fbY = DetailsFrame:Bounds()
    local sX, sY = core:get_screen_resolution()
    local subculture = cm:get_faction(cm:get_local_faction(true)):subculture()
    --if subculture_has_religion_and_tax[subculture] then
        local HorizontalHolder_1 = Container.new(FlowLayout.HORIZONTAL)
            ---------
            --TAXES--
            ---------
            local TaxRateHolder = Container.new(FlowLayout.VERTICAL)
                local TaxRateTitleHolder = Container.new(FlowLayout.HORIZONTAL)
                    local TaxRateTitle = Text.new(UIPANELNAME.."_TAX_RATE_TITLE", DetailsFrame,  "HEADER", "Tax Rate")
                    TaxRateTitle:Resize(190, 35)
                TaxRateTitleHolder:AddGap(45)
                TaxRateTitleHolder:AddComponent(TaxRateTitle)
                TaxRateTitleHolder:AddGap(45)
                local TaxSliderHolder = Container.new(FlowLayout.HORIZONTAL)
                    local IncrementButton = Button.new("TAXincrementButton", DetailsFrame, "CIRCULAR", "ui/skins/default/icon_maximize.png");
                    IncrementButton:Resize(38, 38);
                    local SliderImage = Image.new(UIPANELNAME.."_TAX_RATE_SLIDER", DetailsFrame, "ui/custom/pmui/tax_"..fpd._taxRate..".png")
                        TaxEffectTooltip(SliderImage, fpd, subculture)
                    SliderImage:Resize(190, 40)
                    local DecrementButton = Button.new("TAXdecrementButton", DetailsFrame, "CIRCULAR", "ui/skins/default/icon_minimize.png");
                    DecrementButton:Resize(38, 38);

                    IncrementButton:RegisterForClick(function()
                        SliderImage:SetImage("ui/custom/pmui/tax_"..(fpd._taxRate + 1)..".png")
                        if (fpd._taxRate + 1) == 5 then
                            IncrementButton:SetDisabled(true)
                        end
                        DecrementButton:SetDisabled(false)
                        TaxEffectTooltip(SliderImage, fpd, subculture, 1)
                        local factorImage = Util.getComponentWithName(UIPANELNAME.."_WEALTH_FACTOR_IMAGE_Province Taxes")
                        if not not factorImage then
                            --# assume factorImage: IMAGE
                            TaxEffectTooltip(factorImage, fpd, subculture, 1)
                        end
                        CampaignUI.TriggerCampaignScriptEvent(cm:get_faction(cm:get_local_faction(true)):command_queue_index(), "PMUI|IncreaseTaxes|"..fpd._province)
                    end)
                    DecrementButton:RegisterForClick(function()
                        SliderImage:SetImage("ui/custom/pmui/tax_"..(fpd._taxRate - 1)..".png")
                        if (fpd._taxRate - 1) == 1 then
                            DecrementButton:SetDisabled(true)
                        end
                        IncrementButton:SetDisabled(false)
                        TaxEffectTooltip(SliderImage, fpd, subculture, -1)
                        local factorImage = Util.getComponentWithName(UIPANELNAME.."_WEALTH_FACTOR_IMAGE_Province Taxes")
                        if not not factorImage then
                            --# assume factorImage: IMAGE
                            TaxEffectTooltip(factorImage, fpd, subculture, -1)
                        end
                        CampaignUI.TriggerCampaignScriptEvent(cm:get_faction(cm:get_local_faction(true)):command_queue_index(), "PMUI|DecreaseTaxes|"..fpd._province)
                    end)

                TaxSliderHolder:AddComponent(DecrementButton)
                TaxSliderHolder:AddComponent(SliderImage)
                TaxSliderHolder:AddComponent(IncrementButton)
            TaxRateHolder:AddComponent(TaxRateTitleHolder)
            TaxRateHolder:AddComponent(TaxSliderHolder)
            ------------
            --RELIGION--
            ------------
            local ReligionHolder = Container.new(FlowLayout.VERTICAL)
                local ReligionTitleHolder = Container.new(FlowLayout.HORIZONTAL)
                    local ReligionTitle = Text.new(UIPANELNAME.."_RELIGION_TITLE", DetailsFrame, "HEADER", "Religious Cults")
                    ReligionTitle:Resize(190, 35)
                ReligionTitleHolder:AddGap(45)
                ReligionTitleHolder:AddComponent(ReligionTitle)
                ReligionTitleHolder:AddGap(45)
                local ReligionListHolder = Container.new(FlowLayout.VERTICAL)
                    local ReligionListView = ListView.new(UIPANELNAME.."_RELIGION_LISTVIEW", DetailsFrame, "VERTICAL")
                    ReligionListView:Scale(0.5)
                    ReligionListView:Resize(200, 175)
                        local ReligionListBufferContainer = Container.new(FlowLayout.HORIZONTAL)
                        ReligionListBufferContainer:AddGap(15)
                    ReligionListView:AddContainer(ReligionListBufferContainer)
                    for religion, quantity in pairs(fpd._religionLevels) do
                        if quantity == 0 then
                            pm:log("UI: Ignoring religion ["..religion.."] because it is 0")
                        else
                            if not not pm._religionDetails[religion] then
                                rd = pm._religionDetails[religion]
                                local ReligionItemContainer = Container.new(FlowLayout.HORIZONTAL)
                                    local religionImage = Image.new(UIPANELNAME.."_RELIGION_LIST_ITEM_IMAGE_"..religion, DetailsFrame, rd._UIImage)
                                    religionImage:Resize(20,20)
                                    ReligionEffectTooltip(religionImage, fpd, rd)
                                    local religionName = Text.new(UIPANELNAME.."_RELIGION_LIST_ITEM_FACTOR_"..religion, DetailsFrame, "NORMAL", rd._UIName)
                                    religionName:Resize(140, 30)
                                    local religionLevel = Text.new(UIPANELNAME.."_RELIGION_LIST_ITEM_LEVEL_"..religion, DetailsFrame, "HEADER", "[[col:dark_g]]"..tostring(rd._UILevels[quantity]).."[[/col]]")
                                    religionLevel:Resize(20, 20)
                                ReligionItemContainer:AddComponent(religionLevel)
                                ReligionItemContainer:AddComponent(religionImage)
                                ReligionItemContainer:AddComponent(religionName)
                                ReligionListView:AddContainer(ReligionItemContainer)
                            end
                        end
                    end
                ReligionListHolder:AddComponent(ReligionListView)
            ReligionHolder:AddComponent(ReligionTitleHolder)
            ReligionHolder:AddComponent(ReligionListHolder)
        ----------------------------------------------
        HorizontalHolder_1:AddComponent(TaxRateHolder)
        HorizontalHolder_1:AddGap(fbX/10)
        HorizontalHolder_1:AddComponent(ReligionHolder)
    --end
    local HorizontalHolder_2 = Container.new(FlowLayout.VERTICAL)
        --------------
        --UNITS PROD--
        --------------
        local UnitProductionHolder = Container.new(FlowLayout.VERTICAL)
        ----------
        --WEALTH--
        ----------
        local WealthHolder = Container.new(FlowLayout.VERTICAL)
            local WealthTitleHolder = Container.new(FlowLayout.HORIZONTAL)
                local WealthTitle = Text.new(UIPANELNAME.."_WEALTH_TITLE", DetailsFrame,  "HEADER", "Wealth")
                WealthTitle:Resize(190, 35)
            WealthTitleHolder:AddGap(45)
            WealthTitleHolder:AddComponent(WealthTitle)
            WealthTitleHolder:AddGap(45)
            local WealthDisplayHolder = Container.new(FlowLayout.HORIZONTAL)
                local colour = "dark_g"
                if fpd._wealth < 30 then
                    colour = "red"
                end
                local WealthBlurb = Text.new(UIPANELNAME.."_WEALTH_TEXT", DetailsFrame, "NORMAL", "Current Total:")
                WealthBlurb:Resize(130, 30)
                local WealthDisplay = Text.new(UIPANELNAME.."_WEALTH_DISPLAY", DetailsFrame, "HEADER", "[[col:"..colour.."]]"..fpd._wealth.."[[/col]]")
                WealthDisplay:Resize(30, 30)
                local WealthIcon = Button.new(UIPANELNAME.."_ICON_WEALTH", DetailsFrame, "CIRCULAR", "ui/custom/pmui/WealthIcon.png")
                WealthIcon:Resize(23, 23)
                local contentComponent = WealthIcon:GetContentComponent()
                contentComponent:SetCanResizeHeight(true)
                contentComponent:SetCanResizeWidth(true)
                contentComponent:Resize(24,24)
                contentComponent:SetCanResizeHeight(false)
                contentComponent:SetCanResizeWidth(false)
                if pm._wealthResults[subculture][fpd._wealthLevel] == nil then
                    pm:log("Not setting any wealth tooltip")
                else
                    cm:callback(function()
                        local IconUIC = find_uicomponent(core:get_ui_root(), "REGION_DETAILS_PANEL_ICON_WEALTH")
                        if not not IconUIC then
                            local tt = ""
                            for i = 1, #pm._wealthResultsUI[subculture][fpd._wealthLevel] do
                                tt = tt .. pm._wealthResultsUI[subculture][fpd._wealthLevel][i] .. "\n"
                            end
                            IconUIC:SetTooltipText(tt, true)
                        else
                            pm:log("UI: failed to find the wealth image for tooltip set!")
                        end
                    end, 0.1)
                end
            
            WealthDisplayHolder:AddComponent(WealthBlurb)
            WealthDisplayHolder:AddComponent(WealthDisplay)
            WealthDisplayHolder:AddComponent(WealthIcon)
            local WealthFactorsBlurb = Text.new(UIPANELNAME.."_WEALTH_FACTORS_TITLE", DetailsFrame, "NORMAL", "Changes Last Turn:")
            WealthFactorsBlurb:Resize(160, 30)
            --wealth factors list
            local WealthFactorsContainer = Container.new(FlowLayout.VERTICAL)
            local WealthFactorList = ListView.new(UIPANELNAME.."_WEALTH_FACTORS_LIST", DetailsFrame, "VERTICAL")
            WealthFactorList:Scale(0.5)
            WealthFactorList:Resize(200, 225)
            local WealthFactorBufferDummy = Container.new(FlowLayout.VERTICAL)
            WealthFactorBufferDummy:AddGap(7)
            WealthFactorList:AddContainer(WealthFactorBufferDummy)
            for factor, quantity in pairs(fpd._UIWealthFactors) do
                if quantity == 0 then
                    pm:log("UI: Skipping factor ["..factor.."] because it is 0 ")
                else
                    pm:log("UI: generating wealth factor UI for ["..factor.."] at quantity ["..quantity.."] ")
                    local factor_string = factor
                    local factorImage = "ui/campaign ui/effect_bundles/icon_effects_raiding.png"
                    if string.find(factor, "wh_") or string.find(factor, "wh2_") then
                        -- we are assumign this means the factor is a settlement
                        factor_string = effect.get_localised_string("regions_onscreen_"..factor)
                        factorImage = "ui/campaign ui/effect_bundles/strategic_location.png"
                    end
                    if string.find(factor, "RELIGION_") then
                        local religion_name = string.gsub(factor, "RELIGION_", "")
                        local religion = pm._religionDetails[religion_name]
                        if not not religion then
                            factor_string = religion._UIName
                            factorImage = religion._UIImage
                        end
                    end
                    if factor == "Province Taxes" then
                        factorImage = "ui/campaign ui/effect_bundles/income.png"
                    end
                    local front_tag = "[[col:dark_g]]+"
                    if quantity < 0 then
                        front_tag = "[[col:red]]-"
                    end
                    local FactorElementsHolder = Container.new(FlowLayout.HORIZONTAL)
                    local FactorImage = Image.new(UIPANELNAME.."_WEALTH_FACTOR_IMAGE_"..factor, DetailsFrame, factorImage)
                    FactorImage:Resize(20, 20)
                    if factor == "Province Taxes" then
                        TaxEffectTooltip(FactorImage, fpd, subculture, 0)
                    end
                    local FactorElement = Text.new(UIPANELNAME.."_WEALTH_FACTOR_"..factor, DetailsFrame, "NORMAL", factor_string)
                    local QuantityElement = Text.new(UIPANELNAME.."_DY_WEALTH_FACTOR_"..factor, DetailsFrame, "NORMAL", front_tag..quantity.."[[/col]]")
                    FactorElement:Resize(140, 30)
                    QuantityElement:Resize(60, 30)
                    FactorElementsHolder:AddComponent(FactorImage)
                    FactorElementsHolder:AddComponent(FactorElement)
                    FactorElementsHolder:AddComponent(QuantityElement)
                    WealthFactorList:AddContainer(FactorElementsHolder)
                end
            end
            WealthFactorsContainer:AddComponent(WealthFactorList)
        WealthHolder:AddComponent(WealthTitleHolder)
        WealthHolder:AddComponent(WealthDisplayHolder)
        WealthHolder:AddComponent(WealthFactorsBlurb)
        WealthHolder:AddComponent(WealthFactorsContainer)  
    HorizontalHolder_2:AddComponent(UnitProductionHolder)
    HorizontalHolder_2:AddGap(fbX/10)
    HorizontalHolder_2:AddComponent(WealthHolder)
    HorizontalHolder_1:MoveTo(500, 300)
    HorizontalHolder_2:MoveTo(500, 300)

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
        ProvinceDetailsFrame:Resize(1060, 565)
        local fX, fY = ProvinceDetailsFrame:Bounds()
        local pPosX, pPosY = SettlementPanel:Position()
        ProvinceDetailsFrame:MoveTo(pPosX, pPosY - fY)
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
        existingElement:Resize(56, 56)
        existingElement:MoveTo(8, 1016)
    else
        local ButtonParent = find_uicomponent(core:get_ui_root(), "layout") --, "info_panel_holder", "primary_info_panel_holder", "info_panel_background", "ProvinceInfoPopup", "parchment_banner"
        local DetailsButton = Button.new(UIBUTTONNAME, ButtonParent, "CIRCULAR", "ui/skins/default/icon_province_details.png")
        DetailsButton:Resize(56, 56)
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


