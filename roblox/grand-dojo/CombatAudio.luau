local ContentProvider = game:GetService("ContentProvider")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

local CombatAudio = {}

-- Original WAV sources and their import names live in art/combat-audio.
-- Only released Roblox audio IDs for those recordings belong in this table.
local assets = {}
local cues = {
    light = {file = "Light thup", volume = .33},
    heavy = {file = "Planted impact", volume = .40},
    guard = {file = "Guard clack", volume = .34},
    parry = {file = "Parry chime", volume = .36},
    ground = {file = "Ground pulse", volume = .34},
    countdown = {file = "Countdown bell", volume = .24},
}
local groundAttacks = {seismicChestPound = true, magmaTrail = true, ["Breakwater Stamp"] = true}
local heavyAttacks = {
    heavy = true, ridgePalm = true, bellySlide = true, palm = true,
    ["Kiln Rush"] = true, ["Wind Court Return"] = true, ["Harbor Sweep"] = true,
}
local lightPitch = {jab = 1.06, cross = .98, body = .94, uppercut = 1.02}
local countdownPitch = {1.10, 1.02, .96}
local hearDistance = 50

local prepared = false
local voices = {}
local lastBeat = 4

function CombatAudio.prepare()
    if prepared then
        return
    end
    prepared = true
    local sounds, worldFolder = {}, nil
    for cue, asset in assets do
        local style = cues[cue]
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
            table.insert(slots, {sound = sound, readyAt = 0})
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

local function play(cue, point, pitch)
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
        if sound.IsLoaded and not playing(slot, now) then
            if point then
                sound.Parent.Position = point
            end
            -- Reserve the slot through the next render if Play has not reached the mixer yet.
            slot.readyAt = now + .05
            sound.PlaybackSpeed = pitch
            sound.TimePosition = 0
            sound:Play()
            return
        end
    end
end

function CombatAudio.impact(kind, point, attack)
    local camera = workspace.CurrentCamera
    if not camera or typeof(point) ~= "Vector3" or (point - camera.CFrame.Position).Magnitude >= hearDistance then
        return
    end
    if kind == "parried" then
        play("parry", point, 1)
    elseif kind == "blocked" or kind == "braced" then
        play("guard", point, if kind == "braced" then .92 else 1)
    elseif kind == "burst" then
        play("ground", point, 1)
    elseif kind == "strike" or kind == "counter" or kind == "hit" then
        if groundAttacks[attack] then
            play("ground", point, 1)
        elseif heavyAttacks[attack] then
            play("heavy", point, 1)
        else
            play("light", point, lightPitch[attack] or 1)
        end
    end
end

function CombatAudio.resetCountdown()
    lastBeat = 4
end

function CombatAudio.countdown(remaining)
    if not (remaining > 0 and remaining <= 3) then
        return
    end
    local beat = math.ceil(remaining)
    if beat < lastBeat then
        lastBeat = beat
        play("countdown", nil, countdownPitch[beat])
    end
end

return CombatAudio
