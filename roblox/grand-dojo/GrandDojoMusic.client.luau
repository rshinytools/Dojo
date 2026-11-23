local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local DEFAULT_VOLUME = .55
local AREA_SETTLE_SECONDS = .85
local LOAD_TIMEOUT = 5
local RETRY_SECONDS = 45
local FADE_SECONDS = 1.8
local VOLUME_RAMP_SECONDS = .18
local UPDATE_INTERVAL = .10
local SPLASH_DISCOVERY_SECONDS = .35
local SPLASH_LIMIT_SECONDS = 18.5

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local playlists = require(ReplicatedStorage:WaitForChild("MusicPlaylist"))

local music = Instance.new("SoundGroup")
music.Name = "Beast Dojo Music"
music.Volume = 0
music.Parent = SoundService

local function musicSlot(name)
    local sound = Instance.new("Sound")
    sound.Name = name
    sound.Volume = 0
    sound.Looped = true
    sound.SoundGroup = music
    sound.Parent = SoundService
    return sound
end

local firstSound = musicSlot("Beast Dojo Music A")
local secondSound = musicSlot("Beast Dojo Music B")
local cursorByArea = {}
local retryAfter = {}
local now = 0
local nextUpdate = 0
local sawSplash = false
local started = false
local volumeTarget = 0
local worldArea = "city"
local worldCandidate
local settleAt = 0
local desiredArea
local nextProbe = 0
local active
local pending
local fade

local function clearSound(sound)
    sound:Stop()
    sound.Volume = 0
    sound.SoundId = ""
end

local function chooseArea()
    local area = player:GetAttribute("MusicArea")
    if type(area) ~= "string" or playlists[area] == nil then
        area = nil
    end
    if area ~= worldCandidate then
        worldCandidate = area
        settleAt = now + AREA_SETTLE_SECONDS
    end
    if area and now >= settleAt then
        worldArea = area
    end

    if player:GetAttribute("SparringActive") == true then
        return "ring"
    end
    local nextGate = player:GetAttribute("RelayNextGate")
    if type(nextGate) == "number" and nextGate > 0 then
        return "relay"
    end
    return worldArea
end

local function updateVolume()
    local level = player:GetAttribute("MusicVolume")
    if type(level) ~= "number" or level ~= level then
        level = DEFAULT_VOLUME
    end
    volumeTarget = if player:GetAttribute("MusicMuted") == true then 0 else math.clamp(level, 0, 1)
end

local function play(track)
    local previous = active
    active = track
    active.sound.TimePosition = 0
    active.sound:Play()
    cursorByArea[track.area] = track.index
    fade = {from = previous, start = now}
end

local function probe(area, rotating)
    local tracks = playlists[area]
    if not tracks then
        return false
    end
    local cursor = cursorByArea[area] or 0
    for step = 1, #tracks do
        local index = (cursor + step - 1) % #tracks + 1
        local id = tracks[index]
        if type(id) ~= "number" or id <= 0 or id >= math.huge or id % 1 ~= 0 then
            continue
        end
        if active and active.id == id then
            if rotating then
                continue
            end
            active.area = area
            cursorByArea[area] = index
            return true
        end
        if now >= (retryAfter[id] or 0) then
            local sound = if active and active.sound == firstSound then secondSound else firstSound
            sound.SoundId = string.format("rbxassetid://%.0f", id)
            pending = {
                sound = sound, id = id, area = area, index = index,
                deadline = now + LOAD_TIMEOUT,
                rotationPosition = if rotating then active.sound.TimePosition else nil,
            }
            return true
        end
    end
    return false
end

local function endingIn(seconds)
    return active.sound.TimeLength - active.sound.TimePosition <= seconds
end

local function updateMusic()
    local area = chooseArea()
    if area ~= desiredArea then
        desiredArea = area
        nextProbe = 0
        if pending then
            clearSound(pending.sound)
            pending = nil
        end
    end

    if fade then
        return
    end
    if pending then
        local sound = pending.sound
        if sound.IsLoaded and sound.TimeLength > 0 then
            local startPosition = pending.rotationPosition
            if startPosition == nil or endingIn(FADE_SECONDS + .2) or active.sound.TimePosition < startPosition then
                play(pending)
                pending = nil
            end
            return
        end
        if now < pending.deadline then
            return
        end
        -- Keep the outgoing track while Roblox resolves an unavailable or denied asset.
        retryAfter[pending.id] = now + RETRY_SECONDS
        clearSound(sound)
        pending = nil
    end

    if now < nextProbe then
        return
    end
    local rotating = active ~= nil and active.area == desiredArea
    if rotating and not endingIn(FADE_SECONDS + LOAD_TIMEOUT + .2) then
        return
    end
    if not probe(desiredArea, rotating) then
        if not active and desiredArea ~= "city" then
            probe("city", false)
        end
        nextProbe = now + 1
    end
end

local heartbeat = RunService.Heartbeat:Connect(function(dt)
    now += dt
    if now >= nextUpdate then
        nextUpdate = now + UPDATE_INTERVAL
        if not started then
            local hasSplash = playerGui:FindFirstChild("BeastDojoSplash") ~= nil
            sawSplash = sawSplash or hasSplash
            started = now >= SPLASH_LIMIT_SECONDS
                or (not hasSplash and (sawSplash or now >= SPLASH_DISCOVERY_SECONDS))
        end
        if started then
            updateVolume()
            updateMusic()
        end
    end

    local step = dt / VOLUME_RAMP_SECONDS
    music.Volume += math.clamp(volumeTarget - music.Volume, -step, step)
    if fade then
        local fraction = math.clamp((now - fade.start) / FADE_SECONDS, 0, 1)
        active.sound.Volume = math.sin(fraction * math.pi / 2)
        if fade.from then
            fade.from.sound.Volume = math.cos(fraction * math.pi / 2)
        end
        if fraction == 1 then
            if fade.from then
                clearSound(fade.from.sound)
            end
            fade = nil
        end
    end
end)

script.Destroying:Connect(function()
    heartbeat:Disconnect()
    firstSound:Destroy()
    secondSound:Destroy()
    music:Destroy()
end)
