
local myname, ns = ...


local UNKNOWN = GRAY_FONT_COLOR_CODE.. "???"


local server = GetRealmName().." "..UnitFactionGroup("player")
local function GetNumAuctions(link)
  local id = ns.ids[link]
  local count = 0

  if id and ForSaleByOwnerDB then
    for char,vals in pairs(ForSaleByOwnerDB[server]) do
      count = count + (vals[id] or 0)
    end
  end

  return count
end


local function ColorNum(num)
  local color = (num > 0) and HIGHLIGHT_FONT_COLOR_CODE or GRAY_FONT_COLOR_CODE
  return color.. num.. "|r"
end


local function SetRecipe(self, recipe)
  if not recipe then
    self:Hide()
    return
  end

  self.recipe_id = recipe.recipeID
  self.recipe = recipe

  self.icon:SetTexture(recipe.icon)
  self.name:SetText(recipe.name)

  local link = C_TradeSkillUI.GetRecipeItemLink(recipe.recipeID)
  self.item.link = link
  if recipe.learned then
    local cooldown, _, num, max = C_TradeSkillUI.GetRecipeCooldown(recipe.recipeID)

    if cooldown or ((max or 0) > 0 and num == 0) then
      self.craftable:SetText(RED_FONT_COLOR_CODE.. "On cooldown")
    else
      self.craftable:SetText("Can craft: ".. ColorNum(recipe.numAvailable))
    end

    if link then
      local stock = GetItemCount(link, true) + GetNumAuctions(link)
      self.stock:SetText("In stock: ".. ColorNum(stock))
    else
      self.stock:SetText()
    end
  else
    self.craftable:SetText()
    self.stock:SetText()
  end

  local cost, incomplete = GetReagentCost and GetReagentCost("recipe:"..recipe.recipeID)
  local reagent_price = cost and ns.GS(cost) or UNKNOWN
  if incomplete then reagent_price = "~"..reagent_price end
  self.cost:SetText(reagent_price)

  if link then
    local ah = GetAuctionBuyout and GetAuctionBuyout(link)
    local ah_price = ah and ns.GS(ah) or UNKNOWN
    self.ah:SetText(ah_price)
  else
    self.ah:SetText()
  end

  self:Show()
end


local function PreClick(self, button)
  if InCombatLockdown() then return end

  if button == "LeftButton" and (self.recipe.numAvailable > 0) then
    macro = "/run C_TradeSkillUI.CraftRecipe(".. self.recipe_id.. ")"
    if self.is_enchant then macro = macro.. "\n/use item:38682" end

    self:SetAttribute("type", "macro")
    self:SetAttribute("macrotext", macro)

  elseif button == "RightButton" or (self.recipe.numAvailable == 0) then
    macro = "/run "..
      "TradeSkillFrame.RecipeList:SetSelectedRecipeID(".. self.recipe_id.. ") "..
      "TradeSkillFrame.RecipeList:ForceRecipeIntoView(".. self.recipe_id.. ")"
    self:SetAttribute("type", "macro")
    self:SetAttribute("macrotext", macro)
  end
end


local function PostClick(self, button)
  if InCombatLockdown() then return end
  self:SetAttribute("type", nil)
  self:SetAttribute("macrotext", nil)
end


local function OnEnter(self)
  GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 0, 48)
  GameTooltip:SetHyperlink(self.link)
end


function ns.NewCraftButton(parent)
  local butt = CreateFrame("CheckButton", nil, parent, "SecureActionButtonTemplate")
  butt:SetHeight(48)

  butt.item = CreateFrame("Frame", nil, butt)
  butt.item:SetPoint("TOPLEFT")
  butt.item:SetSize(48, 48)
  butt.item:SetScript("OnEnter", OnEnter)
  butt.item:SetScript("OnLeave", GameTooltip_Hide)

  butt.icon = butt.item:CreateTexture(nil, "ARTWORK")
  butt.icon:SetAllPoints()

  butt.name = butt:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  butt.name:SetPoint("TOPLEFT", butt.item, "TOPRIGHT", 5, 0)
  butt.name:SetPoint("RIGHT", butt, -5, 0)
  butt.name:SetJustifyH("LEFT")
  butt.name:SetWordWrap(false)

  butt.craftable = butt:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
  butt.craftable:SetPoint("TOPLEFT", butt.name, "BOTTOMLEFT", 0, -4)

  butt.stock = butt:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
  butt.stock:SetPoint("TOPLEFT", butt.craftable, "BOTTOMLEFT", 0, -4)

  butt.costlabel = butt:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  butt.costlabel:SetPoint("TOP", butt.craftable)
  butt.costlabel:SetPoint("RIGHT", butt, "RIGHT", -5, 0)
  butt.costlabel:SetText("Cost")

  butt.auctionlabel = butt:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  butt.auctionlabel:SetPoint("TOPRIGHT", butt.costlabel, "BOTTOMRIGHT", 0, -4)
  butt.auctionlabel:SetText("AH")

  butt.cost = butt:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  butt.cost:SetPoint("TOPRIGHT", butt.costlabel, "TOPLEFT", -5, 0)

  butt.ah = butt:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  butt.ah:SetPoint("TOP", butt.auctionlabel)
  butt.ah:SetPoint("RIGHT", butt.cost)

  butt.SetRecipe = SetRecipe
  butt:SetScript("PreClick", PreClick)
  butt:SetScript("PostClick", PostClick)

  butt:RegisterForClicks("AnyDown")

  return butt
end
