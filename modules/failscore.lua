local addonName, ns = ...
local module = ns.Module:new()
local bit_band = bit.band

local function hasFlag(flags, flag)
  return bit_band(flags, flag) == flag
end

module:RegisterEvent("ADDON_LOADED")
module:RegisterEvent("GUILD_PARTY_STATE_UPDATED")
module:RegisterEvent("CHAT_MSG_WHISPER")

function module:ADDON_LOADED(name)
  if name ~= addonName then return end

  self:BuildDB()
  self:UpdateGuildDB()
end

function module:GUILD_PARTY_STATE_UPDATED(isGuildGroup)
  local _, instanceType = GetInstanceInfo()

  if isGuildGroup and instanceType == "raid" then
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  else
    self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  end
end

function module:CHAT_MSG_WHISPER(...)
  local msg, _, _, _, name, _, _, _, _, _, _, guid = ...
  if string.lower(msg) ~= "failscore" or not guid then return end

  local player = self.guilddb[guid]
  local leader = self.guilddb.leader
  local pluralizeDeath = leader.score > 1 and " deaths" or " death"
  local message = " :: " .. leader.name .. " leads with " .. leader.score .. pluralizeDeath

  if player then
    pluralizeDeath = player.score > 1 and " deaths" or " death"
    message = "You have " .. player.score .. pluralizeDeath .. message
  else
    message = "You have no deaths on record" .. message
  end

  SendChatMessage(message, "WHISPER", nil, name)
end

function module:COMBAT_LOG_EVENT_UNFILTERED()
  local _, event, _, _, _, _, _, destGuid, destName, destFlags = CombatLogGetCurrentEventInfo()

  if event == "UNIT_DIED" and hasFlag(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) then
    self:IncreaseScore(destGuid, destName)
    self:UpdateLeader(destGuid)
  end
end

function module:BuildDB()
  local db = ns:GetDB()
  db.failscore = db.failscore or {}
  self.db = db.failscore
end

function module:UpdateGuildDB()
  local guild = GetGuildInfo("player")
  self.db[guild] = self.db[guild] or { leader = {score = 0}}
  self.guilddb = self.db[guild]
end

function module:IncreaseScore(guid, name)
  if not self.guilddb[guid] then
    self.guilddb[guid] = { name = name, score = 1 }
  else
    local playerdb = self.guilddb[guid]
    playerdb.name = name
    playerdb.score = playerdb.score + 1
  end
end

function module:UpdateLeader(guid)
  local leader = self.guilddb.leader
  local player = self.guilddb[guid]

  if player.score > leader.score then
    leader.score = player.score
    leader.name = player.name
    if guid ~= leader.guid then
      leader.guid = guid
      self:AnnounceNewLeader()
    end
  end
end

function module:AnnounceNewLeader()
  local leader = self.guilddb.leader
  local death = leader.score > 1 and " deaths" or " death"
  local message = leader.name .. " has taken the lead with " .. leader.score .. death .. "! Whisper me 'failscore' for your score."

  SendChatMessage(message, "RAID")
end
