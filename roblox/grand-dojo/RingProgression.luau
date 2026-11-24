local RingProgression = {}

RingProgression.Order = {"grand-dojo", "cinder", "cloud-top", "galleon"}
RingProgression.ById = {
    ["grand-dojo"] = {
        name = "Grand Dojo Ring", botId = "juniper", level = 1, xp = 0,
        pvp = true, training = "Lantern Timing in Festival Plaza",
    },
    cinder = {
        name = "Cinder Terraces Ring", botId = "bracken", level = 3, xp = 180,
        pvp = false, training = "Lantern Timing or the Lantern Relay",
    },
    ["cloud-top"] = {
        name = "Cloud-Top Temple", botId = "sablecrest", level = 5, xp = 460,
        pvp = false, training = "Kiln Rhythm, the Lantern Relay, or Bot Spar",
    },
    galleon = {
        name = "Galleon Ring", botId = "granite", level = 7, xp = 830,
        pvp = false, training = "Wind Court Signals, the Lantern Relay, or Bot Spar",
    },
}

RingProgression.DrillOrder = {"lantern-timing", "kiln-rhythm", "wind-signals"}
RingProgression.Drills = {
    ["lantern-timing"] = {
        name = "Lantern Timing",
        xp = 40,
        cues = {"Reed Lantern", "Copper Lantern", "Jade Lantern"},
    },
    ["kiln-rhythm"] = {
        name = "Kiln Rhythm",
        xp = 40,
        cues = {"Open Intake", "Pump Bellows", "Vent Kiln"},
    },
    ["wind-signals"] = {
        name = "Wind Court Signals",
        xp = 40,
        cues = {"Lower Flag", "Bridge Flag", "Summit Flag"},
    },
}

RingProgression.DrillCooldown = 45
RingProgression.DrillWindow = 50
RingProgression.CueSettle = 1.35

function RingProgression.access(highestLevel, fighterLevel, ringId)
    local ring = RingProgression.ById[ringId]
    if not ring then
        return false, "This ring is unavailable."
    end
    if not (type(highestLevel) == "number" and highestLevel >= 1) then
        return false, "Your fighter progress is still loading."
    end
    if highestLevel < ring.level then
        return false, string.format("%s opens at Level %d (%d XP). Train with %s.",
            ring.name, ring.level, ring.xp, ring.training)
    end
    if type(fighterLevel) == "number" and fighterLevel < ring.level then
        return true, string.format("Ring open. Level %d recommended, your fighter is Level %d.",
            ring.level, fighterLevel)
    end
    return true, string.format("Ring open. Level %d recommended.", ring.level)
end

function RingProgression.beginDrill(drillId, now)
    local drill = RingProgression.Drills[drillId]
    if drill then
        return {id = drillId, index = 1, readyAt = now + RingProgression.CueSettle,
            expiresAt = now + RingProgression.DrillWindow}
    end
    return nil
end

function RingProgression.drillCue(trial, index, now)
    local config = RingProgression.Drills[trial.id]
    if not config or now >= trial.expiresAt then
        return "expired"
    elseif trial.index > #config.cues then
        return "complete"
    elseif index ~= trial.index then
        return "wrong"
    elseif now < trial.readyAt then
        return "early"
    end
    trial.index += 1
    trial.readyAt = now + RingProgression.CueSettle
    return if trial.index > #config.cues then "finished" else "advance"
end

return RingProgression
