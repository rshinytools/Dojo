local Rescue = require("../roblox/grand-dojo/QuickPlayRescue")

local startedAt = 500
local round = Rescue.new(startedAt)
assert(round.score == 0 and round.position == 8 and Rescue.target(round) == 3)
assert(Rescue.move(round, 5, startedAt - 0.01) == nil)
assert(Rescue.move(round, 4, startedAt) == "neighbor")
assert(Rescue.move(round, 11, startedAt) == "neighbor")
assert(Rescue.move(round, 1.5, startedAt) == "neighbor")
assert(Rescue.move(round, 0 / 0, startedAt) == "neighbor")
assert(Rescue.move(round, 5, startedAt) == "moved")
assert(Rescue.move(round, 6, startedAt + 0.03) == nil)
assert(Rescue.move(round, 4, startedAt + 0.12) == "current")
assert(Rescue.move(round, 2, startedAt + 0.12) == "current")
assert(Rescue.move(round, 6, startedAt + 0.12) == "moved")
assert(Rescue.move(round, 7, startedAt + 0.24) == "neighbor", "Row wrapping must fail")
assert(Rescue.move(round, 3, startedAt + 0.24) == "picked-up")
assert(round.holding and Rescue.target(round) == Rescue.Dock and round.score == 0)
assert(Rescue.move(round, 6, startedAt + 0.36) == "moved")
assert(Rescue.move(round, 5, startedAt + 0.48) == "moved")
assert(Rescue.move(round, 8, startedAt + 0.60) == "delivered")
assert(not round.holding and round.score == 1 and Rescue.target(round) == 1)
assert(Rescue.currents(round.score)[6] and not Rescue.currents(round.score)[4])
assert(Rescue.move(round, 5, startedAt + 0.72) == "moved")
assert(Rescue.move(round, 6, startedAt + 0.84) == "current")
assert(Rescue.move(round, 4, startedAt + 0.84) == "moved")
assert(not Rescue.finished(round, startedAt + 34.99))
assert(Rescue.finished(round, startedAt + 35))
assert(Rescue.move(round, 1, startedAt + 35) == nil and round.score == 1)

local function nextMove(state)
    local target = Rescue.target(state)
    local current = Rescue.currents(state.score)
    local queue = {{tile = state.position}}
    local seen = {[state.position] = true}
    local i = 1
    while i <= #queue do
        local item = queue[i]
        if item.tile == target then
            return item.first
        end
        for neighbor = 1, Rescue.TileCount do
            if not current[neighbor] and not seen[neighbor] and Rescue.neighbors(item.tile, neighbor) then
                queue[#queue + 1] = {tile = neighbor, first = item.first or neighbor}
                seen[neighbor] = true
            end
        end
        i += 1
    end
    error("A shifting current cut all routes to the objective")
end

local clean = Rescue.new(1000)
local now = clean.startedAt
local ranks = {[1] = "Try again", [2] = "Silver", [3] = "Silver", [4] = "Gold"}
for _ = 1, 60 do
    if Rescue.finished(clean, now) then break end
    local move = Rescue.move(clean, nextMove(clean), now)
    if move == "delivered" and ranks[clean.score] then
        assert(Rescue.rank(clean.score) == ranks[clean.score])
    end
    now += 0.5
end
assert(clean.score == 9 and clean.position == Rescue.Dock and Rescue.finished(clean, now))
assert(Rescue.move(clean, 5, now + 1) == nil)
print("Reedfall Rescue passed the authoritative 35-second run, current changes, medal gates and invalid moves")
