"""Exercise ranked ledger recovery and the Studio player-ID adapter with Luau."""

import argparse
from pathlib import Path
import subprocess
from tempfile import TemporaryDirectory


GRAND_DOJO = Path(__file__).resolve().parents[1] / "roblox" / "grand-dojo"
FIXTURE = r"""
local values, clock = {}, 100000
local store = {}
function store:UpdateAsync(key, change)
    if self.failKey == key then error("Store unreachable") end
    local value = change(values[key])
    if value then
        values[key] = value
        if self.loseReply == key then
            self.failKey = key
            error("Write succeeded but the reply was lost")
        end
    end
    return value
end

local function server()
    return Ledger.new(store, function() return clock end, function() end)
end

local function expectProfile(ledger, user, points, games)
    local record = assert(ledger:read(user))
    assert(record.points == points and record.games == games)
end

local owner = server()
local ticket = assert(owner:reserve("lost-journal-reply", 7, 8))
store.loseReply = "m_lost-journal-reply"
local report, reason = owner:commit(ticket, 1)
assert(report == nil and reason == "unavailable")
assert(values["m_lost-journal-reply"].state == "committed" and values.p_7.pending and values.p_8.pending)
store.loseReply, store.failKey = nil, nil
local restarted = server()
expectProfile(restarted, 8, 1184, 1)
expectProfile(restarted, 7, 1216, 1)
assert(assert(restarted:commit(ticket, 1))[1].delta == 16)
expectProfile(restarted, 7, 1216, 1)

local split = assert(restarted:reserve("lost-profile-reply", 8, 12))
store.loseReply = "p_8"
report, reason = restarted:commit(split, 0)
assert(report == nil and reason == "pending" and not values.p_12.pending)
store.loseReply, store.failKey = nil, nil
local rejoined = server()
local updatedPoints = values.p_8.points
expectProfile(rejoined, 8, updatedPoints, 2)
local nextMatch = assert(rejoined:reserve("newer-claim", 8, 10))
assert(assert(rejoined:commit(split, 0))[1].after == updatedPoints)
assert(values.p_8.pending == nextMatch.id and values.p_8.games == 2)
assert(rejoined:cancel(nextMatch))
expectProfile(rejoined, 8, updatedPoints, 2)

local abandoned = assert(rejoined:reserve("expired", 7, 8))
clock = abandoned.expiresAt
expectProfile(server(), 7, 1216, 1)
report, reason = owner:commit(abandoned, 1)
assert(report == nil and reason == "cancelled")
expectProfile(server(), 8, updatedPoints, 2)
print("Ranked ledger passed lost journal/profile replies, reconnect, stale replay and lease expiry.")
"""

STUDIO_FIXTURE = r"""
local liveId = makeRankIdentity(false)
local studioId = makeRankIdentity(true)
assert(liveId({UserId = 1}) == 1)
assert(liveId({UserId = -1}) == -1)
local first = studioId({UserId = -1})
local second = studioId({UserId = -2})
local sameNumberPositive = studioId({UserId = 1})
assert(first ~= second and first ~= sameNumberPositive and second ~= sameNumberPositive)
assert(studioId({UserId = -1}) == first)

local isolated = Ledger.new(Ledger.memoryStore(), function() return clock end, function() end)
assert(isolated:read(liveId({UserId = -1})) == nil)
local studioTicket = assert(isolated:reserve("studio-duel", first, second))
assert(isolated:commit(studioTicket, 1))
expectProfile(isolated, studioId({UserId = -1}), 1216, 1)
expectProfile(isolated, studioId({UserId = -2}), 1184, 1)
expectProfile(isolated, sameNumberPositive, 1200, 0)
print("Studio ranked identities stayed distinct and stable, and the ledger kept its live ID validation.")
"""


def identity_adapter(server):
    # Extract the small adapter without booting the rest of the game in standalone Luau.
    declarations = [
        line for line in server.splitlines()
        if line.startswith(("local studio =", "local studioRankIds,"))
    ]
    assert len(declarations) == 2
    start = server.index("local function rankUserId(")
    end = server.index("\nlocal function readRank(", start)
    return "\n".join((
        "local function makeRankIdentity(isStudio)",
        "local RunService = { IsStudio = function() return isStudio end }",
        *declarations, server[start:end], "return rankUserId", "end",
    ))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("luau", nargs="?", default="luau", help="Standalone Luau runner path or command")
    args = parser.parse_args()

    rules = (GRAND_DOJO / "DuelRankRules.luau").read_text(encoding="utf-8")
    ledger = (GRAND_DOJO / "DuelRankLedger.luau").read_text(encoding="utf-8")
    server = (GRAND_DOJO / "GrandDojoDuel.server.luau").read_text(encoding="utf-8")
    source = "\n".join((
        "local Rules = (function()", rules, "end)()",
        "local Ledger = (function()",
        'local script = {Parent = {WaitForChild = function(_, name) return name end}}',
        'local require = function(name) assert(name == "DuelRankRules"); return Rules end',
        ledger, "end)()", FIXTURE, identity_adapter(server), STUDIO_FIXTURE,
    ))
    with TemporaryDirectory() as temporary:
        combined = Path(temporary) / "ranked_ledger.luau"
        combined.write_text(source, encoding="utf-8")
        subprocess.run([args.luau, str(combined)], check=True)


if __name__ == "__main__":
    main()
