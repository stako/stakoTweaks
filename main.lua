local addonName, ns = ...
ns.playerClass = select(2, UnitClass("player"))

-- Module class
ns.Module = {
  new = function(self, obj)
    obj = obj or {}
    setmetatable(obj, self)
    self.__index = self

    obj:BuildEventManager()

    return obj
  end,

  BuildEventManager = function(self)
    local eventManager = CreateFrame("Frame")
    eventManager:SetScript("OnEvent", function(frame, event, ...) self[event](self, ...) end)
    self.EventManager = eventManager
  end,

  RegisterEvent = function(self, event) self.EventManager:RegisterEvent(event) end,
  RegisterUnitEvent = function(self, event, ...) self.EventManager:RegisterUnitEvent(event, ...) end,
  UnregisterEvent = function(self, event, ...) self.EventManager:UnregisterEvent(event) end,
  UnregisterAllEvents = function(self, event, ...) self.EventManager:UnregisterAllEvents() end,
}
