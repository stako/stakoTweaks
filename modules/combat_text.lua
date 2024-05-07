local addonName, addon = ...
local module = addon:NewModule()

addon:RegisterEvent("ADDON_LOADED")
addon:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")

local previousHealth
local executeThreshold
local executeMessage

function module:ADDON_LOADED(name)
  if name ~= "Blizzard_CombatText" then return end

  COMBAT_TEXT_TYPE_INFO["DAMAGE_CRIT"].show = nil
  COMBAT_TEXT_TYPE_INFO["DAMAGE"].show = nil
  COMBAT_TEXT_TYPE_INFO["SPELL_DAMAGE"].show = nil
  COMBAT_TEXT_TYPE_INFO["PERIODIC_HEAL"].show = nil
  -- COMBAT_TEXT_TYPE_INFO["SPELL_CAST"].show = nil
  COMBAT_TEXT_TYPE_INFO["HEAL_CRIT"].show = nil
  COMBAT_TEXT_TYPE_INFO["HEAL"].show = nil
  -- COMBAT_TEXT_TYPE_INFO["SPLIT_DAMAGE"].show = nil

  COMBAT_TEXT_TYPE_INFO["RESIST"] = {r = 1, g = 0.1, b = 0.1, show = nil}
  COMBAT_TEXT_TYPE_INFO["BLOCK"] = {r = 1, g = 0.1, b = 0.1, show = nil}
  COMBAT_TEXT_TYPE_INFO["ABSORB"] = {r = 1, g = 0.1, b = 0.1, show = nil}
  COMBAT_TEXT_TYPE_INFO["SPELL_RESIST"] = {r = 0.79, g = 0.3, b = 0.85, show = nil}
  COMBAT_TEXT_TYPE_INFO["SPELL_BLOCK"] = {r = 1, g = 1, b = 1, show = nil}
  COMBAT_TEXT_TYPE_INFO["SPELL_ABSORB"] = {r = 0.79, g = 0.3, b = 0.85, show = nil}

  COMBAT_TEXT_TYPE_INFO["ENERGIZE"] = {r = 0.1, g = 0.55, b = 1, cvar = "floatingCombatTextEnergyGains"}
  COMBAT_TEXT_TYPE_INFO["ENTERING_COMBAT"] = {r = 1, g = 0.1, b = 0.19, cvar = "floatingCombatTextCombatState"}
  COMBAT_TEXT_TYPE_INFO["LEAVING_COMBAT"] = {r = 0.1, g = 1, b = 0.19, cvar = "floatingCombatTextCombatState"}

  COMBAT_TEXT_ENTERING_COMBAT = "++ |cFFFFFFFFCombat|r ++"
  COMBAT_TEXT_LEAVING_COMBAT = "–– |cFFFFFFFFCombat|r ––"
  HEALTH_LOW = "Low Health"

  COMBAT_TEXT_HEIGHT = 20
  COMBAT_TEXT_CRIT_MAXHEIGHT = 50
  COMBAT_TEXT_CRIT_MINHEIGHT = 25

  for i=1, NUM_COMBAT_TEXT_LINES do
    font = _G["CombatText"..i]
    font:SetFontObject(CombatTextFontOutline)
  end
end

function module:UNIT_HEALTH(unit)
  if executeThreshold == nil or unit ~= "target" or UnitCanAttack("player", unit) == false then return end

  local value, max = UnitHealth(unit), UnitHealthMax(unit)
  local threshold = max * executeThreshold

  if (previousHealth == 0 or previousHealth > threshold) and value < threshold then
    CombatText_OnEvent(CombatText, "SPELL_ACTIVE", nil, executeMessage)
  end

  previousHealth = value
end

function module:PLAYER_TARGET_CHANGED()
  previousHealth = 0
  self:UNIT_HEALTH("target")
end

function module:ACTIVE_TALENT_GROUP_CHANGED()
  self:UpdateExecuteThreshold()
end

function module:UpdateExecuteThreshold()
  executeThreshold = nil
  executeMessage = nil

  if addon.playerClass == "ROGUE" and GetPrimaryTalentTree() == 1 then
    executeThreshold = 0.35
    executeMessage = "Backstab!"
    addon:RegisterUnitEvent("UNIT_HEALTH", "target")
    addon:RegisterEvent("PLAYER_TARGET_CHANGED")
  end
end

module:UpdateExecuteThreshold()
