local Players = game:GetService("Players")
local Run = game:GetService("RunService")
local Http = game:GetService("HttpService")
local Tween = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local player = Players.LocalPlayer
local character = player.Character
local root = character.HumanoidRootPart
local humanoid = character:FindFirstChildOfClass("Humanoid")
local ring = workspace["Grand Dojo City"]["Fighting Ring"]
local corner = ring["Bot Spar Corner"]
local prompt = corner["Sparring Gate"].SparPrompt
local remote = game.ReplicatedStorage.GrandDojoSparring
local nativeHud = player.PlayerGui.GrandDojo
local resultPanel = nativeHud.SparringResult
local clock = function() return workspace:GetServerTimeNow() end
local camera = workspace.CurrentCamera
local clip, state, observed = {status="running", actions={}}, {}, {}
local qaKey = "FestivalChampionshipProof"
local displayReed, displayJuniper = 100, 90
local poses, deathAt, latestWindup, lastSignal
local eventConnection, cameraConnection
local xpBefore = tonumber(player:GetAttribute("FighterXp")) or 0
local function status()
    player:SetAttribute(qaKey,Http:JSONEncode(clip))
end
local function note(name)
    table.insert(clip.actions, { name=name, health=state.p, opponent=state.b,
        at=math.round((clock()-(state.starts or clock()))*100)/100 })
    observed[name] = true
end
local function effect(color, count)
    local scenePoint = Vector3.new(35.1,8.22,3.80)
    local anchor = CFrame.lookAt(scenePoint, scenePoint + Vector3.xAxis)
    for index=1,count do
        local theta = math.pi*2*(index-.28)/count
        local center = anchor:PointToWorldSpace(Vector3.new(math.cos(theta)*.42,math.sin(theta)*.42,0))
        local tip = anchor:PointToWorldSpace(Vector3.new(math.cos(theta)*.97,math.sin(theta)*.97,0))
        local spark = Instance.new("Part")
        spark.Name = "Festival contact accent"
        spark.Size = Vector3.new(.042,.068,.34)
        spark.CFrame = CFrame.lookAt(center,tip)
        spark.Color = color
        spark.Material = Enum.Material.Neon
        spark.Anchored = true
        spark.CanCollide = false
        spark.CanQuery = false
        spark.CanTouch = false
        spark.CastShadow = false
        spark.Transparency = .30
        spark.Parent = workspace
        Tween:Create(spark,TweenInfo.new(.18),{
            CFrame=CFrame.lookAt(tip,tip+(tip-center)),Transparency=1
        }):Play()
        Debris:AddItem(spark,.24)
    end
end
local function hitBeat(kind)
    if not poses then return end
    if kind == "blocked" or kind == "parried" then
        poses.play(kind)
        festivalHud.cue(kind,if kind=="parried" then "JUNIPER IS OPEN" else "NO DAMAGE")
        effect(if kind=="parried" then Color3.fromRGB(83,242,222) else Color3.fromRGB(185,216,219),5)
    elseif kind == "hit" then
        poses.play("hurt")
        festivalHud.cue("strike")
        effect(Color3.fromRGB(255,191,118),5)
    end
end
status()
task.spawn(function()
    eventConnection=remote.OnClientEvent:Connect(function(kind,a,b,starts,ends,phase,feedback,at)
        if kind=="begin" or kind=="state" then
            local lastPhase, lastP, lastB = state.phase,state.p,state.b
            state={p=a,b=b,starts=starts,ends=ends,phase=phase,feedback=feedback,at=at}
            if poses and phase=="windup" and latestWindup~=at then
                latestWindup=at
                poses.play("botWindup", at-clock()-.90)
            end
            local damage = (feedback == "hit" and a~=lastP)
                or ((feedback == "strike" or feedback == "counter") and b~=lastB)
            local defense = (feedback == "blocked" or feedback == "parried") and phase=="recovery"
                and (lastPhase~="recovery" or lastSignal~=feedback)
            if damage or defense then
                note(feedback)
                if feedback=="hit" or feedback=="blocked" or feedback=="parried" then
                    hitBeat(feedback)
                    displayReed=a
                    festivalHud.health(displayReed,displayJuniper)
                end
                if feedback=="strike" or feedback=="counter" then
                    task.delay(.21,function()
                        if not poses or clip.result then return end
                        displayJuniper=b
                        festivalHud.health(displayReed,displayJuniper)
                        festivalHud.cue(feedback,if feedback=="counter" then "RECOVERY PUNISHED" else nil)
                        effect(Color3.fromRGB(255,192,100),if feedback=="counter" then 7 else 4)
                    end)
                end
            end
            lastSignal=feedback
        elseif kind=="result" then
            clip.result=a
            clip.wins=b
            deathAt=clock()
            if a=="win" then
                poses.play("ko")
                resultPanel.Visible=false
                task.delay(.24,function()
                    if poses then
                        festivalHud.health(displayReed,0)
                        festivalHud.cue("ko")
                        effect(Color3.fromRGB(255,208,117),8)
                    end
                end)
            end
            note("result "..a)
        elseif kind=="reward" then
            clip.reward=a
            note("reward")
        end
    end)
    local ok,errorText=xpcall(function()
        assert((root.Position-prompt.Parent.Position).Magnitude<=prompt.MaxActivationDistance,"Walk to the spar prompt first.")
        task.wait(1.1)
        prompt:InputHoldBegin()
        task.wait(prompt.HoldDuration+.28)
        prompt:InputHoldEnd()
        local timeout=os.clock()+5
        repeat task.wait(.04) until state.starts or os.clock()>timeout
        assert(state.starts,"Native prompt did not start")
        local bot=corner:WaitForChild("Juniper Tortoise",3)
        assert(bot)
        local target=Vector3.new(34.05,6.30,3.97)
        humanoid:MoveTo(target)
        poses=stageFestivalPoses()
        poses.start()
        festivalHud.show()
        festivalHud.health(100,90)
        festivalHud.clock(55)
        festivalHud.cue("ready")
        local age=0
        cameraConnection=Run.RenderStepped:Connect(function(dt)
            age+=dt
            local factor=math.clamp(age/2.9,0,1)
            local koEase=deathAt and math.clamp((clock()-deathAt)*1.7,0,1) or 0
            local center=Vector3.new(34.90,8.54,3.80)
            local offset=Vector3.new(11.9+1.6*(1-factor)+koEase*1.6,2.52+koEase*.40,3.2-.8*factor)
            camera.CameraType=Enum.CameraType.Scriptable
            camera.FieldOfView=49
            camera.CFrame=CFrame.lookAt(center+offset,center)
            camera.Focus=CFrame.new(center)
            if deathAt and clock()-deathAt<1.36 then resultPanel.Visible=false end
        end)

        local attacked, heldAt, counteredAt, committedFight = false
        while not clip.result and clock()<state.ends+2 do
            local now=clock()
            local opponent=corner:FindFirstChild("Juniper Tortoise")
            if now>=state.starts and opponent then
                if not committedFight then
                    committedFight=true
                    festivalHud.cue("fight")
                    note("fight")
                end
                festivalHud.clock(math.max(0,math.ceil(state.ends-now)))
                local delta=opponent:GetPivot().Position-root.Position
                local flat=Vector3.new(delta.X,0,delta.Z)
                local range=flat.Magnitude>.05 and flat.Magnitude<=6.15 and root.CFrame.LookVector:Dot(flat.Unit)>.37
                if not attacked and range and state.phase~="recovery" then
                    attacked=true
                    poses.play("strike")
                    remote:FireServer("strike")
                end
                if state.phase=="windup" and observed.hit then
                    local untilHit=state.at-now
                    local lead=if observed.blocked then .20 else .53
                    if heldAt~=state.at and untilHit<=lead and untilHit>.055 and range then
                        heldAt=state.at
                        poses.play("guard")
                        remote:FireServer("guard")
                    end
                elseif state.phase=="recovery" and counteredAt~=state.at and range then
                    local from=state.at-(if state.feedback=="parried" then 1.35 else .95)
                    if now-from>.30 and state.at-now>.16 then
                        counteredAt=state.at
                        poses.play("counter")
                        remote:FireServer("strike")
                    end
                end
            end
            Run.Heartbeat:Wait()
        end
        assert(clip.result=="win","Expected full practice victory, got "..tostring(clip.result))
        task.wait(1.55)
        festivalHud.hide()
        resultPanel.Visible=true
        assert(clip.reward==60 and player:GetAttribute("FighterXp")==xpBefore+60,"Native XP mismatch")
        assert(observed.strike and observed.hit and observed.blocked and observed.parried and observed.counter,"Missing native event")
        assert(displayReed==82 and corner:FindFirstChild("Juniper Tortoise")==nil,"Health or cleanup mismatch")
        clip.nativeXp=player:GetAttribute("FighterXp")
        clip.reedHealth=displayReed
        clip.nativeRecap=resultPanel.Visible
        task.wait(2.25)
    end,debug.traceback)
    if eventConnection then eventConnection:Disconnect() end
    if cameraConnection then cameraConnection:Disconnect() end
    festivalHud.hide()
    if poses then poses.destroy() end
    clip.status=if ok then "passed" else "failed"
    clip.error=if ok then nil else tostring(errorText)
    status()
end)
return player:GetAttribute(qaKey)
