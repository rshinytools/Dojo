local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local remote = ReplicatedStorage:WaitForChild("TrophyRoom")
local Catalog = require(ReplicatedStorage:WaitForChild("TrophyCatalog"))
local Art = require(ReplicatedStorage:WaitForChild("TrophyArt"))
local player = Players.LocalPlayer
local ink = Color3.fromRGB(35,23,33)
local lacquer = Color3.fromRGB(78,35,44)
local brass = Color3.fromRGB(228,176,104)
local ivory = Color3.fromRGB(255,240,214)
local muted = Color3.fromRGB(218,190,166)
local teal = Color3.fromRGB(34,89,83)
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
        Name=copy,Text=copy,Size=size,BackgroundColor3=lacquer,BorderSizePixel=0,Selectable=true,
        Font=Enum.Font.GothamBold,TextSize=14,TextColor3=ivory,TextWrapped=true,
    })
    round(b,8)
    local line=make("UIStroke",b,{Color=brass,Transparency=.62,ApplyStrokeMode=Enum.ApplyStrokeMode.Border})
    b.SelectionGained:Connect(function() line.Transparency=0;line.Thickness=2 end)
    b.SelectionLost:Connect(function() line.Transparency=.62;line.Thickness=1 end)
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
    AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.545),Size=UDim2.fromScale(.93,.85),
    BackgroundColor3=ink,Visible=false,
})
round(panel,14)
make("UISizeConstraint",panel,{MaxSize=Vector2.new(740,530)})
make("UIStroke",panel,{Color=brass,Thickness=1.5})
local header=make("Frame",panel,{Name="Header",Size=UDim2.new(1,0,0,58),BackgroundColor3=lacquer,BorderSizePixel=0})
round(header,14)
make("UIGradient",header,{Color=ColorSequence.new(Color3.fromRGB(255,228,205),Color3.fromRGB(162,145,164))})
local function label(parent,name,copy,size,tint,font)
    return make("TextLabel",parent,{
        Name=name,Text=copy,TextColor3=tint,TextSize=size,Font=font or Enum.Font.GothamMedium,
        TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,BackgroundTransparency=1,
    })
end
local title=label(header,"RoomTitle","",23,ivory,Enum.Font.Fondamento)
title.Position,title.Size=UDim2.fromOffset(14,3),UDim2.new(1,-74,0,31)
local subtitle=label(header,"RoomMode","",12,ivory,Enum.Font.GothamBold)
subtitle.Position,subtitle.Size=UDim2.fromOffset(15,34),UDim2.new(1,-74,0,18)
local body=make("ScrollingFrame",panel,{
    Name="DisplayContent",Position=UDim2.fromOffset(14,115),Size=UDim2.new(1,-28,1,-129),
    BackgroundTransparency=1,BorderSizePixel=0,AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=5,
    ScrollBarImageColor3=brass,CanvasSize=UDim2.fromOffset(0,0),ScrollingDirection=Enum.ScrollingDirection.Y,
})
local state, selectedSlot, candidate
local section="Featured"
local messageIndex=0
local function flash(message)
    messageIndex+=1
    local current=messageIndex
    floating.Text,floating.Visible=message,true
    task.delay(3,function() if current==messageIndex then floating.Visible=false end end)
end

local function hidePanel()
    panel.Visible=false
    body:ClearAllChildren()
    selectedSlot,candidate=nil,nil
    if UserInputService.GamepadEnabled then GuiService.SelectedObject=collection end
end
local close=button(header,"×",UDim2.fromOffset(44,44),hidePanel)
close.Position=UDim2.new(1,-52,0,7)

local actions=make("Frame",panel,{
    Name="DisplayActions",Position=UDim2.fromOffset(14,64),Size=UDim2.new(1,-28,0,44),BackgroundTransparency=1,
})
make("UIListLayout",actions,{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,6),
    SortOrder=Enum.SortOrder.LayoutOrder})
local function slotName(index)
    if index<=6 then return "Pedestal "..index end
    return "Wall "..((index-7)%6+1)
end

local render
render=function(preserveScroll)
    local previousScroll=body.CanvasPosition
    local previousSelection=GuiService.SelectedObject
    local restoreName=previousSelection and previousSelection:IsDescendantOf(panel) and previousSelection.Name
    local sequence={}
    for _,child in actions:GetChildren() do
        if child:IsA("GuiObject") then child:Destroy() end
    end
    body:ClearAllChildren()
    make("UIPadding",body,{PaddingTop=UDim.new(0,2),PaddingLeft=UDim.new(0,2),
        PaddingRight=UDim.new(0,8),PaddingBottom=UDim.new(0,3)})
    make("UIListLayout",body,{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,7)})
    local order=0
    local function add(object)
        order+=1
        object.LayoutOrder=order
        return object
    end
    local function register(control,name)
        control.Name=name
        table.insert(sequence,control)
        return control
    end
    local function row(name,copy,onClick,primary,tall)
        local control=register(add(button(body,copy,UDim2.new(1,0,0,if tall then 52 else 44),onClick)),name)
        if primary then control.BackgroundColor3=teal end
        return control
    end
    local function caption(name,copy)
        local text=add(label(body,name,copy,14,muted))
        text.Size=UDim2.new(1,0,0,0)
        text.AutomaticSize=Enum.AutomaticSize.Y
    end
    local function tab(name,copy,active,fn)
        local b=register(button(actions,copy,UDim2.new(1/(if state.mine then 3 else 2),-4,1,0),fn),name)
        b.LayoutOrder=#sequence
        if active then b.BackgroundColor3=teal end
        return b
    end
    local function showSection(value)
        section,selectedSlot,candidate=value,nil,nil
        render()
    end

    title.Text=if state.mine then "Your Trophy Room" else state.owner.."’s Trophy Room"
    subtitle.Text=if state.mine then "Manage displays" else "Guest view"
    if selectedSlot then
        local current=state.layout[tostring(selectedSlot)]
        local id=if state.mine then candidate or current else current
        local trophy=id and Catalog.byId[id]
        local back=register(button(actions,"Back to displays",UDim2.fromOffset(148,44),function()
            selectedSlot,candidate=nil,nil
            render()
        end),"BackToDisplays")
        back.BackgroundColor3=teal

        if trophy then
            local card=add(make("Frame",body,{
                Name="TrophyDetailCard",Size=UDim2.new(1,0,0,184),
                BackgroundColor3=Color3.fromRGB(52,31,45),BorderSizePixel=0,
            }))
            round(card,10)
            make("UIStroke",card,{Color=brass,Transparency=.48})
            local viewport=make("ViewportFrame",card,{
                Name="TrophyPreview",Size=UDim2.new(.43,-9,1,-16),Position=UDim2.fromOffset(8,8),
                BackgroundColor3=Color3.fromRGB(47,35,58),BorderSizePixel=0,
            })
            Art.preview(viewport,id)
            round(viewport,8)
            local function fitPreview()
                local size=viewport.AbsoluteSize
                if size.Y<=0 or not viewport.CurrentCamera then return end
                local widthRatio=math.clamp(size.X/size.Y,.45,1)
                viewport.CurrentCamera.FieldOfView=math.deg(2*math.atan(math.tan(math.rad(33)/2)/widthRatio))
            end
            viewport:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitPreview)
            fitPreview()
            local category=label(card,"TrophyCategory",Catalog.categories[trophy.group][1],12,brass,Enum.Font.GothamBold)
            category.Position,category.Size=UDim2.new(.43,9,0,10),UDim2.new(.57,-18,0,23)
            local name=label(card,"TrophyName",trophy.title,20,ivory,Enum.Font.Fondamento)
            name.Position,name.Size=UDim2.new(.43,9,0,35),UDim2.new(.57,-18,0,51)
            local details=label(card,"HowToEarn",trophy.criterion,13,muted)
            details.Position,details.Size=UDim2.new(.43,9,0,90),UDim2.new(.57,-18,1,-101)
            details.TextYAlignment=Enum.TextYAlignment.Top
        end

        if state.mine then
            caption("SlotInstructions",slotName(selectedSlot).." · Choose an earned trophy")
            if candidate and candidate~=current then
                row("PlaceTrophy","Place "..Catalog.byId[candidate].title,function()
                    remote:FireServer("set",selectedSlot,candidate)
                end,true)
            end
            if #state.earned==0 then caption("NoEarnedTrophies","Earn a trophy to place it here.") end
            for _,earnedId in state.earned do
                local name=Catalog.byId[earnedId].title
                row("Choose_"..earnedId,name..(if earnedId==current then " · On display" else ""),function()
                    candidate=earnedId
                    render()
                end,earnedId==candidate)
            end
            if current then
                row("ClearDisplay","Clear "..slotName(selectedSlot),function()
                    candidate=nil
                    remote:FireServer("set",selectedSlot,"")
                end)
            end
        end
    else
        tab("FeaturedTab","Pedestals",section=="Featured",function() showSection("Featured") end)
        tab("WallTab","Wall shelves",section=="Wall",function() showSection("Wall") end)
        if state.mine then
            tab("GuestsTab","Invite guests",section=="Guests",function()
                showSection("Guests")
                remote:FireServer("open")
            end)
        end
        if section=="Guests" then
            caption("InviteHelp","Invite a player from this server. Invitations last 60 seconds.")
            if #state.guests==0 then caption("NoGuests","No eligible guests in this server right now.") end
            for _,guest in state.guests do
                row("Invite_"..guest.id,"Invite "..guest.name,function() remote:FireServer("invite",guest.id) end)
            end
        else
            if section=="Wall" then
                local pageText="Wall page "..state.page.." of 2"
                if state.mine then
                    row("SwitchWallPage",pageText.." · Switch page",function()
                        remote:FireServer("page",3-state.page)
                    end)
                else
                    caption("ActiveWallPage",pageText)
                end
            end
            local first=if section=="Featured" then 1 else 7+(state.page-1)*6
            local visible=0
            for index=first,first+5 do
                local id=state.layout[tostring(index)]
                local trophy=id and Catalog.byId[id]
                if state.mine or trophy then
                    visible+=1
                    local name=if trophy then trophy.title else "Empty"
                    row("Display_"..index,slotName(index).."  ·  "..name,function()
                        selectedSlot,candidate=index,nil
                        render()
                    end,false,true)
                end
            end
            if visible==0 then caption("EmptySection","No trophies on display here yet.") end
        end
    end

    local top=sequence[1]
    local tabCount=if selectedSlot then 1 elseif state.mine then 3 else 2
    close.NextSelectionDown=top
    for index,control in sequence do
        if index<=tabCount then
            control.NextSelectionUp=close
            control.NextSelectionDown=sequence[tabCount+1]
            if index>1 then control.NextSelectionLeft=sequence[index-1] end
            if index<tabCount then control.NextSelectionRight=sequence[index+1] end
        else
            control.NextSelectionUp=if index==tabCount+1 then top else sequence[index-1]
            control.NextSelectionDown=sequence[index+1]
        end
    end
    body.CanvasPosition=if preserveScroll then previousScroll else Vector2.zero
    if previousSelection or UserInputService.GamepadEnabled then
        local restored=if restoreName then panel:FindFirstChild(restoreName,true) else nil
        if restored and restored:IsA("GuiButton") then
            GuiService.SelectedObject=restored
        else
            GuiService.SelectedObject=top or close
        end
    end
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
        hidePanel()
        rail.Visible=true
        if UserInputService.GamepadEnabled then GuiService.SelectedObject=collection end
        flash(if data then "Your private collection" else "Visiting a Trophy Room")
    elseif action=="closed" then
        hidePanel()
        rail.Visible,invite.Visible=false,false
        state,section=nil,"Featured"
        if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(gui) then
            GuiService.SelectedObject=nil
        end
    elseif action=="panel" or action=="refresh" then
        if action=="refresh" and not panel.Visible then return end
        state=data
        if not state.mine and selectedSlot then
            local visible=selectedSlot<=6 or math.floor((selectedSlot-7)/6)+1==state.page
            if not visible or not state.layout[tostring(selectedSlot)] then selectedSlot=nil end
        end
        panel.Visible=true
        render(action=="refresh")
    elseif action=="notice" then
        flash(data)
    elseif action=="invite" then
        inviteLabel.Text=data.." invited you to their Trophy Room."
        invite.Visible=true
        if UserInputService.PreferredInput==Enum.PreferredInput.Gamepad then GuiService.SelectedObject=accept end
    end
end)
