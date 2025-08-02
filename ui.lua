local CoreEvent = game.ReplicatedStorage:WaitForChild("CoreEvent")

for i,v in pairs(workspace:GetChildren()) do
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
	for i,v in pairs(workspace:GetChildren()) do
		if v:FindFirstChild("Owner") and v.Owner.Value == "None" then
			v.Owner.Value = plr.Name
			v.Sign.SignGUI.SignTextLabel.Text = plr.Name.."'s Base"
			break
		end
	end
	
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = plr
	local Steals = Instance.new("NumberValue")
	Steals.Name = "Steals"
	Steals.Value = 0
	Steals.Parent = leaderstats
	local Rebirths = Instance.new("NumberValue")
	Rebirths.Name = "Rebirths"
	Rebirths.Value = 0
	Rebirths.Parent = leaderstats
	local Cash = Instance.new("NumberValue")
	Cash.Name = "Cash"
	Cash.Value = 100
	Cash.Parent = leaderstats
	
	plr.CharacterAdded:Connect(function(Character)
		for i,v in pairs(workspace:GetChildren()) do
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
	
	for i,v in ipairs(NPCS) do
		TotalWeight += v.Chance
	end
	
	local RandomWeight = math.random() * TotalWeight
	local Current = 0
	
	for i,v in ipairs(NPCS) do
		Current += v.Chance
		if RandomWeight <= Current then
			return v.Model.Rig
		end
	end
end

local function NPCMove(NPC)
	for i = 1,#workspace.CheckPoints:GetChildren(),1 do
		local CheckPointNumber = 1
		
		NPC.Humanoid:MoveTo(workspace.CheckPoints["Checkpoint"..CheckPointNumber].Position)
		
		local AT = NPC.Humanoid.Animator:LoadAnimation(NPC.WalkAnimation)
		AT:Play()
		
		NPC.Humanoid.MoveToFinished:Connect(function()
			CheckPointNumber += 1
			
			if CheckPointNumber == #workspace.CheckPoints:GetChildren() then
				NPC:Destroy()
			else	
				NPC.Humanoid:MoveTo(workspace.CheckPoints["Checkpoint"..CheckPointNumber].Position)
			end
		end)
	end
end

local function SpawnNPC()
	local NPC = ChooseRandomNPC()
	local NPCModel = NPC:Clone()
	NPCModel.Parent = workspace
	local SpecificNPCFolder = NPCFolder[NPCModel.NPCName.Value]
	NPCModel.Head.InfoGUI.PriceTextLabel.Text = "$"..SpecificNPCFolder.Price.Value
	NPCModel.Head.InfoGUI.NameTextLabel.Text = SpecificNPCFolder.Name
	NPCModel.Head.InfoGUI.RarityTextLabel.Text = SpecificNPCFolder.Rarity.Value
	NPCModel.Head.InfoGUI.MoneyPerSecondTextLabel.Text = "$"..SpecificNPCFolder.MoneyPerSecond.Value.."/s"
	NPCModel.PivotTo(workspace.Spawner.CFrame)
	NPCMove(NPCModel)
end

while true do
	SpawnNPC()
	
	task.wait(1)
end
