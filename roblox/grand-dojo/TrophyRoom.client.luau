local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local remote = ReplicatedStorage:WaitForChild("TrophyRoom")
local Catalog = require(ReplicatedStorage:WaitForChild("TrophyCatalog"))
local Art = require(ReplicatedStorage:WaitForChild("TrophyArt"))
local player = Players.LocalPlayer
local ink, brass, ivory = Color3.fromRGB(48,28,40),Color3.fromRGB(230,167,96),Color3.fromRGB(255,232,203)
local function make(class,parent,properties)
    local object=Instance.new(class)
    for name,value in properties do object[name]=value end
    object.Parent=parent
    return object
end
local function round(ui,radius)
    make("UICorner",ui,{CornerRadius=UDim.new(0,radius)})
end
local function button(parent,copy,size,fn)
    local b=make("TextButton",parent,{
        Name=copy,Text=copy,Size=size,BackgroundColor3=Color3.fromRGB(101,58,61),
        Font=Enum.Font.GothamBold,TextSize=14,TextColor3=ivory,TextWrapped=true,
    })
    round(b,8)
    b.Activated:Connect(fn)
    return b
end
local gui=make("ScreenGui",player:WaitForChild("PlayerGui"),{Name="TrophyRoom",ResetOnSpawn=false,DisplayOrder=33})
local rail=make("Frame",gui,{
    AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,5),Size=UDim2.fromOffset(220,44),
    BackgroundTransparency=1,Visible=false,
})
local collection=button(rail,"Displays",UDim2.fromOffset(108,44),function() remote:FireServer("open") end)
local exit=button(rail,"Return",UDim2.fromOffset(104,44),function() remote:FireServer("exit") end)
exit.Position=UDim2.fromOffset(116,0)
local floating=make("TextLabel",gui,{
    AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-16),Size=UDim2.new(.77,0,0,42),
    BackgroundColor3=ink,TextColor3=ivory,Font=Enum.Font.GothamBold,TextSize=14,TextWrapped=true,Visible=false,
})
round(floating,9)
local panel=make("Frame",gui,{
    AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.53),Size=UDim2.fromScale(.91,.88),
    BackgroundColor3=ink,Visible=false,
})
round(panel,12)
make("UISizeConstraint",panel,{MaxSize=Vector2.new(680,500)})
make("UIStroke",panel,{Color=brass,Thickness=1.5})
local title=make("TextLabel",panel,{
    Position=UDim2.fromOffset(12,0),Size=UDim2.new(1,-69,0,48),BackgroundTransparency=1,
    TextXAlignment=Enum.TextXAlignment.Left,TextColor3=ivory,Font=Enum.Font.GothamBold,TextSize=20,TextWrapped=true,
})
local close=button(panel,"×",UDim2.fromOffset(44,44),function() panel.Visible=false end)
close.Position=UDim2.new(1,-51,0,4)
local body=make("ScrollingFrame",panel,{
    Position=UDim2.fromOffset(12,50),Size=UDim2.new(1,-24,1,-61),BackgroundTransparency=1,
    BorderSizePixel=0,AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=5,
    CanvasSize=UDim2.fromOffset(0,0),
})
local state, slot, messageIndex
messageIndex=0
local function flash(message)
    messageIndex+=1
    local current=messageIndex
    floating.Text,floating.Visible=message,true
    task.delay(3,function() if current==messageIndex then floating.Visible=false end end)
end
local function render()
    body:ClearAllChildren()
    make("UIListLayout",body,{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,6)})
    local n=0
    local function row(text,run)
        n+=1
        local b=button(body,text,UDim2.new(1,-6,0,44),run)
        b.LayoutOrder=n
        return b
    end
    title.Text=if state.mine then "Your Trophy Room" else state.owner.."’s Trophy Room"
    if state.mine and slot then
        row("Back to displays",function() slot=nil;render() end)
        row("Clear this slot",function() remote:FireServer("set",slot,"") end)
        for _,id in state.earned do
            local b=row("     "..Catalog.byId[id].title,function() remote:FireServer("set",slot,id) end)
            b.TextXAlignment=Enum.TextXAlignment.Left
        end
    else
        row("Wall page "..state.page.." of 2"..(if state.mine then " · Switch page" else ""),function()
            if state.mine then remote:FireServer("page",3-state.page) end
        end)
        for i=1,12 do
            local index=if i<=6 then i else i+(state.page-1)*6
            local kind=(if i<=6 then "Featured " else "Wall ")..tostring(if i<=6 then i else i-6)
            local id=state.layout[tostring(index)]
            row(kind.." · "..(if id and Catalog.byId[id] then Catalog.byId[id].title else "Empty"),function()
                if state.mine then slot=index;render() end
            end)
        end
        for _,guest in state.guests do
            row("Invite "..guest.name,function() remote:FireServer("invite",guest.id) end)
        end
    end
    body.CanvasPosition=Vector2.zero
    if UserInputService.PreferredInput==Enum.PreferredInput.Gamepad then GuiService.SelectedObject=close end
end

local invite=make("Frame",gui,{
    AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.new(.82,0,0,112),
    BackgroundColor3=ink,Visible=false,
})
round(invite,12)
make("UISizeConstraint",invite,{MaxSize=Vector2.new(380,112)})
local inviteLabel=make("TextLabel",invite,{
    Size=UDim2.new(1,0,0,59),BackgroundTransparency=1,TextColor3=ivory,TextSize=15,
    Font=Enum.Font.GothamBold,TextWrapped=true,
})
local accept=button(invite,"Visit room",UDim2.new(.47,0,0,44),function()
    invite.Visible=false; remote:FireServer("accept")
end)
accept.Position=UDim2.new(.02,0,0,60)
local decline=button(invite,"Decline",UDim2.new(.47,0,0,44),function()
    invite.Visible=false; remote:FireServer("decline")
end)
decline.Position=UDim2.new(.51,0,0,60)

remote.OnClientEvent:Connect(function(action,data)
    if action=="entered" then
        panel.Visible=false
        rail.Visible=true
        flash(if data then "Your private collection" else "Visiting a Trophy Room")
    elseif action=="closed" then
        rail.Visible,panel.Visible,invite.Visible=false,false,false
        state,slot=nil,nil
    elseif action=="panel" then
        state=data
        render()
        panel.Visible=true
    elseif action=="notice" then
        flash(data)
    elseif action=="invite" then
        inviteLabel.Text=data.." invited you to their Trophy Room."
        invite.Visible=true
        if UserInputService.PreferredInput==Enum.PreferredInput.Gamepad then GuiService.SelectedObject=accept end
    end
end)
