local addonName, addon = ...
if addon.playerClass ~= "HUNTER" then return end
local module = addon:NewModule()

local text = UIParent:CreateFontString(nil, "OVERLAY", "SystemFont_Huge1_Outline")
text:SetPoint("CENTER", 0, -55)
text:SetText("|T132369:14|t Auto Shot Disabled |T132369:14|t")
text:Hide()
module.text = text

addon:RegisterEvent("START_AUTOREPEAT_SPELL")
addon:RegisterEvent("PLAYER_REGEN_ENABLED")
addon:RegisterEvent("STOP_AUTOREPEAT_SPELL")

function module:START_AUTOREPEAT_SPELL()
  self.text:Hide()
end

function module:PLAYER_REGEN_ENABLED()
  self.text:Hide()
end

function module:STOP_AUTOREPEAT_SPELL()
  local _, instanceType = IsInInstance()
  if instanceType ~= "party" and instanceType ~= "raid" then return end

  self.text:SetShown(InCombatLockdown())
end
