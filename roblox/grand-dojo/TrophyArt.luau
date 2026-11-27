-- The same fitted, original sculptures are used by the journal and physical room.
local Catalog = require(script.Parent.TrophyCatalog)
local Art = {}
local brass, pale, cedar = Color3.fromRGB(217, 155, 68), Color3.fromRGB(255, 219, 142), Color3.fromRGB(74, 39, 49)
local colors = {
    Color3.fromRGB(221, 122, 71), Color3.fromRGB(67, 194, 170), Color3.fromRGB(239, 139, 65),
    Color3.fromRGB(108, 162, 229), Color3.fromRGB(164, 220, 245), Color3.fromRGB(215, 112, 186),
}

function Art.build(id)
    local trophy = Catalog.byId[id]
    if not trophy then return nil end
    local model = Instance.new("Model")
    model.Name = id
    local accent = colors[trophy.index]
    local function part(name, size, position, tint, shape, angles, material)
        local p = Instance.new("Part")
        p.Name, p.Size, p.Color, p.Shape = name, size, tint, shape or Enum.PartType.Block
        p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, false, false, false
        p.CastShadow = false
        p.Material = material or Enum.Material.SmoothPlastic
        p.CFrame = CFrame.new(position) * (angles or CFrame.identity)
        p.Parent = model
        return p
    end
    local B, C = Enum.PartType.Ball, Enum.PartType.Cylinder
    local v = Vector3.new
    local upright = CFrame.Angles(0,0,math.pi/2)
    local function orb(name, width, height, x, y, z, color, material)
        return part(name,v(width,height,width),v(x,y,z),color,B,nil,material)
    end
    local function bar(name,w,h,d,x,y,z,color,roll)
        return part(name,v(w,h,d),v(x,y,z),color,nil,roll and CFrame.Angles(0,0,roll))
    end
    local function link(a,b,width,color,name)
        return part(name,v(width,(b-a).Magnitude,width),(a+b)*.5,color,nil,
            CFrame.lookAt(Vector3.zero,(b-a).Unit)*CFrame.Angles(math.pi/2,0,0))
    end
    local base = part("Obsidian base",v(.23,2.20,2.20),v(0,.115,0),cedar,C,upright)
    model.PrimaryPart = base
    part("Gilded rim",v(.10,2.04,2.04),v(0,.28,0),brass,C,upright)
    bar("Enamel plaque",.68,.19,.08,0,.20,.99,accent)
    local g, n = trophy.group, trophy.index
    if id == "world-04" then
        for side=-1,1,2 do
            bar("Gate pillar",.19,1.99,.37,side*.88,1.37,0,brass)
            bar("Gate collar",.31,.14,.45,side*.88,.58,0,pale)
        end
        bar("Gate roof",2.17,.20,.51,0,2.33,0,accent)
        bar("Gilt crown",2.28,.11,.58,0,2.47,0,pale)
        bar("Silk cord",.07,.42,.07,0,2.07,0,brass)
        orb("Glazed lantern",.86,1.04,0,1.40,0,Color3.fromRGB(255,169,71),Enum.Material.Neon)
        for _,y in {1.07,1.40,1.73} do
            part("Filigree band",v(.045,.88,.88),v(0,y,0),pale,C,upright)
        end
    elseif g == 2 then
        part("Compass case",v(.25,1.65,1.65),v(0,1.37,0),brass,C,CFrame.Angles(0,math.pi/2,0))
        part("Compass enamel",v(.12,1.47,1.47),v(0,1.37,.13),accent,C,CFrame.Angles(0,math.pi/2,0))
        for i=0,3 do
            local a = i * math.pi/2 + n*.21
            bar("Compass point",.19,.53,.07,math.sin(a)*.29,1.37+math.cos(a)*.29,.22,pale,-a)
        end
        orb("Gem",.18,.18,0,1.38,.26,pale)
        for i=-1,1 do
            part("District seal",v(.13,.38,.38),v(i*.46,.59,.62),colors[(n+i+5)%6+1],C,
                CFrame.Angles(0,math.pi/2,0))
        end
    elseif g == 3 then
        for i=1,4 do
            local x = (i-2.5)*.40
            local h = .76 + ((i+n)%4)*.42
            local peak = Instance.new("WedgePart")
            peak.Name, peak.Size, peak.CFrame = "Summit", v(.58,h,.77), CFrame.new(x,.34+h/2,-i*.07)
                * CFrame.Angles(0,(i+n)*.42,0)
            peak.Color, peak.Material, peak.Anchored = accent, Enum.Material.Slate, true
            peak.CanCollide, peak.CanTouch, peak.CanQuery, peak.CastShadow = false,false,false,false
            peak.Parent = model
        end
        local old = v(.83,.53,0)
        for i=1,15 do
            local a=i*.38
            local nextPoint=v(math.cos(a)*.86,.53+i*.10,math.sin(a)*.58)
            link(old,nextPoint,.085,pale,"Wind ribbon")
            old=nextPoint
        end
        orb("Summit bell",.38,.46,0,2.0,.08,brass)
    elseif g == 4 then
        local xOffset = if n == 5 then .31 else .53
        for side=-1,1,2 do
            local x=side*xOffset
            bar("Glove cuff",.42,.34,.45,x,.95,0,brass,side*.30)
            orb("Padded glove",.71,.87,x,1.51+(if n%3==0 then side*.18 else 0),0,accent)
            orb("Thumb guard",.36,.49,x+side*.26,1.34,.17,accent)
        end
        if n>=3 then
            bar("Arena crest",.48,.47,.13,0,2.14,.04,pale,math.pi/4)
        end
        for i=-1,1,2 do
            bar("Ring corner",.12,.37,.13,i*.84,.51,.55,brass)
        end
        bar("Ring rope",1.65,.07,.07,0,.64,.55,accent)
    elseif g == 5 then
        local coreY=1.37
        orb("Elemental core",.85,if n==3 then 1.10 else .86,0,coreY,0,pale,Enum.Material.Neon)
        for j=0,(if n == 6 then 5 else 3) do
            local angle=j*math.pi/(if n==6 then 3 else 2)
            local old=v(math.cos(angle)*.89,.42,math.sin(angle)*.89)
            for k=1,6 do
                local nextPoint=v(math.cos(angle+k*.14)*(.90-k*.08),.42+k*(.18+n*.008),
                    math.sin(angle+k*.14)*(.90-k*.08))
                link(old,nextPoint,.19,accent,if n==2 then "Kraken arm" else "Elemental ribbon")
                old=nextPoint
            end
            orb("Crest gem",.19,.19,old.X,old.Y,old.Z,pale)
        end
    else
        if n==2 or n==5 then
            for i=1,(if n==5 then 4 else 2) do
                bar("Mentor tablet",.59,1.23,.16,(i-(if n==5 then 2.5 else 1.5))*.43,1.23,-i*.14,accent,-i*.1)
                bar("Tablet gold line",.31,.04,.07,(i-(if n==5 then 2.5 else 1.5))*.43,1.35,-i*.14+.10,pale)
            end
        else
            local h=if n==6 then 2.08 else 1.68
            bar("Journey standard",.13,h,.13,0,.33+h/2,0,brass)
            part("Carved insignia",v(.30,1.18,1.18),v(0,h,.13),accent,C,CFrame.Angles(0,math.pi/2,0))
            for i=1,n do
                local a=(i-1)*2*math.pi/n
                orb("Milestone gem",.16,.16,math.cos(a)*.38,h+math.sin(a)*.38,.30,pale)
            end
        end
    end
    return model
end

function Art.preview(frame,id)
    frame:ClearAllChildren()
    local model=Art.build(id)
    if not model then return end
    model.Parent=frame
    local camera=Instance.new("Camera")
    camera.CFrame=CFrame.lookAt(Vector3.new(3.5,2.7,5.9),Vector3.new(0,1.43,0))
    camera.FieldOfView=33
    camera.Parent=frame
    frame.CurrentCamera=camera
    frame.Ambient=Color3.fromRGB(157,138,147)
    frame.LightColor=Color3.fromRGB(255,221,160)
    frame.LightDirection=Vector3.new(-1,-1,-.5)
end

return Art
