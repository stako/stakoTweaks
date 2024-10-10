local addonName, ns = ...
if ns.playerClass ~= "ROGUE" and ns.playerClass ~= "DRUID" then return end

local module = ns.Module:new()

local comboText = TargetFrameTextureFrame:CreateFontString(nil, "OVERLAY", "stakoComboFont")
comboText:SetPoint("LEFT", PlayerFrame, "RIGHT", 2, 10)

module:RegisterEvent("ADDON_LOADED")

function module:ADDON_LOADED(name)
  if name ~= addonName then return end

  hooksecurefunc("ComboFrame_Update", module.ComboFrame_Update)
end

function module.ComboFrame_Update(comboFrame)
  local comboPoints = GetComboPoints(comboFrame.unit, "target")
  comboText:SetText(comboPoints > 0 and comboPoints or "")
end