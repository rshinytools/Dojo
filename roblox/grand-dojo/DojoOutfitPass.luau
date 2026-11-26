local ConfigService = game:GetService("ConfigService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local OutfitPass = {}
local CATALOG_KEY = "dojo_outfitters_midnight_lantern"

function OutfitPass.catalog(value)
    local id = if type(value) == "table" then value.passId else nil
    if type(id) ~= "number" or id < 1 or id > 9007199254740991 or id % 1 ~= 0 then
        return 0
    end
    return id
end

function OutfitPass.mount(remote)
    local records = {}
    local passId = 0

    local function check(player, record)
        local id = passId
        if id == 0 then
            player:SetAttribute("DojoBundleOwnership", "locked")
            return "locked"
        end
        local request = {}
        record.lastOwnershipRequest = request
        local ok, owns = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, player.UserId, id)
        if records[player] ~= record or id ~= passId or record.lastOwnershipRequest ~= request then return nil end
        local ownership = if not ok then "unknown" elseif owns then "owned" else "locked"
        player:SetAttribute("DojoBundleOwnership", ownership)
        return ownership
    end

    local function refresh(player)
        local record = records[player]
        if not record or record.checking then return end
        record.checking = true
        task.spawn(function()
            check(player, record)
            record.checking = false
        end)
    end

    local function publish(value)
        local id = OutfitPass.catalog(value)
        local previousId = passId
        passId = id
        remote:SetAttribute("BundlePassId", id)
        if previousId == id then return end
        for player, record in records do
            record.checking = false
            player:SetAttribute("DojoBundleOwnership", if id == 0 then "locked" else "unknown")
            refresh(player)
        end
    end

    local function joined(player)
        if records[player] then return end
        local record = {}
        records[player] = record
        record.spawned = player.CharacterAdded:Connect(function() refresh(player) end)
        refresh(player)
    end

    Players.PlayerAdded:Connect(joined)
    Players.PlayerRemoving:Connect(function(player)
        local record = records[player]
        if record then record.spawned:Disconnect() end
        records[player] = nil
    end)
    for _, player in Players:GetPlayers() do joined(player) end
    publish(nil)
    task.spawn(function()
        while true do
            local loaded, snapshot = pcall(ConfigService.GetConfigAsync, ConfigService)
            if loaded then
                snapshot:GetValueChangedSignal(CATALOG_KEY):Connect(function()
                    publish(snapshot:GetValue(CATALOG_KEY))
                end)
                snapshot.UpdateAvailable:Connect(function()
                    local refreshed = pcall(snapshot.Refresh, snapshot)
                    if refreshed then publish(snapshot:GetValue(CATALOG_KEY)) end
                end)
                publish(snapshot:GetValue(CATALOG_KEY))
                break
            end
            task.wait(30)
        end
    end)

    MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, id, purchased)
        local record = records[player]
        if not record or id == 0 or id ~= passId then return end
        if not purchased then return end
        if check(player, record) ~= "owned" then
            remote:FireClient(player, "bundleNotice", "Ownership is still syncing. Reopen the shop to check again.")
        end
    end)

    local pass = {}
    function pass.refresh(player)
        local record = records[player]
        if not record or os.clock() < (record.nextCheck or 0) then return end
        record.nextCheck = os.clock() + 4
        refresh(player)
    end

    function pass.canEquip(player)
        local record = records[player]
        return record ~= nil and check(player, record) == "owned"
    end

    return pass
end

return OutfitPass
