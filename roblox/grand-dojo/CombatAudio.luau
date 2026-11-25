local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

local CombatAudio = {}

local assets = require(ReplicatedStorage:WaitForChild("CombatCueAssets"))
local cues = {
    light = {file = "Light thup", volume = .33},
    heavy = {file = "Planted impact", volume = .40},
    guard = {file = "Guard clack", volume = .34},
    parry = {file = "Parry chime", volume = .36},
    ground = {file = "Ground pulse", volume = .34},
    countdown = {file = "Countdown bell", volume = .24},
}
local groundPitch = {
    seismicChestPound = .86, magmaTrail = 1.08, tadpoleTornado = 1.16, gustVortex = 1.26,
    cavitationCannon = .72, tidalBellyFlop = .84, ["Breakwater Stamp"] = .93,
    thunderDive = 1.35, staticCharge = .80, apexPounce = 1.22,
    jawsOfTheDeep = 1.10, tentacleCataclysm = .76,
    eruptionSlam = .74, hellfireStampede = 1.21,
    talonDrop = 1.12, tempestRoar = 1.27, stormThunder = .69,
    pulse = .87, sweep = .98, undertow = .90, cataclysm = .82, solarFlare = 1.13,
}
local heavyPitch = {
    icecrestPalm = .92, ironbarkHammer = .82, furnaceBacklash = 1.09,
    heavy = 1, ridgePalm = .96, lilyVault = 1.12, spurLift = 1.19, bellySlide = 1.04, palm = .94, sunDive = .88,
    harborPalm = .91, shellCheck = .89, fortressRicochet = .79,
    plateCheck = .93, meteorRoll = .78, tailRake = 1.02, volcanicBreath = .88, hornCheck = .89, burrowHook = 1.08,
    reefHook = 1.04, tideGrip = .92,
    basaltBackhand = .81, cinderLunge = 1.14,
    stormClaw = .83,
    ["Kiln Rush"] = .98, ["Wind Court Return"] = 1.08, ["Harbor Sweep"] = .88,
}
local lightPitch = {
    floeHook = .88, canopyKnuckle = .96, coalstepKick = 1.15,
    jab = 1.06, cross = .98, body = .94, uppercut = 1.02, reedSweep = .86, reedstep = .92, emberSweep = 1.12,
    eddyPalm = .89, pebbleBarrage = 1.25, canopySlip = 1.16, featherFlurry = 1.20,
    tailFeint = 1.03, clawDash = .92, wingSweep = 1.19, unstoppableFrenzy = 1.30, jadeRake = 1.12,
    galeRake = 1.32,
    ["Kiln Jab"] = .96, ["Wind Jab"] = 1.10,
}
local countdownPitch = {1.10, 1.02, .96}
local hearDistance = 50
local duckDistance = 25
local duckDepth, duckHold, duckRelease = .17, .15, .34

local prepared = false
local voices = {}
local duckUntil = -math.huge
local lastBeat = 4
local recentCountdownAt
local countdownEnded = false

function CombatAudio.prepare()
    if prepared then
        return
    end
    prepared = true
    local sounds, worldFolder = {}, nil
    for cue, style in cues do
        local asset = assets[cue]
        if type(asset) ~= "string" or not string.match(asset, "^rbxassetid://[1-9]%d*$") then
            continue
        end
        local spatial = cue ~= "countdown"
        local slots = {}
        voices[cue] = slots
        for _ = 1, if spatial then 2 else 1 do
            local parent = SoundService
            if spatial then
                if not worldFolder then
                    worldFolder = Instance.new("Folder")
                    worldFolder.Name = "Local Dojo audio"
                    worldFolder.Parent = workspace
                end
                local anchor = Instance.new("Part")
                anchor.Name = style.file
                anchor.Anchored, anchor.CanCollide, anchor.CanTouch, anchor.CanQuery = true, false, false, false
                anchor.CastShadow, anchor.Transparency, anchor.Size = false, 1, Vector3.one * .05
                anchor.Parent = worldFolder
                parent = anchor
            end
            local sound = Instance.new("Sound")
            sound.Name, sound.SoundId, sound.Volume = style.file, asset, style.volume
            if spatial then
                sound.RollOffMode = Enum.RollOffMode.LinearSquare
                sound.RollOffMinDistance, sound.RollOffMaxDistance = 11, hearDistance
            end
            sound.Parent = parent
            local slot = {sound = sound, readyAt = 0}
            table.insert(slots, slot)
            sound.Played:Connect(function()
                if slot.duck then
                    duckUntil = os.clock() + duckHold
                end
            end)
            table.insert(sounds, sound)
        end
    end
    if #sounds > 0 then
        task.spawn(function()
            pcall(function()
                ContentProvider:PreloadAsync(sounds)
            end)
        end)
    end
end

local function playing(slot, now)
    return now < slot.readyAt or slot.sound.IsPlaying
end

local function play(cue, point, pitch, duck, restart)
    CombatAudio.prepare()
    local slots = voices[cue]
    if not slots then
        return
    end
    local now = os.clock()
    if point then
        local active = 0
        for other, spatialSlots in voices do
            if other ~= "countdown" then
                for _, slot in spatialSlots do
                    if playing(slot, now) then
                        active += 1
                    end
                end
            end
        end
        if active >= (if UserInputService.TouchEnabled then 4 else 6) then
            return
        end
    end
    for _, slot in slots do
        local sound = slot.sound
        if sound.IsLoaded and (restart or not playing(slot, now)) then
            if restart and sound.IsPlaying then
                sound:Stop()
            elseif point then
                sound.Parent.Position = point
            end
            -- Reserve the slot through the next render if Play has not reached the mixer yet.
            slot.readyAt = now + .05
            slot.duck = duck
            sound.PlaybackSpeed = pitch
            sound.TimePosition = 0
            sound:Play()
            return
        end
    end
end

function CombatAudio.musicGain()
    local released = math.clamp((os.clock() - duckUntil) / duckRelease, 0, 1)
    return 1 - duckDepth * (1 - released)
end

function CombatAudio.impact(kind, point, attack)
    local camera = workspace.CurrentCamera
    if not camera or typeof(point) ~= "Vector3" then
        return
    end
    local distance = (point - camera.CFrame.Position).Magnitude
    if distance >= hearDistance then
        return
    end
    local duck = distance <= duckDistance
    if kind == "parried" then
        play("parry", point, 1, duck)
    elseif kind == "deflected" then
        play("guard", point, 1.22, duck)
    elseif kind == "gustPull" then
        play("ground", point, .78, false)
    elseif kind == "diveKick" then
        play("heavy", point, .86, duck)
    elseif kind == "guardBroken" then
        play("heavy", point, .74, duck)
    elseif kind == "snared" then
        play("guard", point, .80, false)
    elseif kind == "blocked" or kind == "braced" then
        play("guard", point, if kind == "braced" then .92 else 1, duck)
    elseif kind == "burst" then
        play("ground", point, groundPitch[attack] or 1, duck)
    elseif kind == "strike" or kind == "counter" or kind == "hit" then
        if groundPitch[attack] then
            play("ground", point, groundPitch[attack], duck)
        elseif heavyPitch[attack] then
            play("heavy", point, heavyPitch[attack], duck)
        else
            play("light", point, lightPitch[attack] or 1, duck)
        end
    end
end

function CombatAudio.resetCountdown()
    lastBeat = 4
    recentCountdownAt = nil
    countdownEnded = false
end

function CombatAudio.countdown(remaining)
    if countdownEnded or type(remaining) ~= "number" or remaining ~= remaining then
        return
    end
    local now = os.clock()
    if remaining <= 0 then
        countdownEnded = true
        -- The start belongs to a countdown we actually observed just before zero.
        if remaining >= -.40 and recentCountdownAt and now - recentCountdownAt <= .75 then
            play("countdown", nil, .80, true, true)
        end
        return
    elseif remaining > 3 then
        return
    end
    if remaining <= .75 then
        recentCountdownAt = now
    end
    local beat = math.ceil(remaining)
    if beat < lastBeat then
        lastBeat = beat
        play("countdown", nil, countdownPitch[beat], true)
    end
end

return CombatAudio
