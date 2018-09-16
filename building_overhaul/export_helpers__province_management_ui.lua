pm = _G.pm
local UIBUTTONNAME = "REGION_DETAILS_BUTTON"
local UIPANELNAME = "REGION_DETAILS_PANEL"

--v function(DetailsFrame: FRAME,fpd: FPD)
local function PopulatePanel(DetailsFrame, fpd)
    local fX, fY = DetailsFrame:Bounds()
    local sX, sY = core:get_screen_resolution()
    local FrameContainer = Container.new(FlowLayout.VERTICAL)
    Util.centreComponentOnComponent(FrameContainer, DetailsFrame)    
        local HorizontalHolder_1 = Container.new(FlowLayout.HORIZONTAL)
            local TaxRateHolder = Container.new(FlowLayout.VERTICAL)

            local ReligionHolder = Container.new(FlowLayout.VERTICAL)

        HorizontalHolder_1:AddComponent(TaxRateHolder)
        HorizontalHolder_1:AddGap(fX/10)
        HorizontalHolder_1:AddComponent(ReligionHolder)

        local HorizontalHolder_2 = Container.new(FlowLayout.VERTICAL)
            local UnitProductionHolder = Container.new(FlowLayout.VERTICAL)

            local WealthHolder = Container.new(FlowLayout.VERTICAL)

        HorizontalHolder_2:AddComponent(UnitProductionHolder)
        HorizontalHolder_2:AddGap(fX/10)
        HorizontalHolder_2:AddComponent(WealthHolder)

    FrameContainer:AddComponent(HorizontalHolder_1)
    FrameContainer:AddGap(fY/6)
    FrameContainer:AddComponent(HorizontalHolder_2)
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
    --create a close button and move it to top right.
    --set the panel title.
    local currentFPD = pm._currentFPD
    PopulatePanel(ProvinceDetailsFrame, currentFPD)
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
        cm:callback(function() UIOnSettlementSelected() end, 0.1)
    end,
    true
)

core:add_listener(
    "SettlementSelectedUI",
    "SettlementSelected",
    function(context)
        return (not context:garrison_residence():faction():name() == cm:get_local_faction(true))
    end,
    function(context)
        cm:callback(function()
            local existingElement = Util.getComponentWithName(UIBUTTONNAME)
            if not not existingElement then
                --# assume existingElement: BUTTON
                existingElement:SetVisible(false)
            end
        end, 0.1)
    end,
    true
)

core:add_listener(
    "PanelClosed", 
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
    end,
    true
)
