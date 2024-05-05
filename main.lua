local addonName, addon = ...
addon.modules = {}
addon.playerClass = select(2, UnitClass("player"))

local eventManager = CreateFrame("Frame")
eventManager:SetScript("OnEvent", function(self, event, ...)
  for index, module in ipairs(addon.modules) do
    if module[event] then module[event](module, ...) end
  end
end)

function addon:RegisterEvent(event)
  return eventManager:RegisterEvent(event)
end

function addon:RegisterUnitEvent(event, ...)
  return eventManager:RegisterUnitEvent(event, ...)
end

function addon:NewModule()
  local module = {}
  table.insert(self.modules, module)
  return module
end
