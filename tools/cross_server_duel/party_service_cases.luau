PartyService.mount(remote, function() return canTravel end)
command("view")
assert(state.canRegroup and state.inCity == 2 and state.nearby == 1 and state.hostJob == nil)
canTravel = false
command("regroup")
assert(sends == 0 and #messages == 1)
canTravel, inStudio = true, true
command("regroup")
assert(sends == 0)
inStudio = false
shouldFail = true
command("regroup")
assert(sends == 1 and not attributes.DojoPartyTravel)
shouldFail = false
command("regroup")
assert(sends == 2 and attributes.DojoPartyTravel)
TeleportService.TeleportInitFailed:Fire(player,nil,nil,100,options[1])
assert(attributes.DojoPartyTravel, "A stale callback cannot clear the current hold")
TeleportService.TeleportInitFailed:Fire(player,nil,nil,100,options[2])
assert(not attributes.DojoPartyTravel)
command("regroup")
assert(sends == 3 and attributes.DojoPartyTravel)
tasks[1]()
assert(attributes.DojoPartyTravel, "An earlier timeout cannot clear the current hold")
tasks[2]()
assert(not attributes.DojoPartyTravel)
partyData = {destination}
command("regroup")
assert(sends == 3, "An unconfirmed party member cannot start travel")
game.PrivateServerId = "arena"
command("regroup")
assert(sends == 3)
print("Party service passed native API port checks for busy, Studio, stale party, failed dispatch and timeout.")
