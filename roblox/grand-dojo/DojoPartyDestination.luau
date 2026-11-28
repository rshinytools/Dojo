-- Roblox orders party records by when members accepted the invitation.
local Destination = {}

function Destination.find(members, userId, placeId, jobId)
    local ownRecord, host = false, nil
    local inCity, nearby = 0, 0
    for _, member in members do
        if type(member) == "table" and member.PlaceId == placeId and type(member.JobId) == "string"
            and member.JobId ~= "" and (member.PrivateServerId == nil or member.PrivateServerId == "") then
            inCity += 1
            if member.JobId == jobId then nearby += 1 end
            if member.UserId == userId and member.JobId == jobId then ownRecord = true end
            host = host or member.JobId
        end
    end
    if not ownRecord then return nil end
    return {
        nearby = nearby,
        inCity = inCity,
        hostJob = if host ~= jobId then host else nil,
    }
end

return Destination
