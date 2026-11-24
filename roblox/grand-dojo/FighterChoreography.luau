-- Builds authored Motor6D offsets for rigid fighter shells. Art pivots and
-- contact surfaces use floor coordinates with -Z forward and +X to the right.
local Choreography = {}

local looped = {stance = true, advance = true, retreat = true}
local reflectedJoint = {
    ["Right Shoulder"] = "Left Shoulder", ["Left Shoulder"] = "Right Shoulder",
    ["Right Hip"] = "Left Hip", ["Left Hip"] = "Right Hip",
}

local function rotation(pitch, yaw, roll)
    return CFrame.Angles(math.rad(pitch), math.rad(yaw or 0), math.rad(roll or 0))
end

local function around(pivot, key)
    local shift = Vector3.new(key[4] or 0, key[5] or 0, key[6] or 0)
    return CFrame.new(pivot + shift) * rotation(key[1], key[2], key[3]) * CFrame.new(-pivot)
end

local function lowest(frame, points)
    local height = math.huge
    for _, point in points do
        height = math.min(height, frame:PointToWorldSpace(point).Y)
    end
    return height
end

local function moveVertically(root, offset, delta)
    return CFrame.new(root:VectorToObjectSpace(Vector3.new(0, delta, 0))) * offset
end

local function reflect(frame)
    local x, y, z, xx, xy, xz, yx, yy, yz, zx, zy, zz = frame:GetComponents()
    return CFrame.new(-x, y, z, xx, -xy, -xz, -yx, yy, yz, -zx, zy, zz)
end

local function reflectedFrames(frames)
    local result = {frames[1]}
    -- Keep the asymmetric ready stance at both ends of a mirrored action.
    for index = 2, #frames - 1 do
        local time, authored = table.unpack(frames[index])
        local offsets = {}
        for name, offset in authored do
            offsets[reflectedJoint[name] or name] = reflect(offset)
        end
        result[index] = {time, offsets}
    end
    result[#frames] = frames[#frames]
    return result
end

function Choreography.new(rootHeight, pivots, rightSole, leftSole)
    local rootOrigin = Vector3.new(0, rootHeight, 0)
    local relativePivots = {}
    for name, position in pivots do
        relativePivots[name] = position - rootOrigin
    end
    local feet = {["Right Hip"] = {}, ["Left Hip"] = {}}
    for index, point in rightSole do
        feet["Right Hip"][index] = point - rootOrigin
    end
    for index, point in leftSole do
        feet["Left Hip"][index] = point - rootOrigin
    end

    local function foot(root, name, key)
        local offset = around(relativePivots[name], key)
        if key[7] == nil then
            return offset
        end
        -- A seventh key component sets the sole height above the rest floor.
        local delta = key[7] - rootHeight - lowest(root * offset, feet[name])
        return moveVertically(root, offset, delta)
    end

    local function pose(core, right, left, rightLeg, leftLeg, head, tail)
        local root = CFrame.new(core[1], core[2], core[3]) * rotation(core[4], core[5], core[6])
        local offsets = {
            RootJoint = root,
            Neck = around(relativePivots.Neck, head),
            ["Right Shoulder"] = around(relativePivots["Right Shoulder"], right),
            ["Left Shoulder"] = around(relativePivots["Left Shoulder"], left),
            ["Right Hip"] = foot(root, "Right Hip", rightLeg),
            ["Left Hip"] = foot(root, "Left Hip", leftLeg),
        }
        if tail and relativePivots.TailJoint then
            offsets.TailJoint = around(relativePivots.TailJoint, tail)
        end
        return offsets
    end

    local function finish(clips, contacts, latches, skills, travel, mirrored)
        local durations, leftClips, impact, soleHeights = {}, {}, {}, {}
        for _, name in mirrored do
            leftClips[name] = reflectedFrames(clips[name])
        end
        local function rememberSoles(frames)
            for _, key in frames do
                local authored = key[2]
                if not soleHeights[authored] then
                    local heights = {}
                    for joint, points in feet do
                        heights[joint] = lowest(authored.RootJoint * authored[joint], points)
                    end
                    soleHeights[authored] = heights
                end
            end
        end
        for name, frames in clips do
            durations[name] = frames[#frames][1]
            rememberSoles(frames)
        end
        for _, frames in leftClips do
            rememberSoles(frames)
        end
        -- Read the exact authored surface at a contact key. A fixed Vector3
        -- also works for radial moves that have no single limb to latch to.
        for action, surfaces in latches do
            local points = {}
            for index, surface in surfaces do
                if typeof(surface) == "Vector3" then
                    points[index] = surface
                else
                    local contactPose, joint, position = table.unpack(surface)
                    points[index] = (contactPose.RootJoint * contactPose[joint]):PointToWorldSpace(position - rootOrigin)
                end
            end
            impact[action] = table.freeze(points)
        end

        local poses = {
            Duration = table.freeze(durations), Contact = table.freeze(contacts), Impact = table.freeze(impact),
            Skill = table.freeze(skills), Travel = table.freeze(travel),
        }

        function poses.impact(action, index, direction)
            local point = impact[action][index]
            if direction == -1 and leftClips[action] then
                return Vector3.new(-point.X, point.Y, point.Z)
            end
            return point
        end

        function poses.sample(action, age, direction)
            action = clips[action] and action or "stance"
            local frames = (direction == -1 and leftClips[action]) or clips[action]
            age = math.max(age or 0, 0)
            if looped[action] then
                age %= durations[action]
            end
            local before, after = frames[#frames], frames[#frames]
            local weight = 0
            for index = 2, #frames do
                if age <= frames[index][1] then
                    before, after = frames[index - 1], frames[index]
                    local phase = (age - before[1]) / (after[1] - before[1])
                    weight = phase * phase * (3 - 2 * phase)
                    break
                end
            end
            local root = before[2].RootJoint:Lerp(after[2].RootJoint, weight)
            local result = {RootJoint = root}
            for name, previous in before[2] do
                if name == "RootJoint" then
                    continue
                end
                local offset = previous:Lerp(after[2][name], weight)
                local points = feet[name]
                if points then
                    local startY, endY = soleHeights[before[2]][name], soleHeights[after[2]][name]
                    local targetY = startY + (endY - startY) * weight
                    offset = moveVertically(root, offset, targetY - lowest(root * offset, points))
                end
                result[name] = offset
            end
            return result
        end

        return table.freeze(poses)
    end

    return {pose = pose, finish = finish}
end

return table.freeze(Choreography)
