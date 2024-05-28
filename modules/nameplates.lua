local addonName, addon = ...
local module = addon:NewModule()

addon:RegisterEvent("ADDON_LOADED")

function module:ADDON_LOADED(name)
  if name ~= addonName then return end

  hooksecurefunc(NamePlateDriverFrame, "AcquireUnitFrame", self.AcquireUnitFrame)
  hooksecurefunc("Nameplate_CastBar_AdjustPosition", self.Nameplate_CastBar_AdjustPosition)
end

function module:AcquireUnitFrame(namePlateFrameBase)
  local unitFrame = namePlateFrameBase.UnitFrame
  unitFrame.UpdateNameOverride = module.UpdateNameOverride
end

function module.UpdateNameOverride(frame)
  local name = frame.name

  if UnitIsUnit(frame.unit, "target") then
    name:Show()
    name:SetText(GetUnitName(frame.unit, false))
    name:SetVertexColor(1, 1, 1, 1)
    name:SetFontObject(Game12Font_o1)
    return true
  else
    name:SetFontObject(SystemFont_LargeNamePlate)
  end
end

function module.Nameplate_CastBar_AdjustPosition(castBar)
  if not castBar:IsForbidden() then castBar.Text:Show() end
end