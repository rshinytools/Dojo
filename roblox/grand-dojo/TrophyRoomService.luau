local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Catalog = require(ReplicatedStorage.TrophyCatalog)
local Art = require(ReplicatedStorage.TrophyArt)
local remote = ReplicatedStorage.TrophyRoom
local RoomService = {}

local function root(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0 and character:FindFirstChild("HumanoidRootPart")
end

local function near(player, part, limit)
    local hrp = root(player)
    return hrp and (hrp.Position - part.Position).Magnitude <= limit
end

local function bindPrompt(part, label, action, callback)
    local prompt = Instance.new("ProximityPrompt")
    prompt.ObjectText, prompt.ActionText = label, action
    prompt.RequiresLineOfSight, prompt.MaxActivationDistance = false, 8
    prompt.Triggered:Connect(callback)
    prompt.Parent = part
end

function RoomService.mount(entry, callbacks)
    local rooms, membership, claimed, invitations = {}, {}, {}, {}
    local function notify(player, message)
        remote:FireClient(player,"notice",message)
    end
    local function layout(player)
        local profile = callbacks.profile(player)
        return profile and profile.cityAdventure and profile.cityAdventure.trophyRoom or {}
    end
    local function redraw(room)
        local saved = layout(room.owner)
        for i = 1, 12 do
            local anchor = room.anchors[i]
            local index = if i <= 6 then i else i + (room.page - 1) * 6
            local id = saved[tostring(index)]
            local prior = anchor:FindFirstChild("Display")
            if prior and prior:GetAttribute("TrophyId") == id then continue end
            if prior then prior:Destroy() end
            if id then
                local model = Art.build(id)
                if model then
                    model.Name = "Display"
                    model:SetAttribute("TrophyId", id)
                    model:PivotTo(anchor.CFrame * model:GetPivot())
                    model.Parent = anchor
                    local plaque = Instance.new("BillboardGui")
                    plaque.Name, plaque.Size, plaque.MaxDistance = "Title", UDim2.fromOffset(155,36), 12
                    plaque.StudsOffset = Vector3.new(0,2.8,0)
                    local label = Instance.new("TextLabel")
                    label.Size, label.BackgroundColor3, label.BackgroundTransparency = UDim2.fromScale(1,1),
                        Color3.fromRGB(58,32,44), .12
                    label.Font, label.TextSize, label.TextWrapped = Enum.Font.GothamBold,14,true
                    label.TextColor3, label.Text = Color3.fromRGB(255,224,184),Catalog.byId[id].title
                    label.Parent, plaque.Parent = plaque, model.PrimaryPart
                end
            end
        end
    end
    local function snapshot(player, action)
        local room = membership[player]
        if not room then return end
        local earned, guests = {}, {}
        local profile = callbacks.profile(player)
        if room.owner == player and profile then
            for id in profile.trophies do
                if Catalog.byId[id] then table.insert(earned,id) end
            end
            for _, other in Players:GetPlayers() do
                if other ~= player and not membership[other] then
                    table.insert(guests,{id=other.UserId,name=other.DisplayName})
                end
            end
            table.sort(earned,function(a,b) return Catalog.byId[a].title < Catalog.byId[b].title end)
        end
        local mine=room.owner==player
        local saved=layout(room.owner)
        if not mine then
            local visible={}
            for i=1,6 do
                local featured=tostring(i)
                local wall=tostring(6+i+(room.page-1)*6)
                visible[featured],visible[wall]=saved[featured],saved[wall]
            end
            saved=visible
        end
        remote:FireClient(player,action or "panel",{
            mine=mine, owner=room.owner.DisplayName, layout=saved,
            page=room.page, earned=earned, guests=guests,
        })
    end
    local function refreshDisplays(room)
        for player,current in membership do
            if current==room then snapshot(player,"refresh") end
        end
    end
    local function sendCity(player, move)
        membership[player] = nil
        player:SetAttribute("TrophyRoomActive",nil)
        player:SetAttribute("CityAdventureActive",nil)
        if move and root(player) then
            player.Character:PivotTo(CFrame.new(entry.Position+Vector3.new(0,1,5)))
        end
        if player.Parent==Players then remote:FireClient(player,"closed") end
    end
    local function leave(player, move)
        local room=membership[player]
        if not room then return end
        if room.owner==player then
            for member, current in membership do
                if current==room then sendCity(member,member~=player or move) end
            end
            rooms[player],claimed[room.index]=nil,nil
            room.model:Destroy()
        else
            sendCity(player,move)
        end
    end
    local function enter(player,room)
        if membership[player] or not root(player) then return end
        membership[player]=room
        player:SetAttribute("TrophyRoomActive",true)
        player:SetAttribute("CityAdventureActive",true)
        player.Character:PivotTo(room.model.Arrival.CFrame * CFrame.Angles(0,0,0))
        remote:FireClient(player,"entered",room.owner==player)
    end
    bindPrompt(entry,"Personal Trophy Room","Enter room",function(player)
        if not near(player,entry,10) or membership[player] or callbacks.blocked(player) then return end
        local index=1
        while claimed[index] do index+=1 end
        local model=ServerStorage["Personal Trophy Room"]:Clone()
        model.Name="Personal Trophy Room"
        local destination=Vector3.new(1700+(index%8)*980,270,1700+math.floor(index/8)*980)
        model:PivotTo(model:GetPivot()+destination)
        local room={owner=player, index=index, model=model, anchors={}, page=1}
        rooms[player],claimed[index]=room,true
        for i=1,12 do
            room.anchors[i]=model[(if i<=6 then "Featured" else "Wall")..(if i<=6 then i else i-6)]
        end
        bindPrompt(model.Exit,"Trophy Hall","Return",function(visitor)
            if membership[visitor]==room and near(visitor,model.Exit,10) then leave(visitor,true) end
        end)
        bindPrompt(model.RoomControls,"Trophy displays","Inspect collection",function(visitor)
            if membership[visitor]==room and near(visitor,model.RoomControls,10) then snapshot(visitor) end
        end)
        redraw(room)
        model.Parent=workspace
        enter(player,room)
    end)

    local lastRequest = {}
    remote.OnServerEvent:Connect(function(player, action, a, b)
        local now=os.clock()
        if now-(lastRequest[player] or 0)<.15 then return end
        lastRequest[player]=now
        local room=membership[player]
        local own=room and room.owner==player
        if action=="exit" and room then leave(player,true)
        elseif action=="open" and room then snapshot(player)
        elseif action=="accept" and not room then
            local invite=invitations[player]
            invitations[player]=nil
            if invite and invite.untilTime>=now and rooms[invite.owner]==invite.room and not callbacks.blocked(player) then
                enter(player,invite.room)
            else notify(player,"That room invitation has expired.") end
        elseif action=="decline" then invitations[player]=nil
        elseif action=="page" and own and (a==1 or a==2) then
            room.page=a
            redraw(room)
            refreshDisplays(room)
        elseif action=="invite" and own and type(a)=="number" then
            local guest=Players:GetPlayerByUserId(a)
            if guest and guest~=player and not membership[guest] then
                invitations[guest]={owner=player,room=room,untilTime=now+60}
                remote:FireClient(guest,"invite",player.DisplayName)
                notify(player,"Invitation sent.")
            end
        elseif action=="set" and own and type(a)=="number" and a%1==0 and a>=1 and a<=Catalog.slots then
            local profile=callbacks.profile(player)
            if not profile or (b~="" and (type(b)~="string" or not Catalog.byId[b] or not profile.trophies[b])) then
                notify(player,"Earn this trophy before displaying it.")
            elseif callbacks.queue(player,{kind="trophy-display",slot=a,trophy=b,at=os.time()}) then
                notify(player,"Saving display…")
            else
                notify(player,"Display could not be saved. Try again.")
            end
        end
    end)
    local function watch(player)
        player.CharacterRemoving:Connect(function() leave(player,false) end)
    end
    Players.PlayerAdded:Connect(watch)
    for _, player in Players:GetPlayers() do watch(player) end
    Players.PlayerRemoving:Connect(function(player)
        leave(player,false)
        invitations[player],lastRequest[player]=nil,nil
    end)
    return {
        saved=function(player)
            local room=rooms[player]
            if room then
                redraw(room)
                refreshDisplays(room)
                notify(player,"Display saved.")
            end
        end,
    }
end
return RoomService
