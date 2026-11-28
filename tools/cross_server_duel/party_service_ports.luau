local function signal()
    local handlers = {}
    return {
        Connect = function(_, f) table.insert(handlers, f) end,
        Fire = function(_, ...) for _, f in handlers do f(...) end end,
    }
end
local now = 40
local os = {clock = function() return now end}
local function tick() now += 3 end
local tasks = {}
local task = {delay = function(_, f) table.insert(tasks,f) end}
local Players = {PlayerRemoving = signal()}
local player = {UserId = 2, PartyId = "party-id", Parent = Players}
local attributes = {}
function player:SetAttribute(k,v) attributes[k] = v end
local destination = {UserId = 1, PlaceId = 100, JobId = "public-host"}
local localRecord = {UserId = 2, PlaceId = 100, JobId = "source"}
local partyData = {destination, localRecord}
local SocialService = {GetPartyAsync = function(_, id)
    assert(id == "party-id")
    return partyData
end}
local canTravel, shouldFail, inStudio, sends = true, false, false, 0
local RunService = {IsStudio = function() return inStudio end}
local sequence = 0
local HttpService = {GenerateGUID = function() sequence += 1; return "travel-" .. sequence end}
local options = {}
local TeleportService = {TeleportInitFailed = signal()}
function TeleportService:TeleportAsync(place, players, setting)
    sends += 1
    assert(place == 100 and #players == 1 and players[1] == player)
    assert(setting.ServerInstanceId == "public-host" and setting:GetTeleportData().purpose == "dojoParty")
    table.insert(options,setting)
    if shouldFail then error("Teleport initiation failed") end
end
local Instance = {new = function(class)
    assert(class == "TeleportOptions")
    return {
        SetTeleportData = function(self,data) self.data = data end,
        GetTeleportData = function(self) return self.data end,
    }
end}
local services = {HttpService = HttpService, Players = Players, RunService = RunService,
    SocialService = SocialService, TeleportService = TeleportService}
local game = {PlaceId = 100, JobId = "source", PrivateServerId = "",
    GetService = function(_,service) return assert(services[service]) end}
local messages, state = {}, nil
local remote = {OnServerEvent = signal(), FireClient = function(_,who,kind,packet)
    assert(who == player)
    if kind == "notice" then table.insert(messages, packet) else state = packet end
end}
local function command(action)
    tick()
    remote.OnServerEvent:Fire(player,action,"client-supplied-job-ignored")
end
