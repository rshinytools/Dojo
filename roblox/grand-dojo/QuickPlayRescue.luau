local Rescue = {}

local BOARD_WIDTH = 3
local LANTERNS = {3, 1, 9, 7, 3, 9, 7, 1, 3}
local WEST_CURRENT = table.freeze({[2] = true, [4] = true})
local EAST_CURRENT = table.freeze({[2] = true, [6] = true})
local STEP_INTERVAL = 0.12
local LANTERNS_FOR_SILVER = 2
local LANTERNS_FOR_GOLD = 4

Rescue.Duration = 35
Rescue.TileCount = BOARD_WIDTH ^ 2
Rescue.Dock = 8
Rescue.Keepsake = "Reedfall Paper Boat"

function Rescue.new(startedAt)
    return {
        startedAt = startedAt,
        score = 0,
        position = Rescue.Dock,
        holding = false,
        lastMoveAt = startedAt - STEP_INTERVAL,
    }
end

function Rescue.currents(score)
    return if score % 2 == 0 then WEST_CURRENT else EAST_CURRENT
end

function Rescue.target(round)
    return if round.holding then Rescue.Dock else LANTERNS[round.score + 1]
end

function Rescue.validTile(tile)
    return type(tile) == "number" and tile >= 1 and tile <= Rescue.TileCount and tile % 1 == 0
end

function Rescue.neighbors(a, b)
    if not Rescue.validTile(a) or not Rescue.validTile(b) then
        return false
    end
    local rowA, columnA = math.floor((a - 1) / BOARD_WIDTH), (a - 1) % BOARD_WIDTH
    local rowB, columnB = math.floor((b - 1) / BOARD_WIDTH), (b - 1) % BOARD_WIDTH
    return math.abs(rowA - rowB) + math.abs(columnA - columnB) == 1
end

-- Only the server advances the boat, records its load and decides when a rescue counts.
function Rescue.move(round, tile, now)
    if Rescue.finished(round, now) or now < round.startedAt then
        return nil
    end
    if now - round.lastMoveAt + 1e-6 < STEP_INTERVAL then
        return nil
    end
    if not Rescue.neighbors(round.position, tile) then
        return "neighbor"
    end
    if Rescue.currents(round.score)[tile] then
        return "current"
    end

    round.position = tile
    round.lastMoveAt = now
    if tile == Rescue.target(round) then
        if round.holding then
            round.score += 1
            round.holding = false
            return "delivered"
        end
        round.holding = true
        return "picked-up"
    end
    return "moved"
end

function Rescue.finished(round, now)
    return now >= round.startedAt + Rescue.Duration or round.score >= #LANTERNS
end

function Rescue.rank(score)
    if score >= LANTERNS_FOR_GOLD then
        return "Gold"
    end
    return if score >= LANTERNS_FOR_SILVER then "Silver" else "Try again"
end

return table.freeze(Rescue)
