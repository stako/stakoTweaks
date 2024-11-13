local addonName, ns = ...
local module = ns.Module:new()

module:RegisterEvent("ADDON_LOADED")

function module:ADDON_LOADED(name)
  if name ~= addonName then return end

  PlayerFrameGroupIndicator:SetAlpha(0)

  PlayerFrameTexture:SetTexture("Interface\\AddOns\\"..addonName.."\\textures\\UI-TargetingFrame")
  PlayerStatusTexture:SetTexture("Interface\\AddOns\\"..addonName.."\\textures\\UI-Player-Status")
  PlayerStatusTexture:SetPoint("TOPLEFT", 35, -9)
  PlayerStatusTexture:SetHeight(69)

  hooksecurefunc("PlayerFrame_ToVehicleArt", module.PlayerFrame_ToVehicleArt)
  hooksecurefunc("PlayerFrame_ToPlayerArt", module.PlayerFrame_ToPlayerArt)
end

function module.PlayerFrame_ToVehicleArt(self, vehicleType)
  PlayerFrameHealthBar:SetHeight(12)
  PlayerFrameHealthBarText:SetPoint("CENTER", 50, 3)
  PlayerFrameHealthBarTextLeft:SetPoint("LEFT", 110, 3)
  PlayerFrameHealthBarTextRight:SetPoint("RIGHT", -8, 3)
  PlayerFrameManaBarText:SetPoint("CENTER", 50, -8)
  PlayerFrameManaBarTextLeft:SetPoint("LEFT", 110, -8)
  PlayerFrameManaBarTextRight:SetPoint("RIGHT", -8, -8)
  PlayerName:Show()
end

function module.PlayerFrame_ToPlayerArt(self, vehicleType)
  PlayerFrameHealthBar:SetPoint("TOPLEFT", 106, -24)
  PlayerFrameHealthBar:SetHeight(25)
  PlayerFrameHealthBarText:SetPoint("CENTER", 50, 12)
  PlayerFrameHealthBarTextLeft:SetPoint("LEFT", 110, 12)
  PlayerFrameHealthBarTextRight:SetPoint("RIGHT", -8, 12)
  PlayerFrameManaBarText:SetPoint("CENTER", 50, -7)
  PlayerFrameManaBarTextLeft:SetPoint("LEFT", 110, -7)
  PlayerFrameManaBarTextRight:SetPoint("RIGHT", -8, -7)
  PlayerName:Hide()
end