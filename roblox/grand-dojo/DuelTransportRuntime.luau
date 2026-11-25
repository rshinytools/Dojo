local Config = require(script.Parent.DuelTransportConfig)

local Runtime = {}
Runtime.__index = Runtime
local singleton, initializing, initializationFailed

local function unavailable()
    error("Cross-server Duel store unavailable")
end

local unavailableMap = table.freeze({GetAsync = unavailable, UpdateAsync = unavailable, GetRangeAsync = unavailable})

-- This gate precedes service lookup, attributes, registration, and all network operations.
function Runtime.get(studio)
    if not Config.allows(game.GameId, game.PlaceId, game.JobId, studio) then return nil end
    if singleton then return singleton end
    if initializationFailed then return nil end
    if initializing then
        repeat task.wait() until not initializing
        return singleton
    end
    initializing = true
    local ok, runtime = pcall(function()
        local Assignments = require(script.Parent.DuelAssignments)
        local Tickets = require(script.Parent.DuelQueueTickets)
        local Bridge = require(script.Parent.DuelProfileBridge)
        local privateId = if type(game.PrivateServerId) == "string" and game.PrivateServerId ~= ""
            and game.PrivateServerOwnerId == 0 then game.PrivateServerId else nil
        local scope = string.format("DojoDuel_%.0f_%s", game.PlaceId, Config.Protocol)
        local connected, ticketMap, assignmentMap = pcall(function()
            local memory = game:GetService("MemoryStoreService")
            return memory:GetSortedMap(scope .. "_T"), memory:GetHashMap(scope .. "_A")
        end)
        if not connected then
            if not privateId then return nil end
            ticketMap, assignmentMap = unavailableMap, unavailableMap
        end
        return setmetatable({
            jobId = game.JobId, placeId = game.PlaceId, universeId = game.GameId, protocol = Config.Protocol,
            privateId = privateId,
            tickets = Tickets.new(ticketMap, os.time, Enum.SortDirection.Ascending),
            assignments = Assignments.new(assignmentMap, os.time),
            profiles = Bridge.new(os.time, function(player, enabled)
                player:SetAttribute("DuelTransferHold", if enabled then true else nil)
            end),
        }, Runtime)
    end)
    initializing = false
    if not ok or not runtime then
        initializationFailed = true
        warn("[Beast Dojo] Cross-server Duel could not initialize. Same-server Duel is available.")
        return nil
    end
    singleton = runtime
    return singleton
end

-- Using the same GUID for the assignment and the reservation permits a trusted boot lookup.
function Runtime:profileRole(player)
    if not self.privateId then return "city" end
    if self.role then return self.role end
    local record, reason = self.assignments:read(self.privateId)
    if record then
        if record.id == self.privateId and record.reservedId == self.privateId and record.universeId == self.universeId
            and record.placeId == self.placeId and record.protocol == self.protocol then
            self.role = "arena"
            return self.role
        end
        return "unknown"
    end
    if reason then return "unknown" end
    local joinData = player:GetJoinData()
    local payload = joinData and joinData.TeleportData
    if type(payload) == "table" and payload.purpose == "casualDuel" and payload.matchId == self.privateId then
        return "unknown"
    end
    return "city"
end

-- These ports are used by the Duel coordinator and its existing win/leave logic.
function Runtime:connectFailures(callback)
    local teleport = game:GetService("TeleportService")
    return teleport.TeleportInitFailed:Connect(function(player, _, _, placeId, options)
        if placeId ~= self.placeId or not options then return end
        local ok, payload = pcall(options.GetTeleportData, options)
        if ok and type(payload) == "table" then callback(player, payload) end
    end)
end

function Runtime:returnToCity(player, dispatch)
    local options = Instance.new("TeleportOptions")
    options.ForcePublicServer = true
    options:SetTeleportData({purpose = "casualDuelReturn", dispatch = dispatch})
    return game:GetService("TeleportService"):TeleportAsync(self.placeId, {player}, options)
end

function Runtime:driver(ports)
    local Driver = require(script.Parent.DuelAssignmentDriver)
    local http = game:GetService("HttpService")
    local teleport = game:GetService("TeleportService")
    return Driver.new(self.tickets, self.assignments, {
        jobId = self.jobId, placeId = self.placeId, universeId = self.universeId, protocol = self.protocol,
        privateId = self.privateId, now = os.time,
        guid = function() return http:GenerateGUID(false) end,
        prepare = function(player, transferId, route, deadline)
            return self.profiles:request(player, "prepare", transferId, route, deadline)
        end,
        accept = function(player, transferId, route, deadline)
            return self.profiles:request(player, "accept", transferId, route, deadline)
        end,
        resume = function(player, transferId, route)
            return self.profiles:request(player, "resume", transferId, route)
        end,
        teleport = function(player, placeId, route, payload)
            local options = Instance.new("TeleportOptions")
            options.ReservedServerId = route
            options:SetTeleportData(payload)
            return teleport:TeleportAsync(placeId, {player}, options)
        end,
        sourceEligible = ports.sourceEligible, isPresent = ports.isPresent, readyRoot = ports.readyRoot, begin = ports.begin,
    })
end

return Runtime
