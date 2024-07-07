local addonName, addon = ...
local module = addon:NewModule()

addon:RegisterEvent("ADDON_LOADED")

function module:ADDON_LOADED(name)
  if name ~= addonName then return end

  hooksecurefunc(NamePlateDriverFrame, "AcquireUnitFrame", self.AcquireUnitFrame)
  hooksecurefunc("Nameplate_CastBar_AdjustPosition", self.Nameplate_CastBar_AdjustPosition)

  DefaultCompactNamePlateEnemyFrameOptions.selectedBorderColor = CreateColor(1, 1, 1, 0.8)
end

function module.AcquireUnitFrame(driverFrame, namePlateFrameBase)
  if namePlateFrameBase:IsForbidden() then return end

  local unitFrame = namePlateFrameBase.UnitFrame

  unitFrame.UpdateNameOverride = module.UpdateNameOverride
  unitFrame.UpdateHealthBorderOverride = module.UpdateHealthBorderOverride
  module:TweakFrame(unitFrame)
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
  healthBar:ClearAllPoints()
  healthBar:SetPoint("BOTTOMLEFT", 12, 4)
  healthBar:SetPoint("BOTTOMRIGHT", -12, 4)

  healthBar.border:Hide()
  unitFrame.stakoBorder = CreateFrame("Frame", nil, healthBar, "stakoNamePlateFullBorderTemplate")
  self.UpdateSizes(unitFrame.stakoBorder)

  local castBar = unitFrame.CastBar
  castBar:ClearAllPoints()
  castBar:SetPoint("TOP", healthBar, "BOTTOM", 8, -9)

  local castText = unitFrame.CastBar.Text
  castText:ClearAllPoints()
  castText:SetPoint("TOPLEFT", 0, 5)
  castText:SetPoint("TOPRIGHT", 0, 5)

  local levelFrame = unitFrame.LevelFrame
  levelFrame:ClearAllPoints()
  levelFrame:SetPoint("LEFT", healthBar, "RIGHT", 3, 0)

  local name = unitFrame.name
  name:ClearAllPoints()
  name:SetPoint("BOTTOM", healthBar, "TOP", 0, 4)
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

function module.UpdateSizes(border)
  local borderSize = 1
  local minPixels = 2

  local upwardExtendHeightPixels = borderSize
  local upwardExtendHeightMinPixels = minPixels

  PixelUtil.SetWidth(border.Left, borderSize, minPixels)
  PixelUtil.SetPoint(border.Left, "TOPRIGHT", border, "TOPLEFT", 0, upwardExtendHeightPixels, 0, upwardExtendHeightMinPixels)
  PixelUtil.SetPoint(border.Left, "BOTTOMRIGHT", border, "BOTTOMLEFT", 0, -borderSize, 0, minPixels)

  PixelUtil.SetWidth(border.Right, borderSize, minPixels)
  PixelUtil.SetPoint(border.Right, "TOPLEFT", border, "TOPRIGHT", 0, upwardExtendHeightPixels, 0, upwardExtendHeightMinPixels)
  PixelUtil.SetPoint(border.Right, "BOTTOMLEFT", border, "BOTTOMRIGHT", 0, -borderSize, 0, minPixels)

  PixelUtil.SetHeight(border.Bottom, borderSize, minPixels)
  PixelUtil.SetPoint(border.Bottom, "TOPLEFT", border, "BOTTOMLEFT", 0, 0)
  PixelUtil.SetPoint(border.Bottom, "TOPRIGHT", border, "BOTTOMRIGHT", 0, 0)

  PixelUtil.SetHeight(border.Top, borderSize, minPixels)
  PixelUtil.SetPoint(border.Top, "BOTTOMLEFT", border, "TOPLEFT", 0, 0)
  PixelUtil.SetPoint(border.Top, "BOTTOMRIGHT", border, "TOPRIGHT", 0, 0)
end