"""Exercise asynchronous ownership checks in the fighter cosmetic pass service."""

import argparse
from pathlib import Path
import subprocess
from tempfile import TemporaryDirectory

from verify_cross_server_duel import as_local, source


PORTS = """
local function signal()
    local callbacks = {}
    return {
        Connect = function(_, callback) table.insert(callbacks, callback) end,
        fire = function(_, ...) for _, callback in callbacks do callback(...) end end,
    }
end

local pending, deferred = nil, {}
local task = {}
function task.spawn(fn, ...)
    local ok, failure = coroutine.resume(coroutine.create(fn), ...)
    assert(ok, failure)
end
function task.defer(fn, ...)
    local args = table.pack(...)
    table.insert(deferred, function() fn(table.unpack(args, 1, args.n)) end)
end
local function flush()
    while #deferred > 0 do table.remove(deferred, 1)() end
end

local attrs, ids, queries, owned = {}, {}, {}, {}
local player = {UserId = 12}
function player:SetAttribute(name, value) attrs[name] = value end
function player:GetAttribute(name) return attrs[name] end
for index, item in Catalog.Items do ids[item.id] = 100 + index end

local purchase = signal()
local marketplace = {PromptGamePassPurchaseFinished = purchase}
local pausePass
function marketplace:UserOwnsGamePassAsync(userId, id)
    assert(userId == player.UserId)
    queries[id] = (queries[id] or 0) + 1
    if pausePass == id then
        pausePass = nil
        pending = coroutine.running()
        return coroutine.yield()
    end
    return owned[id] == true
end

local snapshot = {UpdateAvailable = signal()}
function snapshot:GetValueChangedSignal() return signal() end
function snapshot:GetValue(key)
    assert(key == Catalog.PassConfig)
    return ids
end
local services = {
    ConfigService = {GetConfigAsync = function() return snapshot end},
    MarketplaceService = marketplace,
    Players = {PlayerAdded = signal(), PlayerRemoving = signal(), GetPlayers = function() return {player} end},
}
local game = {GetService = function(_, name) return services[name] end}
local remote = {SetAttribute = function() end}
"""

CASES = """
local service = FighterPasses.mount(remote)
local function exercise(item, purchased)
    local id = ids[item.id]
    local attribute = Catalog.attribute("CosmeticOwnership", item.id)
    assert(attrs[attribute] == "locked")
    local before = queries[id]
    pausePass = id
    service.refresh(player, item.id)
    assert(pending and coroutine.status(pending) == "suspended")
    owned[id] = purchased
    purchase:fire(player, id, purchased)
    if purchased then purchase:fire(player, id, true) end
    assert(queries[id] == before + 1, "duplicate in-flight ownership lookup")
    local resumed, failure = coroutine.resume(pending, false)
    assert(resumed, failure)
    pending = nil
    flush()
    assert(queries[id] == before + (if purchased then 2 else 1), "unexpected follow-up lookup")
    assert(attrs[attribute] == (if purchased then "owned" else "locked"), "wrong ownership after checkout")
    assert(service.canEquip(player, item.id) == purchased)
end
exercise(Catalog.Items[1], true)
exercise(Catalog.Items[2], false)
for index = 3, #Catalog.Items do
    local item = Catalog.Items[index]
    assert(queries[ids[item.id]] == 1)
    assert(attrs[Catalog.attribute("CosmeticOwnership", item.id)] == "locked")
end
print("Fighter pass checkout refresh, cancellation and independent ownership passed.")
"""


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("luau", help="Path to a standalone Luau interpreter")
    args = parser.parse_args()
    runtime = source("DojoFighterPasses")
    catalog_import = 'local Catalog = require(ReplicatedStorage:WaitForChild("DojoCosmeticCatalog"))'
    assert runtime.count(catalog_import) == 1
    runtime = runtime.replace(catalog_import, "", 1)
    program = as_local("Catalog", source("DojoCosmeticCatalog"))
    program += PORTS + as_local("FighterPasses", runtime) + CASES
    with TemporaryDirectory(prefix="beast-dojo-fighter-passes-") as folder:
        fixture = Path(folder) / "verify.luau"
        fixture.write_text(program)
        subprocess.run([args.luau, fixture], check=True)


if __name__ == "__main__":
    main()
