local addonName, addon = ...
if addon.playerClass ~= "HUNTER" then return end
local module = addon:NewModule()

local autoShotDisabled = true
local inCombat = false
local inZone = false

local text = UIParent:CreateFontString(nil, "OVERLAY", "SystemFont_Huge1_Outline")
text:SetPoint("CENTER", 0, -55)
text:SetText("|T132369:14|t Auto Shot Disabled |T132369:14|t")
text:Hide()
module.text = text

addon:RegisterEvent("PLAYER_ENTERING_WORLD")
addon:RegisterEvent("START_AUTOREPEAT_SPELL")
addon:RegisterEvent("PLAYER_REGEN_ENABLED")
addon:RegisterEvent("PLAYER_REGEN_DISABLED")
addon:RegisterEvent("STOP_AUTOREPEAT_SPELL")

function module:PLAYER_ENTERING_WORLD()
  local _, instanceType = IsInInstance()
  inZone = (instanceType == "party" or instanceType == "raid")
  self:UpdateVisibility()
end

function module:START_AUTOREPEAT_SPELL()
  autoShotDisabled = false
  self:UpdateVisibility()
end

function module:PLAYER_REGEN_ENABLED()
  inCombat = false
  self:UpdateVisibility()
end

function module:PLAYER_REGEN_DISABLED()
  inCombat = true
  self:UpdateVisibility()
end

function module:STOP_AUTOREPEAT_SPELL()
  autoShotDisabled = true
  self:UpdateVisibility()
end

function module:UpdateVisibility()
  self.text:SetShown(autoShotDisabled and inCombat and inZone)
end
