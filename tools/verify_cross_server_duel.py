"""Exercise the cross-server Casual transport with the actual production modules."""

import argparse
from pathlib import Path
import subprocess
from tempfile import TemporaryDirectory


TOOLS = Path(__file__).resolve().parent
DOJO = TOOLS.parent / "roblox" / "grand-dojo"
FIXTURES = TOOLS / "cross_server_duel"

PORTS = r"""
local canInitialize, warnings, calls = false, 0, 0
local function warn(_) warnings += 1 end
local function require(_) error("Unexpected transport module") end
local Instance = {}
function Instance.new(class)
    assert(class == "TeleportOptions")
    return {SetTeleportData = function(options, packet) options.packet = packet end}
end
local player = {UserId = 777}
local teleport = {}
function teleport:TeleportAsync(place, players, options)
    assert(place == 953 and #players == 1 and players[1] == player)
    assert(options.ForcePublicServer and not options.ReservedServerId and not options.VipServerId)
    assert(options.packet.purpose == "casualDuelReturn" and options.packet.dispatch == "return-attempt")
    calls += 1
    return "sent"
end
local game = {GameId = 77, PlaceId = 953, JobId = "standalone-test"}
function game:GetService(name)
    assert(canInitialize and name == "TeleportService")
    return teleport
end
local script = {Parent = {}}
"""


def source(module):
    return (DOJO / f"{module}.luau").read_text()


def as_local(name, body):
    return f"local {name} = (function()\n{body}\nend)()\n"


def runtime_fixture():
    config = source("DuelTransportConfig")
    runtime = source("DuelTransportRuntime")
    line = 'local Config = require(script.Parent.DuelTransportConfig)'
    assert runtime.count(line) == 1
    runtime = runtime.replace(line, "", 1)
    disabled = as_local("Config", config) + as_local("Runtime", runtime) + """
assert(Runtime.get(false) == nil and Runtime.get(true) == nil)
assert(warnings == 0 and calls == 0)
print("Default staging gate leaves local Duel and progression isolated from transport.")
"""
    unavailable = as_local("Config", 'return {allows = function() return true end}')
    unavailable += as_local("Runtime", runtime) + """
assert(Runtime.get(false) == nil and Runtime.get(false) == nil)
assert(warnings == 1 and calls == 0)
canInitialize = true
local enabledRuntime = setmetatable({placeId = 953}, Runtime)
assert(enabledRuntime:returnToCity(player, "return-attempt") == "sent" and calls == 1)
print("Transport bootstrap errors fall back to local play. City return selects the normal public pool.")
"""
    constructors = {
        "DuelAssignments": "Assignments", "DuelQueueTickets": "Tickets", "DuelProfileBridge": "Bridge"
    }
    arena = "".join(as_local(name, source(module)) for module, name in constructors.items())
    arena += """
local Config = {allows = function() return true end, Protocol = "fixture"}
local modules = {DuelAssignments = Assignments, DuelQueueTickets = Tickets, DuelProfileBridge = Bridge}
local function require(name) return assert(modules[name]) end
local script = {Parent = {DuelAssignments = "DuelAssignments", DuelQueueTickets = "DuelQueueTickets",
    DuelProfileBridge = "DuelProfileBridge"}}
local Enum = {SortDirection = {Ascending = "ascending"}}
game.PrivateServerId, game.PrivateServerOwnerId = "match-reservation", 0
""" + as_local("Runtime", runtime) + """
local arena = assert(Runtime.get(false))
assert(arena.privateId == "match-reservation" and arena:profileRole(player) == "unknown")
local record, reason = arena.assignments:read("match-reservation")
assert(not record and reason == "unavailable")
print("A reserved job keeps its recovery path when the matching store cannot initialize.")
"""
    return PORTS + "".join(f"do\n{case}\nend\n" for case in (disabled, unavailable, arena))


def party_service_fixture():
    destination = as_local("Destination", source("DojoPartyDestination"))
    services = source("DojoPartyService").replace("local Destination = require(script.Parent.DojoPartyDestination)", "", 1)
    return (FIXTURES / "party_service_ports.luau").read_text() + destination + as_local("PartyService", services) + (
        FIXTURES / "party_service_cases.luau"
    ).read_text()


def stored_profile_fixture():
    body = source("PlayerProfiles")
    declarations, body = body.split("local PlayerProfiles = {}", 1)
    assert declarations.count("require(") == 5
    modules = ("FighterForms", "FighterTactics", "FighterLoadouts", "FighterLevelCurve", "CityAdventureCatalog", "QuickPlayCatalog")
    adventure = source("CityAdventureProgress").replace(
        "local Catalog = require(script.Parent.CityAdventureCatalog)", "local Catalog = CityAdventureCatalog", 1
    ).replace('local QuickPlay = require(game:GetService("ReplicatedStorage").QuickPlayCatalog)', "local QuickPlay = QuickPlayCatalog", 1)
    return "".join(as_local(name, source(name)) for name in modules) + as_local(
        "CityAdventureProgress", adventure
    ) + as_local(
        "PlayerProfiles", "local PlayerProfiles = {}" + body
    ) + (FIXTURES / "return_release.luau").read_text()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("luau", help="Path to the standalone Luau interpreter, or an executable on PATH")
    args = parser.parse_args()
    for name in ("profile_bridge", "source_return", "party_regroup"):
        subprocess.run([args.luau, FIXTURES / f"{name}.luau"], check=True)
    with TemporaryDirectory() as temp:
        for name, fixture in (("runtime", runtime_fixture), ("durable_lease", stored_profile_fixture),
                              ("party_service", party_service_fixture)):
            path = Path(temp) / f"{name}.luau"
            path.write_text(fixture())
            subprocess.run([args.luau, path], check=True)


if __name__ == "__main__":
    main()
