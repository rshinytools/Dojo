local Destination = require("../../roblox/grand-dojo/DojoPartyDestination")
local own = {UserId = 2, PlaceId = 100, JobId = "second"}
local host = {UserId = 1, PlaceId = 100, JobId = "first"}
local private = {UserId = 3, PlaceId = 100, JobId = "arena", PrivateServerId = "private"}
local other = {UserId = 4, PlaceId = 900, JobId = "elsewhere"}

local result = assert(Destination.find({private,other,host,own},2,100,"second"))
assert(result.nearby == 1 and result.inCity == 2 and result.hostJob == "first")
result = assert(Destination.find({host,own},1,100,"first"))
assert(result.hostJob == nil, "The anchor stays put when others regroup")
result = assert(Destination.find({own,private,other},2,100,"second"))
assert(result.hostJob == nil and result.inCity == 1, "Private and other-place members cannot be destinations")
assert(not Destination.find({host},2,100,"second"), "Stale rosters must fail closed")
assert(not Destination.find({host,{UserId = 2, PlaceId = 100, JobId = "old"}},2,100,"second"))
print("Party destinations passed split-city regroup, stable anchor, private-server exclusion and stale roster rejection.")
