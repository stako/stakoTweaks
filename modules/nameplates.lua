local addonName, addon = ...
local module = addon:NewModule()

addon:RegisterEvent("ADDON_LOADED")

function module:ADDON_LOADED(name)
  if name ~= addonName then return end

  hooksecurefunc(NamePlateDriverFrame, "AcquireUnitFrame", self.AcquireUnitFrame)
  hooksecurefunc("Nameplate_CastBar_AdjustPosition", self.Nameplate_CastBar_AdjustPosition)

  DefaultCompactNamePlateEnemyFrameOptions.selectedBorderColor = CreateColor(1, 1, 1, 0.8)
end

function module:AcquireUnitFrame(namePlateFrameBase)
  local unitFrame = namePlateFrameBase.UnitFrame
  if unitFrame:IsForbidden() then
    unitFrame.UpdateNameOverride = nil
    unitFrame.UpdateHealthBorderOverride = nil
  else
    unitFrame.UpdateNameOverride = module.UpdateNameOverride
    unitFrame.UpdateHealthBorderOverride = module.UpdateHealthBorderOverride
    module:TweakFrame(unitFrame)
  end
end

function module.UpdateNameOverride(frame)
  local name = frame.name

  if UnitIsUnit(frame.unit, "target") then
    name:Show()
    name:SetText(GetUnitName(frame.unit, true))
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

function module:TweakFrame(unitFrame)
  if unitFrame.stakoTweaked then return end

  unitFrame.stakoTweaked = true

  local healthBar = unitFrame.healthBar
  healthBar.border:Hide()
  unitFrame.stakoBorder = CreateFrame("Frame", nil, healthBar, "stakoNamePlateFullBorderTemplate")
  self.UpdateSizes(unitFrame.stakoBorder)

  local castText = unitFrame.CastBar.Text
  castText:ClearAllPoints()
  castText:SetPoint("TOPLEFT", 0, 5)
  castText:SetPoint("TOPRIGHT", 0, 5)
end

function module.UpdateHealthBorderOverride(frame)
  if frame.optionTable.selectedBorderColor and UnitIsUnit(frame.displayedUnit, "target") then
    for i, texture in ipairs(frame.stakoBorder.Textures) do
      texture:SetVertexColor(frame.optionTable.selectedBorderColor:GetRGBA())
    end
    return true
  end

  if frame.optionTable.defaultBorderColor then
    for i, texture in ipairs(frame.stakoBorder.Textures) do
      texture:SetVertexColor(frame.optionTable.defaultBorderColor:GetRGBA())
    end
    return true
  end
end

function module:UpdateSizes()
  local borderSize = self.borderSize or 1
  local minPixels = self.borderSizeMinPixels or 2

  local upwardExtendHeightPixels = self.upwardExtendHeightPixels or borderSize
  local upwardExtendHeightMinPixels = self.upwardExtendHeightMinPixels or minPixels

  PixelUtil.SetWidth(self.Left, borderSize, minPixels)
  PixelUtil.SetPoint(self.Left, "TOPRIGHT", self, "TOPLEFT", 0, upwardExtendHeightPixels, 0, upwardExtendHeightMinPixels)
  PixelUtil.SetPoint(self.Left, "BOTTOMRIGHT", self, "BOTTOMLEFT", 0, -borderSize, 0, minPixels)

  PixelUtil.SetWidth(self.Right, borderSize, minPixels)
  PixelUtil.SetPoint(self.Right, "TOPLEFT", self, "TOPRIGHT", 0, upwardExtendHeightPixels, 0, upwardExtendHeightMinPixels)
  PixelUtil.SetPoint(self.Right, "BOTTOMLEFT", self, "BOTTOMRIGHT", 0, -borderSize, 0, minPixels)

  PixelUtil.SetHeight(self.Bottom, borderSize, minPixels)
  PixelUtil.SetPoint(self.Bottom, "TOPLEFT", self, "BOTTOMLEFT", 0, 0)
  PixelUtil.SetPoint(self.Bottom, "TOPRIGHT", self, "BOTTOMRIGHT", 0, 0)

  if self.Top then
    PixelUtil.SetHeight(self.Top, borderSize, minPixels)
    PixelUtil.SetPoint(self.Top, "BOTTOMLEFT", self, "TOPLEFT", 0, 0)
    PixelUtil.SetPoint(self.Top, "BOTTOMRIGHT", self, "TOPRIGHT", 0, 0)
  end
end