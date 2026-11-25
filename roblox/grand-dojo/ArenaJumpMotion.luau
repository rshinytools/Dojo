-- Shared arena eligibility and presentation based on observed jump height.
local Jump = {}
Jump.tag = "ArenaJumpFighter"
Jump.standingHeight = 2.1326
local landingDuration = .19

local function ease(value)
    local t = math.clamp(value, 0, 1)
    return t * t * (3 - 2 * t)
end

function Jump.open(character, floor)
    character:SetAttribute("ArenaJumpFloor", floor)
    character:AddTag(Jump.tag)
end

function Jump.allow(character, enabled)
    if character and character:GetAttribute("ArenaJumpEnabled") ~= enabled then
        character:SetAttribute("ArenaJumpEnabled", enabled)
    end
end

function Jump.close(character)
    if character then
        character:RemoveTag(Jump.tag)
        character:SetAttribute("ArenaJumpEnabled", nil)
        character:SetAttribute("ArenaJumpFloor", nil)
    end
end

function Jump.track(sample, now, height, speed, support)
    local rise = height - (sample.height or height)
    sample.height = height
    local nearDeck = support and math.abs(height) <= .21

    if sample.launchedAt then
        sample.peak = math.max(sample.peak, height)
        -- A Humanoid can cross its settled height before the local solver
        -- pushes it back up. Accept that contact when there is real deck below.
        if support and height >= -.64 and height <= .21 and rise <= .06 and now - sample.launchedAt > .08 then
            sample.launchedAt, sample.landedAt = nil, now
        elseif height < -1 or now - sample.launchedAt > 1.4 then
            sample.launchedAt, sample.groundedAt = nil, nil
        else
            return if now - sample.launchedAt < .11 then "takeoff" else "airborne"
        end
    elseif sample.groundedAt and now - sample.groundedAt <= .29
        and height > .21 and (rise >= .09 or speed > 6) then
        sample.launchedAt, sample.landedAt, sample.peak = now, nil, height
        return "takeoff"
    end

    if nearDeck and (math.abs(speed) <= 5 or math.abs(rise) <= .035) then
        sample.groundedAt = now
    end
    if sample.landedAt and height >= -.64 and height <= .26 and now - sample.landedAt < landingDuration then
        return "landing"
    end
    sample.landedAt = nil
    return nil
end

local function turn(pitch, roll)
    return CFrame.Angles(math.rad(pitch), 0, math.rad(roll or 0))
end

function Jump.pose(sample, phase, now, legScale)
    if phase == "landing" then
        local absorb = 1 - ease((now - sample.landedAt) / landingDuration)
        return {
            ["Right Arm"] = turn(-16 * absorb, 5 * absorb),
            ["Left Arm"] = turn(-12 * absorb, -5 * absorb),
            Tail = turn(12 * absorb),
        }, 0
    end

    local age = now - sample.launchedAt
    local extension = ease(sample.height / 1.35)
    local descent = ease((sample.peak - sample.height) / math.max(1, sample.peak * .87))
    local spring = ease((age + .034) / .10) * extension * (1 - .48 * descent)
    local tuck = ease((age - .05) / .16) * extension * (1 - .62 * descent)
    return {
        ["Right Leg"] = turn((14 * spring + 21 * tuck) * legScale, -3 * tuck),
        ["Left Leg"] = turn((-11 * spring - 13 * tuck) * legScale, 3 * tuck),
        ["Right Arm"] = turn(13 * spring + 8 * tuck, -5 * tuck),
        ["Left Arm"] = turn(8 * spring + 11 * tuck, 6 * tuck),
        Tail = turn(-13 * spring + 6 * tuck),
    }, extension
end

return table.freeze(Jump)
