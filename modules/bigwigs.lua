if not BigWigsAPI then return end

local addonName, ns = ...
local module = ns.Module:new()

local pixel
local backdropInfo = { bgFile = "Interface\\ChatFrame\\ChatFrameBackground" }

module:RegisterEvent("UI_SCALE_CHANGED")

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
    fontSizeNormal = 11,
    fontSizeEmphasized = 11,
    GetSpacing = function(bar) return bar:GetHeight() + 8 end,
    ApplyStyle = styleBar,
    BarStopped = removeStyle,
    GetStyleName = function() return "StakoUI" end,
  })
end

do
  -- using a single texture pool was buggy
  local barBorderPool = CreateTexturePool(UIParent, "OVERLAY")
  local iconBorderPool = CreateTexturePool(UIParent, "OVERLAY")

  local function removeStyle(bar)
    local height = bar:Get("bigwigs:restoreheight")
    if height then bar:SetHeight(height) end

    bar:SetBackgroundColor(0.5, 0.5, 0.5, 0.3)

    local barBorder = bar:Get("bigwigs:stakoui:barborder")
    if barBorder then
      barBorder:SetParent(UIParent)
      barBorderPool:Release(barBorder)
    end

    local tex = bar:Get("bigwigs:restoreicon")
    if tex then
      bar:SetIcon(tex)
      bar:Set("bigwigs:restoreicon", nil)

      bar.candyBarIconFrameBackdrop:Hide()

      local iconBorder = bar:Get("bigwigs:stakoui:iconborder")
      if iconBorder then
        iconBorder:SetParent(UIParent)
        iconBorderPool:Release(iconBorder)
      end
    end

    bar.candyBarDuration:ClearAllPoints()
    bar.candyBarDuration:SetPoint("TOPLEFT", bar.candyBarBar, "TOPLEFT", 2, 0)
    bar.candyBarDuration:SetPoint("BOTTOMRIGHT", bar.candyBarBar, "BOTTOMRIGHT", -2, 0)

    bar.candyBarLabel:ClearAllPoints()
    bar.candyBarLabel:SetPoint("TOPLEFT", bar.candyBarBar, "TOPLEFT", 2, 0)
    bar.candyBarLabel:SetPoint("BOTTOMRIGHT", bar.candyBarBar, "BOTTOMRIGHT", -2, 0)
  end

  local function styleBar(bar)
    local width = bar:GetWidth()
    local height = bar:GetHeight()
    local halfHeight = height/2
    bar:Set("bigwigs:restoreheight", height)
    bar:SetHeight(halfHeight)

    local barBackdrop = bar.candyBarBackdrop
    barBackdrop:SetBackdrop(backdropInfo)
    barBackdrop:SetBackdropColor(0, 0, 0, 0.5)
    barBackdrop:SetAllPoints()
    barBackdrop:Show()

    bar:SetBackgroundColor(1, 1, 1, 0)

    local barBorder = barBorderPool:Acquire()
    barBorder:SetParent(bar.candyBarBar)
    barBorder:SetTexture("Interface\\CastingBar\\UI-CastingBar-Border-Small")
    barBorder:SetVertexColor(0.6, 0.6, 0.6)
    barBorder:SetPoint("TOPLEFT", -width*0.1733, halfHeight*2.1)
    barBorder:SetPoint("BOTTOMRIGHT", width*0.1733, -halfHeight*2.1)
    barBorder:Show()
    bar:Set("bigwigs:stakoui:barborder", barBorder)

    local tex = bar:GetIcon()
    if tex then
      local icon = bar.candyBarIconFrame
      bar:SetIcon(nil)
      icon:SetTexture(tex)
      icon:Show()
      if bar.iconPosition == "RIGHT" then
        icon:SetPoint("BOTTOMLEFT", bar, "BOTTOMRIGHT", width*0.06, -halfHeight*0.1)
      else
        icon:SetPoint("BOTTOMRIGHT", bar, "BOTTOMLEFT", -width*0.06, -halfHeight*0.1)
      end
      icon:SetSize(height*1.3, height*1.3)
      bar:Set("bigwigs:restoreicon", tex)

      local iconBackdrop = bar.candyBarIconFrameBackdrop
      iconBackdrop:SetBackdrop(backdropInfo)
      iconBackdrop:SetBackdropColor(0, 0, 0, 1)
      iconBackdrop:SetAllPoints(icon)
      iconBackdrop:Show()

      local iconBorder = iconBorderPool:Acquire()
      iconBorder:SetParent(bar.candyBarBar)
      iconBorder:SetAtlas("CommentatorSpellBorder")
      iconBorder:SetSize(height*2.1, height*2.1)
      iconBorder:SetPoint("CENTER", icon, "CENTER")
      iconBorder:Show()
      bar:Set("bigwigs:stakoui:iconborder", iconBorder)
    end

    bar.candyBarLabel:ClearAllPoints()
    bar.candyBarLabel:SetPoint("BOTTOMLEFT", bar.candyBarBar, "TOPLEFT", 2, 4)
    bar.candyBarLabel:SetPoint("BOTTOMRIGHT", bar.candyBarBar, "TOPRIGHT", -30, 4)
    bar.candyBarLabel:SetHeight(12)

    bar.candyBarDuration:ClearAllPoints()
    bar.candyBarDuration:SetPoint("BOTTOMRIGHT", bar.candyBarBar, "TOPRIGHT", -2, 4)
  end

  BigWigsAPI:RegisterBarStyle("StakoUI 2", {
    apiVersion = 1,
    version = 1,
    fontSizeNormal = 11,
    fontSizeEmphasized = 11,
    GetSpacing = function(bar) return bar:GetHeight() * 2.5 end,
    ApplyStyle = styleBar,
    BarStopped = removeStyle,
    GetStyleName = function() return "StakoUI 2" end,
  })
end