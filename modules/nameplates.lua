local addonName, addon = ...
local module = addon:NewModule()

addon:RegisterEvent("ADDON_LOADED")
addon:RegisterEvent("PLAYER_ENTERING_WORLD")

local UnitIsUnit, UnitIsFriend, UnitIsPlayer, UnitIsPossessed = UnitIsUnit, UnitIsFriend, UnitIsPlayer, UnitIsPossessed
local inForbiddenZone = false

function module:ADDON_LOADED(name)
  if name ~= addonName then return end

  hooksecurefunc(NamePlateDriverFrame, "OnNamePlateAdded", self.OnNamePlateAdded)
  hooksecurefunc(NamePlateDriverFrame, "UpdateNamePlateOptions", self.UpdateNamePlateOptions)
  hooksecurefunc(NamePlateDriverFrame, "ApplyFrameOptions", self.ApplyFrameOptions)
  hooksecurefunc("Nameplate_CastBar_AdjustPosition", self.Nameplate_CastBar_AdjustPosition)
end

function module:PLAYER_ENTERING_WORLD()
  local _, instanceType = IsInInstance()
  inForbiddenZone = (instanceType == "party" or instanceType == "raid")
  self.UpdateNamePlateOptions(NamePlateDriverFrame)
end

function module.OnNamePlateAdded(driverFrame, namePlateUnitToken)
  module:UpdateNamePlate(nil, namePlateUnitToken)
end

function module.UpdateNamePlateOptions(driverFrame)
  local zeroBasedScale = tonumber(GetCVar("NamePlateVerticalScale")) - 1.0
  local horizontalScale = tonumber(GetCVar("NamePlateHorizontalScale"))

  if inForbiddenZone then
    C_NamePlate.SetNamePlateFriendlySize(driverFrame.baseNamePlateWidth * horizontalScale, driverFrame.baseNamePlateHeight * Lerp(1.0, 1.25, zeroBasedScale))
    C_NamePlate.SetNamePlateFriendlyPreferredClickInsets(0, 0, 0, 0)
  else
    C_NamePlate.SetNamePlateFriendlySize(80 * horizontalScale, driverFrame.baseNamePlateHeight * Lerp(1.0, 1.25, zeroBasedScale))
    C_NamePlate.SetNamePlateFriendlyPreferredClickInsets(0, 0, -36, 0)
  end
end

function module.ApplyFrameOptions(driverFrame, namePlateFrameBase, namePlateUnitToken)
  if namePlateFrameBase:IsForbidden() then return end

  module:ApplyTweaks(namePlateFrameBase.UnitFrame, namePlateUnitToken)

  if module.insetsTweaked or not driverFrame.preferredInsets.friendly then return end

  module.insetsTweaked = true
  C_NamePlate.SetNamePlateFriendlyPreferredClickInsets(0, 0, -36, 0)
end

function module:UpdateNamePlate(namePlateFrameBase, namePlateUnitToken)
  if not namePlateUnitToken:find("nameplate") then return end

  namePlateFrameBase = namePlateFrameBase or C_NamePlate.GetNamePlateForUnit(namePlateUnitToken, false)
  if not namePlateFrameBase then return end

  local unitFrame = namePlateFrameBase.UnitFrame
  local isFriend = UnitIsFriend("player", namePlateUnitToken) and not UnitIsPossessed(namePlateUnitToken)
  local isPlayer = UnitIsPlayer(namePlateUnitToken)
  local _, class = UnitClass(namePlateUnitToken)

  CompactUnitFrame_SetHideHealth(unitFrame, isFriend, 1)
  CastingBarFrame_SetUnit(unitFrame.CastBar, isFriend and nil or unit, true, true)
  unitFrame.stakoClassIcon:SetAtlas(GetClassAtlas(class))
  unitFrame.stakoClassIcon:SetShown(isFriend and isPlayer)
  unitFrame.stakoClassOverlay:SetShown(isFriend and isPlayer)
end

function module:ApplyTweaks(unitFrame, namePlateUnitToken)
  if unitFrame.stakoTweaked then return end

  unitFrame.stakoTweaked = true

  unitFrame.UpdateNameOverride = self.UpdateNameOverride
  unitFrame.UpdateHealthBorderOverride = self.UpdateHealthBorderOverride

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
  castText:SetPoint("TOPLEFT", 0, 6)
  castText:SetPoint("TOPRIGHT", 0, 6)

  local levelFrame = unitFrame.LevelFrame
  levelFrame:ClearAllPoints()
  levelFrame:SetPoint("LEFT", healthBar, "RIGHT", 3, 0)

  local name = unitFrame.name
  name:ClearAllPoints()
  name:SetPoint("BOTTOM", healthBar, "TOP", 0, 4)

  unitFrame.LevelFrame.levelText:SetAlpha(0)
  unitFrame.LevelFrame.highLevelTexture:SetAlpha(0)

  local classIcon = unitFrame:CreateTexture(nil, "ARTWORK")
  classIcon:SetSize(128, 128)
  classIcon:SetScale(0.21)
  classIcon:SetPoint("BOTTOM", name, "TOP", 0, 30)
  unitFrame.stakoClassIcon = classIcon

  local classOverlay = unitFrame:CreateTexture(nil, "OVERLAY")
  classOverlay:SetAtlas("Portrait-Frame-Nameplate", true)
  classOverlay:SetPoint("CENTER", classIcon)
  classOverlay:SetScale(0.83)
  unitFrame.stakoClassOverlay = classOverlay

  local mask = unitFrame:CreateMaskTexture(nil, "OVERLAY")
  mask:SetAtlas("CircleMaskScalable", true)
  mask:SetScale(0.5)
  mask:SetPoint("CENTER", classIcon)
  classIcon:AddMaskTexture(mask)
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
  local unit = frame.displayedUnit

  if UnitIsUnit(unit, "target") then
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