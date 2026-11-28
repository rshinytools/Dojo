local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SocialService = game:GetService("SocialService")
local TeleportService = game:GetService("TeleportService")
local Destination = require(script.Parent.DojoPartyDestination)

local PartyService = {}

function PartyService.mount(remote, canTravel)
    local pending, lastRequest, activeRequest = {}, {}, {}
    local function inform(player, message)
        if player.Parent == Players then remote:FireClient(player, "notice", message) end
    end
    local function roster(player, partyId)
        local ok, members = pcall(SocialService.GetPartyAsync, SocialService, partyId)
        if not ok or type(members) ~= "table" or player.PartyId ~= partyId or player.Parent ~= Players then
            return nil
        end
        return Destination.find(members, player.UserId, game.PlaceId, game.JobId)
    end
    local function endTravel(player, dispatch, message)
        if pending[player] ~= dispatch then return end
        pending[player] = nil
        if player.Parent == Players then
            player:SetAttribute("DojoPartyTravel", nil)
            inform(player, message)
        end
    end
    TeleportService.TeleportInitFailed:Connect(function(player, _, _, placeId, options)
        if placeId ~= game.PlaceId or not options or not pending[player] then return end
        local ok, payload = pcall(options.GetTeleportData, options)
        if ok and type(payload) == "table" and payload.purpose == "dojoParty" then
            endTravel(player, payload.dispatch, "Could not join your party. Refresh and try again.")
        end
    end)
    Players.PlayerRemoving:Connect(function(player)
        pending[player], lastRequest[player], activeRequest[player] = nil, nil, nil
    end)
    remote.OnServerEvent:Connect(function(player, action)
        if action ~= "view" and action ~= "regroup" then return end
        local now = os.clock()
        if pending[player] or activeRequest[player] or now - (lastRequest[player] or -4) < 2 then return end
        lastRequest[player] = now
        if game.PrivateServerId ~= "" then
            inform(player, "Regroup from a regular city server.")
            return
        end
        local ok, partyId = pcall(function() return player.PartyId end)
        if not ok or type(partyId) ~= "string" then
            inform(player, "Roblox Party is currently unavailable.")
            return
        end
        if partyId == "" then
            remote:FireClient(player, "party", nil)
            return
        end
        activeRequest[player] = true
        local current = roster(player, partyId)
        activeRequest[player] = nil
        if player.Parent ~= Players then return end
        if not current then
            inform(player, "Your party's city roster is unavailable. Refresh and try again.")
            return
        end
        remote:FireClient(player, "party", {nearby = current.nearby, inCity = current.inCity,
            canRegroup = current.hostJob ~= nil})
        if action ~= "regroup" or not current.hostJob then return end
        if RunService:IsStudio() or not canTravel(player) then
            inform(player, "Regroup from a published city after finishing your current activity.")
            return
        end
        local dispatch = HttpService:GenerateGUID(false)
        pending[player] = dispatch
        player:SetAttribute("DojoPartyTravel", true)
        local options = Instance.new("TeleportOptions")
        options.ServerInstanceId = current.hostJob
        options:SetTeleportData({purpose = "dojoParty", dispatch = dispatch})
        inform(player, "Joining your party's city…")
        local sent = pcall(TeleportService.TeleportAsync, TeleportService, game.PlaceId, {player}, options)
        if not sent then
            endTravel(player, dispatch, "Could not join your party. Refresh and try again.")
        else
            task.delay(22, function()
                endTravel(player, dispatch, "Party travel timed out. Refresh and try again.")
            end)
        end
    end)
end

return PartyService
