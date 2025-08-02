-- YoxanXHub Pet Spawner UI
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()

local Window = OrionLib:MakeWindow({
    Name = "YoxanXHub Pet Spawner",
    HidePremium = false,
    IntroEnabled = false,
    SaveConfig = false,
    ConfigFolder = "YoxanXHub_PetSpawner"
})

local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local spawnerEnabled = false

MainTab:AddToggle({
    Name = "Spawner",
    Default = false,
    Callback = function(Value)
        spawnerEnabled = Value
    end
})

-- === Script Asli ===
local CoreEvent = game.ReplicatedStorage:WaitForChild("CoreEvent")

for i, v in pairs(workspace:GetChildren()) do
    if v:FindFirstChild("Owner") then
        local Base = v

        Base.LockBase.Touched:Connect(function(Hit)
            if Hit.Parent.Name == Base.Owner.Value and Base.LockBase.IsLocked.Value == false then
                Base.LockBase.IsLocked.Value = true
                CoreEvent:FireAllClients("LockBase", Base)

                task.delay(60, function()
                    Base.LockBase.IsLocked.Value = false
                end)
            end
        end)
    end
end

game.Players.PlayerAdded:Connect(function(plr)
    for i, v in pairs(workspace:GetChildren()) do
        if v:FindFirstChild("Owner") and v.Owner.Value == "None" then
            v.Owner.Value = plr.Name
            v.Sign.SignGUI.SignTextLabel.Text = plr.Name .. "'s Base"
            break
        end
    end

    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = plr

    local Steals = Instance.new("NumberValue", leaderstats)
    Steals.Name = "Steals"
    Steals.Value = 0

    local Rebirths = Instance.new("NumberValue", leaderstats)
    Rebirths.Name = "Rebirths"
    Rebirths.Value = 0

    local Cash = Instance.new("NumberValue", leaderstats)
    Cash.Name = "Cash"
    Cash.Value = 100

    plr.CharacterAdded:Connect(function(Character)
        for i, v in pairs(workspace:GetChildren()) do
            if v:FindFirstChild("Owner") and v.Owner.Value == plr.Name then
                Character:PivotTo(v.Spawner.CFrame)
            end
        end
    end)
end)

local NPCFolder = game.ServerStorage:WaitForChild("NPCFolder")

local NPCS = {
    {Model = NPCFolder:WaitForChild("Noob"), Chance = 90},
    {Model = NPCFolder:WaitForChild("Bacon Hair"), Chance = 40},
    {Model = NPCFolder:WaitForChild("Check It Face"), Chance = 35},
    {Model = NPCFolder:WaitForChild("Oakley"), Chance = 30},
    {Model = NPCFolder:WaitForChild("Mr Riches"), Chance = 25}
}

local function ChooseRandomNPC()
    local TotalWeight = 0
    for _, v in ipairs(NPCS) do
        TotalWeight += v.Chance
    end
    local RandomWeight = math.random() * TotalWeight
    local Current = 0
    for _, v in ipairs(NPCS) do
        Current += v.Chance
        if RandomWeight <= Current then
            return v.Model.Rig
        end
    end
end

local function NPCMove(NPC)
    local CheckPoints = workspace:WaitForChild("CheckPoints")
    local CheckPointNumber = 1

    NPC.Humanoid:MoveTo(CheckPoints["Checkpoint" .. CheckPointNumber].Position)

    local AT = NPC.Humanoid.Animator:LoadAnimation(NPC.WalkAnimation)
    AT:Play()

    NPC.Humanoid.MoveToFinished:Connect(function()
        CheckPointNumber += 1
        if CheckPointNumber > #CheckPoints:GetChildren() then
            NPC:Destroy()
        else
            NPC.Humanoid:MoveTo(CheckPoints["Checkpoint" .. CheckPointNumber].Position)
        end
    end)
end

local function SpawnNPC()
    local NPC = ChooseRandomNPC()
    if not NPC then return end
    local NPCModel = NPC:Clone()
    NPCModel.Parent = workspace

    local Specific = NPCFolder[NPCModel.NPCName.Value]
    NPCModel.Head.InfoGUI.PriceTextLabel.Text = "$" .. Specific.Price.Value
    NPCModel.Head.InfoGUI.NameTextLabel.Text = Specific.Name
    NPCModel.Head.InfoGUI.RarityTextLabel.Text = Specific.Rarity.Value
    NPCModel.Head.InfoGUI.MoneyPerSecondTextLabel.Text = "$" .. Specific.MoneyPerSecond.Value .. "/s"

    NPCModel:PivotTo(workspace.Spawner.CFrame)
    NPCMove(NPCModel)
end

task.spawn(function()
    while true do
        if spawnerEnabled then
            SpawnNPC()
        end
        task.wait(1)
    end
end)

OrionLib:Init()
