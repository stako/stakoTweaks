local addonName, ns = ...
local module = ns.Module:new()

module:RegisterEvent("ADDON_LOADED")

function module:ADDON_LOADED(name)
  if name ~= addonName then return end

  hooksecurefunc("TextStatusBar_UpdateTextStringWithValues", function(statusFrame, textString, value, valueMin, valueMax)
    if statusFrame ~= PlayerFrameManaBar then return end
    if textString:IsShown() and textString:GetText() then return end

    local powerType = UnitPowerType("player")

    if powerType == Enum.PowerType.Rage and value > 0 then
      textString:Show()
      textString:SetText(value)
    elseif (powerType == Enum.PowerType.Energy or powerType == Enum.PowerType.Focus) and value < valueMax then
      textString:Show()
      textString:SetText(value)
    end
  end)

  self:BuildEnergyTicker()
  self:BuildHATTicker()
end

function module:BuildEnergyTicker()
  if WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC and WOW_PROJECT_ID ~= WOW_PROJECT_BURNING_CRUSADE_CLASSIC then return end

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

function module:BuildHATTicker()
  if ns.playerClass ~= "ROGUE" then return end

  local tickbar = CreateFrame("Statusbar", nil, PlayerFrameManaBar)
  tickbar:SetAllPoints()

  local spark = tickbar:CreateTexture(nil, "OVERLAY")
  spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
  spark:SetSize(32, 32)
  spark:SetPoint("CENTER")
  spark:SetBlendMode("ADD")
  spark:SetAlpha(0.75)
  spark:Hide()

  local width = tickbar:GetWidth()
  local startTime = 0
  local GetTime = GetTime

  local function updateTicker(self, elapsed)
    local timeSinceProc = GetTime() - startTime
    if timeSinceProc >= 2 then
      self:SetScript("OnUpdate", nil)
      spark:Hide()
    else
      spark:Show()
      spark:SetPoint("CENTER", self, "LEFT", timeSinceProc / 2 * width, 0)
    end
  end

  tickbar:SetScript("OnEvent", function(self)
    local start = GetSpellCooldown(51699)
    if start > 0 then
      startTime = start
      self:SetScript("OnUpdate", updateTicker)
    end
  end)

  tickbar:RegisterEvent("SPELL_UPDATE_COOLDOWN")
end
