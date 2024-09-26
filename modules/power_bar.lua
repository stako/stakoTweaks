local addonName, addon = ...
local module = addon:NewModule()

addon:RegisterEvent("ADDON_LOADED")

function module:ADDON_LOADED(name)
  if name ~= addonName then return end

  hooksecurefunc("TextStatusBar_UpdateTextStringWithValues", function(statusFrame, textString, value, valueMin, valueMax)
    if statusFrame ~= PlayerFrameManaBar then return end
    if textString:IsShown() and textString:GetText() then return end

    local powerType = UnitPowerType("player")

    if powerType == Enum.PowerType.Rage and value > 0 then
      textString:Show()
      textString:SetText(value)

      -- local rightText = statusFrame.RightText
      -- rightText:SetText(value >= 80 and "<<<" or value >= 75 and "<" or "")
      -- rightText:Show()
    elseif (powerType == Enum.PowerType.Energy or powerType == Enum.PowerType.Focus) and value < valueMax then
      textString:Show()
      textString:SetText(value)
    end
  end)

  self:BuildEnergyTicker()
end

function module:BuildEnergyTicker()
  if GetExpansionLevel() > LE_EXPANSION_BURNING_CRUSADE then return end

  local tickbar = CreateFrame("Statusbar", nil, PlayerFrameManaBar)
  tickbar:SetAllPoints()

  local spark = tickbar:CreateTexture(nil, "OVERLAY")
  spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
  spark:SetSize(32, 32)
  spark:SetPoint("CENTER")
  spark:SetBlendMode("ADD")
  spark:SetAlpha(0.6)

  local prevEnergy = 0
  local timeSinceTick = 0
  local isFull = true
  local energy = Enum.PowerType.Energy

  local function isTick(d)
    if  (d >= 19 and d <= 21) or  -- regular energy gain (sometimes 21)
        (d >= 1 and d <= 21 and isFull) or -- partial energy gain to full
        (d >= 39 and d <= 41 and playerClass == "ROGUE") or -- AR energy gain (sometimes 41)
        (d >= 1 and d <= 41 and isFull and playerClass == "ROGUE") -- AR partial energy gain to full
    then
      return true
    else
      return false
    end
  end

  tickbar:SetScript("OnEvent", function(self, event, ...)
    if event == "UNIT_POWER_UPDATE" then
      local curEnergy = UnitPower("player")
      isFull = (curEnergy == UnitPowerMax("player"))

      if isTick(curEnergy - prevEnergy) then
        timeSinceTick = 0
        if UnitPowerType("player") == energy then self:Show() end
      end

      prevEnergy = curEnergy
    elseif event == "UNIT_DISPLAYPOWER" or event == "PLAYER_ENTERING_WORLD" then
      self:SetShown(UnitPowerType("player") == energy and timeSinceTick < 2)
    end
  end)
  tickbar:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
  tickbar:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
  tickbar:RegisterEvent("PLAYER_ENTERING_WORLD")

  tickbar:SetScript("OnUpdate", function(self, elapsed)
    timeSinceTick = timeSinceTick + elapsed
    if timeSinceTick > 2 then self:Hide() end
    spark:SetPoint("CENTER", tickbar, "LEFT", timeSinceTick / 2 * self:GetWidth(), 0)
  end)
end