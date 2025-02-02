local addonName, ns = ...
local module = ns.Module:new()

local powerSparkData = {
  ["PRIEST"] = {spellId = 47755, talent = {1, 11}},
  ["ROGUE"] = {spellId = 51699, talent = {3, 12}},
}

module:RegisterEvent("ADDON_LOADED")

function module:ADDON_LOADED(name)
  if name ~= addonName then return end

  hooksecurefunc("TextStatusBar_UpdateTextStringWithValues", self.UpdatePowerBarText)
  self:SetUpEnergyTicker()
  self:SetUpPowerSpark()
end

function module.UpdatePowerBarText(statusFrame, textString, value, valueMin, valueMax)
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
end

function module:BuildTicker()
  local ticker = CreateFrame("Frame", nil, PlayerFrameManaBar)
  ticker:SetAllPoints()
  ticker:Hide()

  local spark = ticker:CreateTexture(nil, "OVERLAY")
  spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
  spark:SetSize(32, 32)
  spark:SetPoint("CENTER")
  spark:SetBlendMode("ADD")
  spark:SetAlpha(0.65)
  ticker.spark = spark

  return ticker
end

function module:SetUpEnergyTicker()
  if WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC and WOW_PROJECT_ID ~= WOW_PROJECT_BURNING_CRUSADE_CLASSIC then return end
  if ns.playerClass ~= "ROGUE" and ns.playerClass ~= "DRUID" then return end

  local ticker = self:BuildTicker()
  local width = ticker:GetWidth()
  local prevEnergy = 0
  local timeSinceTick = 0
  local isFull = true
  local energy = Enum.PowerType.Energy

  local function isTick(d)
    if  (d >= 19 and d <= 21) or  -- regular energy gain (sometimes 21)
        (d >= 1 and d <= 21 and isFull) or -- partial energy gain to full
        (d >= 39 and d <= 41 and ns.playerClass == "ROGUE") or -- AR energy gain (sometimes 41)
        (d >= 1 and d <= 41 and isFull and ns.playerClass == "ROGUE") -- AR partial energy gain to full
    then
      return true
    else
      return false
    end
  end

  ticker:SetScript("OnUpdate", function(self, elapsed)
    timeSinceTick = timeSinceTick + elapsed
    if timeSinceTick > 2 then self:Hide() return end
    self.spark:SetPoint("CENTER", self, "LEFT", timeSinceTick / 2 * width, 0)
  end)

  ticker:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
  ticker:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
  ticker:RegisterEvent("PLAYER_ENTERING_WORLD")

  ticker:SetScript("OnEvent", function(self, event, ...)
    if event == "UNIT_POWER_UPDATE" then
      local curEnergy = UnitPower("player")
      isFull = (curEnergy == UnitPowerMax("player"))

      if isTick(curEnergy - prevEnergy) then
        timeSinceTick = 0
        if UnitPowerType("player") == energy then self:Show() end
      end

      prevEnergy = curEnergy
    else
      self:SetShown(UnitPowerType("player") == energy and timeSinceTick < 2)
    end
  end)
end

function module:SetUpPowerSpark()
  if WOW_PROJECT_ID ~= WOW_PROJECT_CATACLYSM_CLASSIC then return end
  if not powerSparkData[ns.playerClass] then return end

  local spellId = powerSparkData[ns.playerClass].spellId
  local talent = powerSparkData[ns.playerClass].talent
  local ticker = self:BuildTicker()
  local width = ticker:GetWidth()
  local startTime = 0
  local timeSinceProc = 0
  local cooldown = 0
  local GetTime = GetTime

  ticker:SetScript("OnUpdate", function(self, elapsed)
    timeSinceProc = GetTime() - startTime
    if timeSinceProc > cooldown then self:Hide() return end
    self.spark:SetPoint("CENTER", self, "LEFT", timeSinceProc / cooldown * width, 0)
  end)

  ticker:RegisterEvent("PLAYER_ENTERING_WORLD")
  ticker:RegisterEvent("PLAYER_TALENT_UPDATE")

  ticker:SetScript("OnEvent", function(self, event)
    if event == "SPELL_UPDATE_COOLDOWN" then
      local start, cd = GetSpellCooldown(spellId)
      if start > 0 then
        startTime = start
        cooldown = cd
        ticker:Show()
      end
    else
      local _, _, _, _, rank = GetTalentInfo(unpack(talent))

      if rank > 0 then
        self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
      else
        self:UnregisterEvent("SPELL_UPDATE_COOLDOWN")
      end
    end
  end)
end
