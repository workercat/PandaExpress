
local myname, ns = ...


local BACKDROP = {
  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  edgeSize = 16,
  insets = {left = 4, right = 4, top = 4, bottom = 4},
	tile = true,
  tileSize = 16,
}


ns.panel = CreateFrame("Frame", nil, TradeSkillFrame)
ns.panel:SetWidth(250)
ns.panel:SetPoint("TOPLEFT", TradeSkillFrame, "TOPRIGHT", -8, -21)
ns.panel:SetPoint("BOTTOM", 0, 21)
-- ns.panel:Hide()

ns.panel:SetFrameLevel(TradeSkillFrame:GetFrameLevel()-1)

ns.panel:SetBackdrop(BACKDROP)
ns.panel:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b)
ns.panel:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b)

ns.panel:EnableMouse(true)


local butt = ns.NewCraftButton(ns.panel)
butt:SetPoint("TOPLEFT", 10, -10)
butt:SetPoint("RIGHT", -2, 0)

local anchor = butt
for i=1,7 do
  local butt = ns.NewCraftButton(ns.panel)
  butt:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -7)
  butt:SetPoint("RIGHT", anchor)
  anchor = butt
end