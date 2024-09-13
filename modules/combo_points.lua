local addonName, addon = ...
local module = addon:NewModule()

addon:RegisterEvent("ADDON_LOADED")

function module:ADDON_LOADED(name)
  if name ~= addonName then return end
  if addon.playerClass ~= "ROGUE" and addon.playerClass ~= "DRUID" then return end

  local comboText = TargetFrameTextureFrame:CreateFontString(nil, "OVERLAY", "NumberFontNormalHuge")
  comboText:SetPoint("LEFT", TargetFrame, "RIGHT", -24, 8)
  comboText:SetTextColor(1, 1, 0)
  self.comboText = comboText

  hooksecurefunc("ComboFrame_Update", module.ComboFrame_Update)
end

function module.ComboFrame_Update(comboFrame)
  local comboPoints = GetComboPoints(comboFrame.unit, "target")
  module.comboText:SetText(comboPoints > 0 and comboPoints or "")
end