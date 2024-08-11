if not BigWigsAPI then return end

local addonName, addon = ...
local module = addon:NewModule()

local pixel
local backdropBorder

addon:RegisterEvent("UI_SCALE_CHANGED")

function module:UI_SCALE_CHANGED()
  local scale = UIParent:GetScale()

  pixel = PixelUtil.ConvertPixelsToUI(1, scale)
  backdropBorder = {
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
    tile = false, tileSize = 0, edgeSize = pixel*2,
    insets = {left = 0, right = 0, top = 0, bottom = 0}
  }
end

module:UI_SCALE_CHANGED()

local function removeStyle(bar)
  bar.candyBarBackdrop:Hide()
  local height = bar:Get("bigwigs:restoreheight")
  if height then
    bar:SetHeight(height)
  end

  local tex = bar:Get("bigwigs:restoreicon")
  if tex then
    bar:SetIcon(tex)
    bar:Set("bigwigs:restoreicon", nil)

    bar.candyBarIconFrameBackdrop:Hide()
  end

  bar.candyBarDuration:ClearAllPoints()
  bar.candyBarDuration:SetPoint("TOPLEFT", bar.candyBarBar, "TOPLEFT", 2, 0)
  bar.candyBarDuration:SetPoint("BOTTOMRIGHT", bar.candyBarBar, "BOTTOMRIGHT", -2, 0)

  bar.candyBarLabel:ClearAllPoints()
  bar.candyBarLabel:SetPoint("TOPLEFT", bar.candyBarBar, "TOPLEFT", 2, 0)
  bar.candyBarLabel:SetPoint("BOTTOMRIGHT", bar.candyBarBar, "BOTTOMRIGHT", -2, 0)
end

local function styleBar(bar)
  local scale = UIParent:GetScale()
  local height = bar:GetHeight()

  bar:Set("bigwigs:restoreheight", height)
  bar:SetHeight(height/2)

  local bd = bar.candyBarBackdrop

  bd:SetBackdrop(backdropBorder)
  bd:SetBackdropColor(.1,.1,.1,1)
  bd:SetBackdropBorderColor(0,0,0,1)

  bd:ClearAllPoints()
  bd:SetPoint("TOPLEFT", bar, "TOPLEFT", -pixel*2, pixel*2)
  bd:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", pixel*2, -pixel*2)
  bd:Show()

  local tex = bar:GetIcon()
  if tex then
    local icon = bar.candyBarIconFrame
    bar:SetIcon(nil)
    icon:SetTexture(tex)
    icon:Show()
    if bar.iconPosition == "RIGHT" then
      icon:SetPoint("BOTTOMLEFT", bar, "BOTTOMRIGHT", pixel*6, 0)
    else
      icon:SetPoint("BOTTOMRIGHT", bar, "BOTTOMLEFT", -pixel*6, 0)
    end
    icon:SetSize(height, height)
    bar:Set("bigwigs:restoreicon", tex)

    local iconBd = bar.candyBarIconFrameBackdrop
    iconBd:SetBackdrop(backdropBorder)
    iconBd:SetBackdropColor(.1,.1,.1,1)
    iconBd:SetBackdropBorderColor(0,0,0,1)

    iconBd:ClearAllPoints()
    iconBd:SetPoint("TOPLEFT", icon, "TOPLEFT", -pixel*2, pixel*2)
    iconBd:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", pixel*2, -pixel*2)
    iconBd:Show()
  end

  bar.candyBarLabel:ClearAllPoints()
  bar.candyBarLabel:SetPoint("BOTTOMLEFT", bar.candyBarBar, "TOPLEFT", pixel*2, pixel*3)
  bar.candyBarLabel:SetPoint("BOTTOMRIGHT", bar.candyBarBar, "TOPRIGHT", -pixel*30, pixel*3)
  bar.candyBarLabel:SetHeight(12)

  bar.candyBarDuration:ClearAllPoints()
  bar.candyBarDuration:SetPoint("BOTTOMRIGHT", bar.candyBarBar, "TOPRIGHT", -pixel*2, pixel*3)
end

BigWigsAPI:RegisterBarStyle("StakoUI", {
  apiVersion = 1,
  version = 10,
  barHeight = 20,
  fontSizeNormal = 10,
  fontSizeEmphasized = 11,
  GetSpacing = function(bar) return bar:GetHeight()+8 end,
  ApplyStyle = styleBar,
  BarStopped = removeStyle,
  GetStyleName = function() return "StakoUI" end,
})