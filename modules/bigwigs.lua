if not BigWigsAPI then return end

local addonName, addon = ...
local module = addon:NewModule()

local pixel
local backdropInfo = { bgFile = "Interface\\ChatFrame\\ChatFrameBackground" }

addon:RegisterEvent("UI_SCALE_CHANGED")

function module:UI_SCALE_CHANGED()
  pixel = PixelUtil.ConvertPixelsToUI(1, UIParent:GetScale())
end

module:UI_SCALE_CHANGED()

do
  local function removeStyle(bar)
    local height = bar:Get("bigwigs:restoreheight")
    if height then bar:SetHeight(height) end

    bar:SetBackgroundColor(0.5, 0.5, 0.5, 0.3)

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
    local height = bar:GetHeight()
    bar:Set("bigwigs:restoreheight", height)
    bar:SetHeight(height/2)

    local barBackdrop = bar.candyBarBackdrop
    barBackdrop:SetBackdrop(backdropInfo)
    barBackdrop:SetBackdropColor(0, 0, 0, 1)
    barBackdrop:ClearAllPoints()
    barBackdrop:SetPoint("TOPLEFT", -pixel*2, pixel*2)
    barBackdrop:SetPoint("BOTTOMRIGHT", pixel*2, -pixel*2)
    barBackdrop:Show()

    bar:SetBackgroundColor(1, 1, 1, 0.25)

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

      local iconBackdrop = bar.candyBarIconFrameBackdrop
      iconBackdrop:SetBackdrop(backdropInfo)
      iconBackdrop:SetBackdropColor(0, 0, 0, 1)
      iconBackdrop:ClearAllPoints()
      iconBackdrop:SetPoint("TOPLEFT", icon, "TOPLEFT", -pixel*2, pixel*2)
      iconBackdrop:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", pixel*2, -pixel*2)
      iconBackdrop:Show()
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
    version = 1,
    barHeight = 20,
    fontSizeNormal = 10,
    fontSizeEmphasized = 11,
    GetSpacing = function(bar) return bar:GetHeight() + 8 end,
    ApplyStyle = styleBar,
    BarStopped = removeStyle,
    GetStyleName = function() return "StakoUI" end,
  })
end