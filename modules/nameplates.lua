local addonName, addon = ...
local module = addon:NewModule()

addon:RegisterEvent("ADDON_LOADED")

function module:ADDON_LOADED(name)
  if name ~= addonName then return end

  hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
    local nameplate = C_NamePlate.GetNamePlateForUnit(frame.unit, false)
    if not nameplate then return end

    local name = nameplate.UnitFrame.name

    if UnitIsUnit(frame.unit, "target") then
      name:SetVertexColor(1, 1, 1, 1)
      name:SetFontObject(Game12Font_o1)
    else
      name:SetFontObject(SystemFont_LargeNamePlate)
    end
  end)

  hooksecurefunc("Nameplate_CastBar_AdjustPosition", function(self)
    self.Text:Show()
  end)
end