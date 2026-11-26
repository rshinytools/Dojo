local ConfigService = game:GetService("ConfigService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Catalog = require(ReplicatedStorage:WaitForChild("DojoCosmeticCatalog"))
local FighterPasses = {}

local function passIds(config)
    local ids, rejected = {}, {}
    if type(config) ~= "table" then return ids end
    for _, item in Catalog.Items do
        local id = config[item.id]
        if type(id) == "number" and id >= 1 and id <= 9007199254740991 and id % 1 == 0 then
            if ids[id] then rejected[id] = true end
            ids[id] = item.id
        end
    end
    local byItem = {}
    for id, itemId in ids do
        if not rejected[id] then byItem[itemId] = id end
    end
    return byItem
end

function FighterPasses.mount(remote)
    local records = {}
    local listings = {}

    local function check(player, itemId, record, purchaseCompleted)
        if records[player] ~= record then return false end
        local id = listings[itemId]
        local previous = record.requests[itemId]
        if previous and previous.passId == id then
            -- The in-flight response may reflect ownership before this purchase.
            if purchaseCompleted then previous.recheck = true end
            return false
        end
        if not id then
            player:SetAttribute(Catalog.attribute("CosmeticOwnership", itemId), "locked")
            return false
        end
        local request = {passId = id}
        record.requests[itemId] = request
        local ok, owned = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, player.UserId, id)
        if records[player] ~= record or record.requests[itemId] ~= request or listings[itemId] ~= id then
            return false
        end
        record.requests[itemId] = nil
        if request.recheck and not (ok and owned == true) then
            task.defer(check, player, itemId, record)
            return false
        end
        player:SetAttribute(Catalog.attribute("CosmeticOwnership", itemId), if not ok then "unknown" elseif owned then "owned" else "locked")
        return ok and owned == true
    end

    local function refresh(player, itemId, purchaseCompleted)
        local record = records[player]
        if record then task.spawn(check, player, itemId, record, purchaseCompleted) end
    end

    local function publish(value)
        local previous = listings
        listings = passIds(value)
        for _, item in Catalog.Items do
            local itemId = item.id
            local id = listings[itemId]
            remote:SetAttribute(Catalog.attribute("CosmeticPass", itemId), id or 0)
            if previous[itemId] ~= id then
                for player, record in records do
                    record.requests[itemId] = nil
                    player:SetAttribute(Catalog.attribute("CosmeticOwnership", itemId), if id then "unknown" else "locked")
                    refresh(player, itemId)
                end
            end
        end
    end

    local function joined(player)
        if records[player] then return end
        records[player] = {requests = {}, nextCheck = {}}
        for _, item in Catalog.Items do
            refresh(player, item.id)
        end
    end
    Players.PlayerAdded:Connect(joined)
    Players.PlayerRemoving:Connect(function(player) records[player] = nil end)
    for _, player in Players:GetPlayers() do joined(player) end
    publish(nil)
    task.spawn(function()
        while true do
            local loaded, snapshot = pcall(ConfigService.GetConfigAsync, ConfigService)
            if loaded then
                local function apply()
                    publish(snapshot:GetValue(Catalog.PassConfig))
                end
                snapshot:GetValueChangedSignal(Catalog.PassConfig):Connect(apply)
                snapshot.UpdateAvailable:Connect(function()
                    if pcall(snapshot.Refresh, snapshot) then apply() end
                end)
                apply()
                return
            end
            task.wait(30)
        end
    end)

    MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, id, purchased)
        if purchased then
            for itemId, passId in listings do
                if id == passId then refresh(player, itemId, true) end
            end
        end
    end)

    local service = {}
    function service.refresh(player, itemId)
        local record = records[player]
        if not record or not Catalog.get(itemId) or os.clock() < (record.nextCheck[itemId] or 0) then return end
        record.nextCheck[itemId] = os.clock() + 4
        refresh(player, itemId)
    end

    function service.canEquip(player, itemId)
        local record = records[player]
        return record ~= nil and Catalog.get(itemId) ~= nil
            and (listings[itemId] ~= nil and player:GetAttribute(Catalog.attribute("CosmeticOwnership", itemId)) == "owned"
                or check(player, itemId, record))
    end

    return service
end

return FighterPasses
