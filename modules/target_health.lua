local addonName, addon = ...
local module = addon:NewModule()

addon:RegisterEvent("ADDON_LOADED")

function module:ADDON_LOADED(name)
  if name ~= addonName then return end

  hooksecurefunc("TextStatusBar_UpdateTextStringWithValues", function(statusFrame, textString, value, valueMin, valueMax)
    if statusFrame ~= TargetFrameHealthBar then return end
    if textString:IsShown() and textString:GetText() then return end
    if value == valueMax or value == valueMin then return end

    local valueDisplay = math.ceil((value / valueMax) * 100)
    if valueDisplay > 99 then return end

    textString:Show()
    textString:SetText(valueDisplay .. "%")
  end)
end