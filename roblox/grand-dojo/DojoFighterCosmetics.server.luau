local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Art = require(ReplicatedStorage:WaitForChild("DojoFighterCosmeticArt"))
local Catalog = require(ReplicatedStorage:WaitForChild("DojoCosmeticCatalog"))
local Forms = require(ReplicatedStorage:WaitForChild("FighterForms"))
local shellName = "Starter Fighter Shell"
local records = {}

local function watch(player)
    if records[player] then return end
    local playerConnections = {}
    records[player] = playerConnections
    local characterConnections, mounted = {}, {}
    local character, shell, scheduled

    local function clear()
        for key, item in mounted do
            item.model:Destroy()
            mounted[key] = nil
        end
    end

    local function update()
        if records[player] ~= playerConnections or character ~= player.Character then return end
        local nextShell = character and character:FindFirstChild(shellName)
        if nextShell ~= shell then
            clear()
            shell = nextShell
        end
        if not shell then return end
        local fighterId = shell:GetAttribute("FighterId")
        local formId = shell:GetAttribute("FighterFormId")
        if formId ~= Forms.BaseId then
            clear()
            return
        end
        local ok, equipped = pcall(HttpService.JSONDecode, HttpService, player:GetAttribute("DojoFighterCosmetics") or "{}")
        if not ok or type(equipped) ~= "table" then return end
        for slot, item in mounted do
            if equipped[slot] ~= item.id or player:GetAttribute(Catalog.attribute("CosmeticOwnership", item.id)) ~= "owned" then
                item.model:Destroy()
                mounted[slot] = nil
            end
        end
        for slot, itemId in equipped do
            local item = Catalog.get(itemId)
            if not mounted[slot] and item and item.slot == slot and item.fighterId == fighterId
                and player:GetAttribute(Catalog.attribute("CosmeticOwnership", item.id)) == "owned" then
                local model = Art.mount(character, shell, itemId, fighterId, true)
                if model then mounted[slot] = {id = itemId, model = model} end
            end
        end
    end

    local function schedule()
        if scheduled then return end
        scheduled = true
        task.defer(function()
            scheduled = false
            update()
        end)
    end

    local function bind(newCharacter)
        for _, connection in characterConnections do connection:Disconnect() end
        table.clear(characterConnections)
        clear()
        character, shell = newCharacter, nil
        if not character then return end
        local function shellChanged(child)
            if child.Name == shellName then schedule() end
        end
        characterConnections[1] = character.ChildAdded:Connect(shellChanged)
        characterConnections[2] = character.ChildRemoved:Connect(shellChanged)
        schedule()
    end

    playerConnections[1] = player.CharacterAdded:Connect(bind)
    playerConnections[2] = player.CharacterRemoving:Connect(function(old)
        if character == old then bind(nil) end
    end)
    playerConnections[3] = player:GetAttributeChangedSignal("DojoFighterCosmetics"):Connect(schedule)
    for _, item in Catalog.Items do
        table.insert(playerConnections, player:GetAttributeChangedSignal(Catalog.attribute("CosmeticOwnership", item.id)):Connect(schedule))
    end
    playerConnections.stop = function() bind(nil) end
    bind(player.Character)
end

Players.PlayerAdded:Connect(watch)
Players.PlayerRemoving:Connect(function(player)
    local record = records[player]
    if not record then return end
    records[player] = nil
    record.stop()
    for _, connection in ipairs(record) do connection:Disconnect() end
end)
for _, player in Players:GetPlayers() do watch(player) end
