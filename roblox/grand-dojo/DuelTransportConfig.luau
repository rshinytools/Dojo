-- Explicit staging allowlist. Keep disabled until queue and return integration is verified.
local Config = {Enabled = false, UniverseId = 0, PlaceId = 0, Protocol = "casual-v1"}

function Config.allows(universeId, placeId, jobId, studio)
    return Config.Enabled and not studio and Config.UniverseId > 0 and Config.PlaceId > 0
        and universeId == Config.UniverseId and placeId == Config.PlaceId and type(jobId) == "string" and jobId ~= ""
end

return table.freeze(Config)
