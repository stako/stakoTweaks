local addonName, ns = ...
local module = ns.Module:new()

module:RegisterEvent("ADDON_LOADED")
module:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")

local previousHealth = 0
local executeThreshold
local executeMessage

local castToActive = {
  ["Lock and Load"] = true
}

local blacklist = {
  ["Improved Steady Shot"] = true,
  ["Overpower"] = true,
  ["Sic 'Em!"] = true,
  ["Infusion of Light"] = true,
  ["Daybreak"] = true
}

function module:ADDON_LOADED(name)
  if name ~= "Blizzard_CombatText" then return end

  COMBAT_TEXT_TYPE_INFO["DAMAGE_CRIT"].show = nil
  COMBAT_TEXT_TYPE_INFO["DAMAGE"].show = nil
  COMBAT_TEXT_TYPE_INFO["SPELL_DAMAGE"].show = nil
  COMBAT_TEXT_TYPE_INFO["PERIODIC_HEAL"].show = nil
  COMBAT_TEXT_TYPE_INFO["HEAL_CRIT"].show = nil
  COMBAT_TEXT_TYPE_INFO["HEAL"].show = nil
  COMBAT_TEXT_TYPE_INFO["SPLIT_DAMAGE"].show = nil

  COMBAT_TEXT_TYPE_INFO["RESIST"].cvar = nil
  COMBAT_TEXT_TYPE_INFO["BLOCK"].cvar = nil
  COMBAT_TEXT_TYPE_INFO["ABSORB"].cvar = nil
  COMBAT_TEXT_TYPE_INFO["SPELL_RESIST"].cvar = nil
  COMBAT_TEXT_TYPE_INFO["SPELL_BLOCK"].cvar = nil
  COMBAT_TEXT_TYPE_INFO["SPELL_ABSORB"].cvar = nil

  COMBAT_TEXT_TYPE_INFO["ENTERING_COMBAT"] = {r = 1, g = 0.2, b = 0.2, cvar = "floatingCombatTextCombatState"}
  COMBAT_TEXT_TYPE_INFO["LEAVING_COMBAT"] = {r = 0.35, g = 0.35, b = 1, cvar = "floatingCombatTextCombatState"}
  COMBAT_TEXT_TYPE_INFO["HONOR_GAINED"] = {r = 1, g = 0.2, b = 0.2, cvar = "floatingCombatTextHonorGains"}

  COMBAT_TEXT_ENTERING_COMBAT = "++ |cFFFFFFFFCombat|r ++"
  COMBAT_TEXT_LEAVING_COMBAT = "–– |cFFFFFFFFCombat|r ––"
  COMBAT_TEXT_COMBO_POINTS = "|cFFFFFFFF<%d |rCombo |4Point:Points;|cFFFFFFFF>|r"
  HEALTH_LOW = "Low Health"
  MANA_LOW = "Low Mana"

  -- COMBAT_TEXT_HEIGHT = 20
  -- COMBAT_TEXT_CRIT_MAXHEIGHT = 50
  -- COMBAT_TEXT_CRIT_MINHEIGHT = 25
  COMBAT_TEXT_HEIGHT = 17
  COMBAT_TEXT_CRIT_MAXHEIGHT = 40
  COMBAT_TEXT_CRIT_MINHEIGHT = 22

  CombatText_UpdateDisplayedMessages = module.CombatText_UpdateDisplayedMessages
  CombatText_UpdateDisplayedMessages()

  for i=1, NUM_COMBAT_TEXT_LINES do
    font = _G["CombatText"..i]
    font:SetFontObject(CombatTextFontOutline)
  end

  CombatText:SetScript("OnEvent", self.CombatText_OnEvent)

  self:UpdateExecuteThreshold()
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

  if ns.playerClass == "ROGUE" and GetPrimaryTalentTree() == 1 then
    executeThreshold = 0.35
    executeMessage = "Backstab"
    module:RegisterUnitEvent("UNIT_HEALTH", "target")
    module:RegisterEvent("PLAYER_TARGET_CHANGED")
  elseif ns.playerClass == "PRIEST" and GetPrimaryTalentTree() == 3 then
    executeThreshold = 0.25
    executeMessage = "Death"
    module:RegisterUnitEvent("UNIT_HEALTH", "target")
    module:RegisterEvent("PLAYER_TARGET_CHANGED")
  elseif ns.playerClass == "WARLOCK" and GetPrimaryTalentTree() == 3 then
    executeThreshold = 0.2
    executeMessage = "Shadowburn"
    module:RegisterUnitEvent("UNIT_HEALTH", "target")
    module:RegisterEvent("PLAYER_TARGET_CHANGED")
  end
end

-- copied the entire default function
function module:CombatText_OnEvent(event, ...)
  if not self:IsVisible() then
    CombatText_ClearAnimationList()
    return
  end

  local arg1, data, arg3, arg4 = ...

  -- Set up the messageType
  local messageType, message
  -- Set the message data
  local displayType

  if event == "UNIT_ENTERED_VEHICLE" then
    local unit, showVehicle = ...
    if unit == "player" then
      if showVehicle then
        self.unit = "vehicle"
      else
        self.unit = "player"
      end
      CombatTextSetActiveUnit(self.unit)
    end
    return
  elseif event == "UNIT_EXITING_VEHICLE" then
    if arg1 == "player" then
      self.unit = "player"
      CombatTextSetActiveUnit(self.unit)
    end
    return
  elseif event == "UNIT_HEALTH" then
    if arg1 == self.unit then
      if UnitHealth(self.unit)/UnitHealthMax(self.unit) <= COMBAT_TEXT_LOW_HEALTH_THRESHOLD then
        if not CombatText.lowHealth then
          messageType = "HEALTH_LOW"
          CombatText.lowHealth = 1
        end
      else
        CombatText.lowHealth = nil
      end
    end

    -- Didn't meet any of the criteria so just return
    if not messageType then
      return
    end
  elseif event == "UNIT_POWER_UPDATE" then
    if arg1 == self.unit then
      local powerType, powerToken = UnitPowerType(self.unit)
      local maxPower = UnitPowerMax(self.unit)
      local currentPower = UnitPower(self.unit)
      if maxPower ~= 0 and powerToken == "MANA" and (currentPower / maxPower) <= COMBAT_TEXT_LOW_MANA_THRESHOLD then
        if not CombatText.lowMana then
          messageType = "MANA_LOW"
          CombatText.lowMana = 1
        end
      else
        CombatText.lowMana = nil
      end
      if data == "COMBO_POINTS" then
        local comboPoints = GetComboPoints("player", "target")
        if comboPoints > 0 then
          messageType = "COMBO_POINTS"
          data = comboPoints
          -- Show message as a crit if max combo points
          if comboPoints == MAX_COMBO_POINTS then
            displayType = "crit"
          end
        else
          return
        end
      end
    end

    -- Didn't meet any of the criteria so just return
    if not messageType then
      return
    end
  elseif event == "PLAYER_REGEN_DISABLED" then
    messageType = "ENTERING_COMBAT"
  elseif event == "PLAYER_REGEN_ENABLED" then
    messageType = "LEAVING_COMBAT"
  elseif event == "COMBAT_TEXT_UPDATE" then
    data, arg3, arg4 = GetCurrentCombatTextEventInfo()
    messageType = arg1
    if messageType == "SPELL_CAST" then
      if castToActive[data] then
        messageType = "SPELL_ACTIVE"
      elseif blacklist[data] then
        return
      end
    elseif messageType == "SPELL_ACTIVE" and blacklist[data] then
      return
    end
  elseif event == "RUNE_POWER_UPDATE" then
    messageType = "RUNE"
  else
    messageType = event
  end

  -- Process the messageType and format the message
  -- Check to see if there's a COMBAT_TEXT_TYPE_INFO associated with this combat message
  local info = COMBAT_TEXT_TYPE_INFO[messageType]
  if not info then
    info = {r = 1, g =1, b = 1}
  end
  -- See if we should display the message or not
  if not info.show then
    -- When Resists aren't being shown, partial resists should display as Damage
    if info.cvar == "floatingCombatTextDamageReduction" and arg3 then
      if strsub(messageType, 1, 5) == "SPELL" then
        messageType = arg4 and "SPELL_DAMAGE_CRIT" or "SPELL_DAMAGE"
      else
        messageType = arg4 and "DAMAGE_CRIT" or "DAMAGE"
      end
    else
      return
    end
  end

  local isStaggered = info.isStaggered
  if messageType == "" then

  elseif messageType == "DAMAGE_CRIT" or messageType == "SPELL_DAMAGE_CRIT" then
    displayType = "crit"
    message = "-"..BreakUpLargeNumbers(data)
  elseif messageType == "DAMAGE" or messageType == "SPELL_DAMAGE" or messageType == "DAMAGE_SHIELD" then
    if data == 0 then
      return
    end
    message = "-"..BreakUpLargeNumbers(data)
  elseif messageType == "SPELL_CAST" then
    message = "<"..data..">"
  elseif messageType == "SPELL_AURA_START" then
    message = "<"..data..">"
  elseif messageType == "SPELL_AURA_START_HARMFUL" then
    message = "<"..data..">"
  elseif messageType == "SPELL_AURA_END" or messageType == "SPELL_AURA_END_HARMFUL" then
    message = format(AURA_END, data)
  elseif messageType == "HEAL" or messageType == "PERIODIC_HEAL" then
    if CVarCallbackRegistry:GetCVarValueBool("floatingCombatTextFriendlyHealers") and messageType == "HEAL" and UnitName(self.unit) ~= data then
      message = "+"..BreakUpLargeNumbers(arg3).." ["..data.."]"
    else
      message = "+"..BreakUpLargeNumbers(arg3)
    end
  elseif messageType == "HEAL_ABSORB" or messageType == "PERIODIC_HEAL_ABSORB" then
    if CVarCallbackRegistry:GetCVarValueBool("floatingCombatTextFriendlyHealers") and messageType == "HEAL_ABSORB" and UnitName(self.unit) ~= data then
      message = "+"..BreakUpLargeNumbers(arg3).." ["..data.."] "..format(ABSORB_TRAILER, arg4)
    else
      message = "+"..BreakUpLargeNumbers(arg3).." "..format(ABSORB_TRAILER, arg4)
    end
  elseif messageType == "HEAL_CRIT" or messageType == "PERIODIC_HEAL_CRIT" then
    displayType = "crit"
    if CVarCallbackRegistry:GetCVarValueBool("floatingCombatTextFriendlyHealers") and UnitName(self.unit) ~= data then
      message = "+"..BreakUpLargeNumbers(arg3).." ["..data.."]"
    else
      message = "+"..BreakUpLargeNumbers(arg3)
    end
  elseif messageType == "HEAL_CRIT_ABSORB" then
    displayType = "crit"
    if CVarCallbackRegistry:GetCVarValueBool("floatingCombatTextFriendlyHealers") and UnitName(self.unit) ~= data then
      message = "+"..BreakUpLargeNumbers(arg3).." ["..data.."] "..format(ABSORB_TRAILER, arg4)
    else
      message = "+"..BreakUpLargeNumbers(arg3).." "..format(ABSORB_TRAILER, arg4)
    end
  elseif messageType == "ENERGIZE" then
    local count =  tonumber(data)
    if count > 0 then
      data = "+"..BreakUpLargeNumbers(data)
    else
      return --If we didnt actually gain anything, dont show it
    end
    if arg3 == "MANA"
      or arg3 == "RAGE"
      or arg3 == "FOCUS"
      or arg3 == "ENERGY"
      or arg3 == "RUNIC_POWER"
      or arg3 == "DEMONIC_FURY" then
      message = "|cFFFFFFFF"..data.."|r ".._G[arg3]
      info = PowerBarColor[arg3]
    elseif arg3 == "HOLY_POWER"
        or arg3 == "SOUL_SHARDS"
        or arg3 == "CHI"
        or arg3 == "COMBO_POINTS"
        or arg3 == "ARCANE_CHARGES" then
      local numPower = UnitPower"player" , GetPowerEnumFromEnergizeString(arg3)
      message = "|cFFFFFFFF<"..numPower.."|r ".._G[arg3].."|cFFFFFFFF>|r"
      info = PowerBarColor[arg3]
      --Display as crit if we're at max power
      if UnitPower("player" , GetPowerEnumFromEnergizeString(arg3)) == UnitPowerMax(self.unit, GetPowerEnumFromEnergizeString(arg3)) then
        displayType = "crit"
      end
    end
  elseif messageType == "FACTION" then
    if tonumber(arg3) > 0 then
      arg3 = "+"..arg3
    end
    message = "("..data.." "..arg3..")"
  elseif messageType == "SPELL_MISS" then
    message = COMBAT_TEXT_MISS
  elseif messageType == "SPELL_DODGE" then
    message = COMBAT_TEXT_DODGE
  elseif messageType == "SPELL_PARRY" then
    message = COMBAT_TEXT_PARRY
  elseif messageType == "SPELL_EVADE" then
    message = COMBAT_TEXT_EVADE
  elseif messageType == "SPELL_IMMUNE" then
    message = COMBAT_TEXT_IMMUNE
  elseif messageType == "SPELL_DEFLECT" then
    message = COMBAT_TEXT_DEFLECT
  elseif messageType == "SPELL_REFLECT" then
    message = COMBAT_TEXT_REFLECT
  elseif messageType == "BLOCK" or messageType == "SPELL_BLOCK" then
    if arg3 then
      -- Partial block
      message = "-"..data.." "..format(BLOCK_TRAILER, arg3)
    else
      message = COMBAT_TEXT_BLOCK
    end
  elseif messageType == "ABSORB" or messageType == "SPELL_ABSORB" then
    if arg3 and data > 0 then
      -- Partial absorb
      message = "-"..data.." "..format(ABSORB_TRAILER, arg3)
    else
      message = COMBAT_TEXT_ABSORB
    end
  elseif messageType == "RESIST" or messageType == "SPELL_RESIST" then
    if arg3 then
      -- Partial resist
      message = "-"..data.." "..format(RESIST_TRAILER, arg3)
    else
      message = COMBAT_TEXT_RESIST
    end
  elseif messageType == "HONOR_GAINED" then
    data = tonumber(data)
    if not data or abs(data) < 1 then
      return
    end
    data = floor(data)
    if data > 0 then
      data = "|cFFFFFFFF+"..data.."|r"
    end
    message = format(COMBAT_TEXT_HONOR_GAINED, data)
  elseif messageType == "SPELL_ACTIVE" then
    displayType = "crit"
    message = "<"..data..">"
  elseif messageType == "COMBO_POINTS" then
    message = format(COMBAT_TEXT_COMBO_POINTS, data)
    info = PowerBarColor["COMBO_POINTS"]
  elseif messageType == "RUNE" then
    if data == true then
      message = COMBAT_TEXT_RUNE_DEATH
    else
      message = nil
    end
  elseif messageType == "ABSORB_ADDED" then
    if CVarCallbackRegistry:GetCVarValueBool("floatingCombatTextFriendlyHealers") and UnitName(self.unit) ~= data then
      message = "+"..BreakUpLargeNumbers(arg3).."("..COMBAT_TEXT_ABSORB..")".." ["..data.."]"
    else
      message = "+"..BreakUpLargeNumbers(arg3).."("..COMBAT_TEXT_ABSORB..")"
    end
  else
    message = _G["COMBAT_TEXT_"..messageType]
    if not message then
      message = _G[messageType]
    end
  end

  -- Add the message
  if message then
    CombatText_AddMessage(message, COMBAT_TEXT_SCROLL_FUNCTION, info.r, info.g, info.b, displayType, isStaggered)
  end
end

function module.CombatText_UpdateDisplayedMessages()
	-- set the unit to track
	CombatText.unit = "player"
	CombatTextSetActiveUnit("player")

	-- Get scale
	COMBAT_TEXT_Y_SCALE = WorldFrame:GetHeight() / 768
	COMBAT_TEXT_X_SCALE = WorldFrame:GetWidth() / 1024
	COMBAT_TEXT_SPACING = 10 * COMBAT_TEXT_Y_SCALE
	COMBAT_TEXT_MAX_OFFSET = 130 * COMBAT_TEXT_Y_SCALE
	COMBAT_TEXT_X_ADJUSTMENT = 80 * COMBAT_TEXT_X_SCALE

	-- Update shown messages
	for index, value in pairs(COMBAT_TEXT_TYPE_INFO) do
		if ( value.cvar ) then
			if ( CVarCallbackRegistry:GetCVarValueBool(value.cvar) ) then
				value.show = 1
			else
				value.show = nil
			end
		end
	end
	-- Update scrolldirection
	local textFloatMode = CVarCallbackRegistry:GetCVarValue("floatingCombatTextFloatMode")
	if ( textFloatMode == "1" ) then
		COMBAT_TEXT_SCROLL_FUNCTION = CombatText_StandardScroll
		COMBAT_TEXT_LOCATIONS = {
			startX = 0,
			startY = 384 * COMBAT_TEXT_Y_SCALE,
			endX = 0,
			endY = 609 * COMBAT_TEXT_Y_SCALE
		}

	elseif ( textFloatMode == "2" ) then
		COMBAT_TEXT_SCROLL_FUNCTION = CombatText_StandardScroll
		COMBAT_TEXT_LOCATIONS = {
			startX = 0,
			startY = 448 * COMBAT_TEXT_Y_SCALE,
			endX = 0,
			endY =  223 * COMBAT_TEXT_Y_SCALE
		}
	else
		COMBAT_TEXT_SCROLL_FUNCTION = CombatText_FountainScroll
		COMBAT_TEXT_LOCATIONS = {
			startX = 0,
			startY = 384 * COMBAT_TEXT_Y_SCALE,
			endX = 0,
			endY = 609 * COMBAT_TEXT_Y_SCALE
		}
	end
	CombatText_ClearAnimationList()
end
