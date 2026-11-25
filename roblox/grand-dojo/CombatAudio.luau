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
    lanternBreak = 1.03,
    glacierRing = 1.21, hearthCircle = .95, estuaryRing = 1.09,
    staticPerch = 1.27, trenchRing = .68,
    seismicChestPound = .86, magmaTrail = 1.08, tadpoleTornado = 1.16, gustVortex = 1.26,
    cavitationCannon = .72, tidalBellyFlop = .84, ["Breakwater Stamp"] = .93,
    thunderDive = 1.35, staticCharge = .80, apexPounce = 1.22,
    jawsOfTheDeep = 1.10, tentacleCataclysm = .76,
    eruptionSlam = .74, hellfireStampede = 1.21,
    talonDrop = 1.12, tempestRoar = 1.27, stormThunder = .69,
    pulse = .87, sweep = .98, undertow = .90, cataclysm = .82, solarFlare = 1.13,
}
local heavyPitch = {
    furnaceGate = 0.76, foundryTurn = 0.88,
    cinderCrown = 0.87, violetCross = 1.02,
    sunfanCrash = 0.98, crownArc = 1.13,
    thunderheadDrop = 0.93, cirrusBreaker = 1.12,
    festivalCross = 1.05,
    frostwake = 1.17, cedarCrash = .92, forestClamp = .84, crucibleArc = 1.06,
    lilyCrash = .96, marshBarrage = 1.09, riverRush = 1.16, roostHammer = .88,
    sunriseArc = 1.15, canopyClap = 1.20, duskWheel = 1.27,
    sunforgeClasp = .92, stingerRelay = 1.08, coralGate = 1.16, quaysideCross = 1.24,
    mooringDrop = .78, tidelineClap = .88, stonegatePress = .84, keystoneTurn = .94,
    bastionPress = .80, forgeCadence = .91, obsidianDrop = .84, ashlineTurn = 1.03,
    splitGale = 1.23, summitPress = .89, switchback = .97,
    honeycombCrush = .78, hollowHammer = .93, groveBreak = .86, verdantCross = 1.08,
    whitecapBreak = .96, surgeCross = 1.16, reefbreakerCross = 1.03,
    forgeShoulder = .81, blackglassSweep = 1.07, crosswindWing = 1.18, nimbusTail = .93,
    quarryBackhand = .86, emeraldProwl = .93, undertowHeel = .94, maelstromPalm = .79,
    kilnShoulder = .83, cinderHeel = 1.06, thunderclapWing = 1.18, ridgelineDrive = .79,
    duneLash = 1.04, tidebreakerClaw = .89, basinPress = .80, rampartBash = .77,
    pondboundHeel = 1.08, breakwaterPalm = .91, crestWheel = 1.11, sailSwipe = 1.15,
    icecrestPalm = .92, glacierPress = .86, reedstoneHeel = .95, ironbarkHammer = .82, furnaceBacklash = 1.09,
    heavy = 1, ridgePalm = .96, lilyVault = 1.12, spurLift = 1.19, bellySlide = 1.04, palm = .94, sunDive = .88,
    harborPalm = .91, shellCheck = .89, fortressRicochet = .79,
    plateCheck = .93, meteorRoll = .78, tailRake = 1.02, volcanicBreath = .88, hornCheck = .89, burrowHook = 1.08,
    reefHook = 1.04, tideGrip = .92,
    basaltBackhand = .81, cinderLunge = 1.14,
    stormClaw = .83,
    ["Kiln Rush"] = .98, ["Wind Court Return"] = 1.08, ["Harbor Sweep"] = .88,
}
local lightPitch = {
    cinderTap = 0.96, smelterToe = 0.83,
    coalFlick = 1.07, slateToe = 0.94,
    aerieTap = 1.27, ridgeTalon = 1.10,
    zephyrKnuckle = 1.21, cloudbankToe = 1.07,
    reedCheck = 1.09, courtyardToe = .97,
    rimeTap = 1.24, skateToe = 1.11, fernCheck = .99, timberToe = .89, sootPalm = 1.12, kilnToe = 1.00,
    pondTap = 1.08, bankKick = 1.01, runnelTap = 1.15, currentHeel = .96,
    roostTap = 1.13, sunspur = 1.04, sailTap = 1.22, branchToe = 1.06,
    flintCheck = 1.06, siltScoop = .96, coralCheck = 1.19, dockKick = 1.11,
    dockTap = .91, brineToe = .87, masonTap = .98, plinthToe = .92,
    tileJab = 1.04, cobbleToe = .92, kilnKnuckle = 1.10, sootstep = .97,
    skyFletch = 1.28, perchHook = 1.14, slateJab = .99, cragToe = .89,
    brambleCheck = 1.02, thicketToe = .85, vineFlick = 1.19, briarStep = .94,
    saltTap = 1.25, sandbarToe = 1.11, reefCurl = 1.15, tidepoolToe = .99,
    pumiceKnuckle = .91, emberKnuckle = 1.09, gildedFlick = 1.23, horizonPalm = 1.07,
    copperKnuckle = 1.04, mossPalm = 1.13, shoalPalm = 1.17, currentTap = 1.22,
    rivetPalm = .98, ashenSnap = 1.18, quillFlick = 1.28, stoneTap = 1.05,
    sandPincer = 1.14, jetSnap = 1.27, whiskerCheck = .91, quickSnap = 1.1,
    mudPalm = 1.08, brookHook = .98, perchPeck = 1.19, boughSnap = 1.15,
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

local interruptPriority = {light = 1, ground = 2, heavy = 3, guard = 4}

local function reserveSpatialVoice(now, prioritizeParry)
    local active, replace, rank = 0, nil, math.huge
    for cue, slots in voices do
        if cue == "countdown" then continue end
        local priority = prioritizeParry and interruptPriority[cue]
        for _, slot in slots do
            if not playing(slot, now) then continue end
            active += 1
            if priority and (priority < rank or (priority == rank and slot.readyAt < replace.readyAt)) then
                replace, rank = slot, priority
            end
        end
    end
    local limit = if UserInputService.TouchEnabled then 4 else 6
    if active < limit then return true end
    if active == limit and replace then
        -- Prefer the nearby parry over a weaker contact without raising the mixer budget.
        replace.readyAt, replace.duck = 0, false
        replace.sound:Stop()
        return true
    end
    return false
end

local function play(cue, point, pitch, duck, restart)
    CombatAudio.prepare()
    local slots = voices[cue]
    if not slots then
        return
    end
    local now = os.clock()
    for _, slot in slots do
        local sound = slot.sound
        if sound.IsLoaded and (restart or not playing(slot, now)) then
            if point and not reserveSpatialVoice(now, cue == "parry" and duck) then return end
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
