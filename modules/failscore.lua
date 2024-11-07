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

  self:UpdateGuildDB()
  self:UpdateRankings()

  local player = self.guilddb[guid]
  local leader = self.guilddb.leader

  if not leader.name then return end

  local pluralizeDeath = leader.score > 1 and " deaths" or " death"
  local leaderMessage = " || Leader: " .. leader.name .. " (" .. leader.score .. pluralizeDeath .. ")"
  local message

  if player then
    local rank = self.guilddb.rankings[guid]
    local deathsMessage = "Deaths: " .. player.score
    local rankMessage = " || Rank: " .. rank
    message = deathsMessage .. rankMessage
    if rank > 1 then
      message = message .. leaderMessage
    end
  else
    message = "No deaths on record" .. leaderMessage
  end

  SendChatMessage(message, "WHISPER", nil, name)
end

function module:COMBAT_LOG_EVENT_UNFILTERED()
  local _, event, _, _, _, _, _, destGuid, destName, destFlags = CombatLogGetCurrentEventInfo()

  if event == "UNIT_DIED" and hasFlag(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) then
    self:UpdateGuildDB()
    self:IncreaseScore(destGuid, destName)
    self:UpdateLeader(destGuid)
  end
end

function module:BuildDB()
  local db = ns:GetDB()
  db.failscore = db.failscore or { lastDeath = 0, lastRanking = 0 }
  self.db = db.failscore
end

function module:UpdateGuildDB()
  if self.guilddb then return end

  local guild = GetGuildInfo("player")
  self.db[guild] = self.db[guild] or { rankings = {}, leader = {score = 0}}
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

  self.db.lastDeath = GetTime()
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

function module:UpdateRankings()
  if self.db.lastDeath < self.db.lastRanking then return end

  local sortedList = {}
  local rankings = self.guilddb.rankings

  for guid, data in pairs(self.guilddb) do
    if guid ~= "leader" and guid ~= "rankings" then
      tinsert(sortedList, {guid = guid, score = data.score})
    end
  end

  table.sort(sortedList, function(a, b)
    return a.score > b.score
  end)

  local currentRank = 1
  for i = 1, #sortedList do
    local player = sortedList[i]

    if i > 1 and player.score < sortedList[i-1].score then
      currentRank = currentRank + 1
    end

    rankings[player.guid] = currentRank
  end


  self.db.lastRanking = GetTime()
end
