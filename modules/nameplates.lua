local addonName, addon = ...
local module = addon:NewModule()

addon:RegisterEvent("ADDON_LOADED")

function module:ADDON_LOADED(name)
  if name ~= addonName then return end

  hooksecurefunc(NamePlateDriverFrame, "AcquireUnitFrame", self.AcquireUnitFrame)
  hooksecurefunc("Nameplate_CastBar_AdjustPosition", self.Nameplate_CastBar_AdjustPosition)
end

function module.AcquireUnitFrame(driverFrame, namePlateFrameBase)
  if namePlateFrameBase:IsForbidden() then return end

  local unitFrame = namePlateFrameBase.UnitFrame

  module:TweakFrame(unitFrame)
  unitFrame.UpdateNameOverride = module.UpdateNameOverride
  unitFrame.UpdateHealthBorderOverride = module.UpdateHealthBorderOverride
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
  self.UpdateBorderSizes(unitFrame.stakoBorder)

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

function module.UpdateNameOverride(frame)
  if not ShouldShowName(frame) then
    frame.name:Hide()
  else
    local name = GetUnitName(frame.unit, false)
    if C_Commentator.IsSpectating() and name then
      local overrideName = C_Commentator.GetPlayerOverrideName(name)
      if overrideName then
        name = overrideName
      end
    end

    frame.name:SetText(name)

    if UnitIsUnit(frame.unit, "target") then
      frame.name:SetVertexColor(1, 1, 1)
      frame.name:SetFontObject(Game12Font_o1)
    else
      frame.name:SetFontObject(SystemFont_LargeNamePlate)

      if CompactUnitFrame_IsTapDenied(frame) or UnitIsDead(frame.unit) and not UnitIsPlayer(frame.unit) then
        frame.name:SetVertexColor(0.5, 0.5, 0.5)
      elseif frame.optionTable.colorNameBySelection then
        frame.name:SetVertexColor(UnitSelectionColor(frame.unit, frame.optionTable.colorNameWithExtendedColors))
      else
        frame.name:SetVertexColor(1.0, 1.0, 1.0)
      end
    end

    frame.name:Show()
  end

  return true
end

function module.UpdateHealthBorderOverride(frame)
  if UnitIsUnit(frame.displayedUnit, "target") then
    module.UpdateBorderColor(frame, 1, 1, 1, 0.75)
  else
    module.UpdateBorderColor(frame, 0, 0, 0, 0.75)
  end

  return true
end

function module.Nameplate_CastBar_AdjustPosition(castBar)
  if not castBar:IsForbidden() then castBar.Text:Show() end
end

function module.UpdateBorderColor(frame, r, g, b, a)
  for i, texture in ipairs(frame.stakoBorder.Textures) do
    texture:SetVertexColor(r, g, b, a)
  end
end

function module.UpdateBorderSizes(border)
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