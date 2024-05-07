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

  COMBAT_TEXT_TYPE_INFO["RESIST"].show = nil
  COMBAT_TEXT_TYPE_INFO["BLOCK"].show = nil
  COMBAT_TEXT_TYPE_INFO["ABSORB"].show = nil
  COMBAT_TEXT_TYPE_INFO["SPELL_RESIST"].show = nil
  COMBAT_TEXT_TYPE_INFO["SPELL_BLOCK"].show = nil
  COMBAT_TEXT_TYPE_INFO["SPELL_ABSORB"].show = nil

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

  CombatText:SetScript("OnEvent", self.CombatText_OnEvent)
end

function module:UNIT_HEALTH(unit)
  if executeThreshold == nil or unit ~= "target" or UnitCanAttack("player", unit) == false then return end

  local value, max = UnitHealth(unit), UnitHealthMax(unit)
  if value == 0 then return end

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
    executeMessage = "Backstab"
    addon:RegisterUnitEvent("UNIT_HEALTH", "target")
    addon:RegisterEvent("PLAYER_TARGET_CHANGED")
  end
end

function module:CombatText_OnEvent(event, ...)
	if not self:IsVisible() then
		CombatText_ClearAnimationList()
		return
	end

	local arg1, data, arg3, arg4 = ...
	local messageType, message
	local displayType

  messageType = arg1
	if event ~= "COMBAT_TEXT_UPDATE" or messageType ~= "ENERGIZE" then
    CombatText_OnEvent(self, event, ...)
    return
  end

	data, arg3, arg4 = GetCurrentCombatTextEventInfo()
	local info = COMBAT_TEXT_TYPE_INFO[messageType]
	if not info.show then return end


  local count =  tonumber(data)
  if (count > 0 ) then
    data = "+"..BreakUpLargeNumbers(data)
  else
    return
  end
  if( arg3 == "MANA"
    or arg3 == "RAGE"
    or arg3 == "FOCUS"
    or arg3 == "ENERGY"
    or arg3 == "RUNIC_POWER"
    or arg3 == "DEMONIC_FURY") then
    message = "|cFFFFFFFF"..data.."|r ".._G[arg3]
  elseif ( arg3 == "HOLY_POWER"
      or arg3 == "SOUL_SHARDS"
      or arg3 == "CHI"
      or arg3 == "COMBO_POINTS"
      or arg3 == "ARCANE_CHARGES" ) then
    local numPower = UnitPower( "player" , GetPowerEnumFromEnergizeString(arg3) )
    message = "|cFFFFFFFF<"..numPower.."|r ".._G[arg3].."|cFFFFFFFF>|r"
    if ( UnitPower( "player" , GetPowerEnumFromEnergizeString(arg3)) == UnitPowerMax(self.unit, GetPowerEnumFromEnergizeString(arg3))) then
      displayType = "crit"
    end
	end

  info = PowerBarColor[arg3]
	CombatText_AddMessage(message, COMBAT_TEXT_SCROLL_FUNCTION, info.r, info.g, info.b, displayType, false)
end

module:UpdateExecuteThreshold()
