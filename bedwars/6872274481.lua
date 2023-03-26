repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer.Character

--functions and locals

local lplr = game.Players.LocalPlayer
local cam = game.Workspace.CurrentCamera
local uis = game:GetService("UserInputService")
local hrp = lplr.Character.HumanoidRootPart
local hmd = lplr.Character.Humanoid

function runcode(func)
	pcall(function()
		func()
	end)
end
function Chat(msg)
	local args = { [1] = msg, [2] = "All" }
	game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"):FireServer(unpack(args))
end

--vape stuff lol
local KnitClient = debug.getupvalue(require(lplr.PlayerScripts.TS.knit).setup, 6)
local Client = require(game:GetService("ReplicatedStorage").TS.remotes).default.Client
local getremote = function(tab)
	for i,v in pairs(tab) do
		if v == "Client" then
			return tab[i + 1]
		end
	end
	return ""
end
local repstorage = game:GetService("ReplicatedStorage")
local KnockbackTable = debug.getupvalue(require(game:GetService("ReplicatedStorage").TS.damage["knockback-util"]).KnockbackUtil.calculateKnockbackVelocity, 1)
local cstore = require(lplr.PlayerScripts.TS.ui.store).ClientStore
local bedwars = { -- vape
	["SprintController"] = KnitClient.Controllers.SprintController,
	["CombatConstant"] = require(repstorage.TS.combat["combat-constant"]).CombatConstant,
	["SwordController"] = KnitClient.Controllers.SwordController,
	["ClientHandler"] = Client,
	["AppController"] = require(repstorage["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out.client.controllers["app-controller"]).AppController,
	["SwordRemote"] = getremote(debug.getconstants((KnitClient.Controllers.SwordController).attackEntity)),
}
function isalive(player)
	local character = player.Character
	if not character then
		-- the player does not have a character
		return false
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		-- the character does not have a humanoid object
		return false
	end

	return humanoid.Health > 0
end

local BedwarsSwords = require(game:GetService("ReplicatedStorage").TS.games.bedwars["bedwars-swords"]).BedwarsSwords
function hashFunc(instance) 
	return {value = instance}
end


local function GetInventory(plr)
	if not plr then
		return {inv = {}, armor = {}}
	end

	local success, result = pcall(function()
		return require(game:GetService("ReplicatedStorage").TS.inventory["inventory-util"]).InventoryUtil.getInventory(plr)
	end)

	if not success then
		return {items = {}, armor = {}}
	end

	if plr.Character and plr.Character:FindFirstChild("InventoryFolder") then
		local invFolder = plr.Character:FindFirstChild("InventoryFolder").Value
		if not invFolder then return result end

		for _, item in pairs(result) do
			for _, subItem in pairs(item) do
				if typeof(subItem) == "table" and subItem.itemType then
					subItem.instance = invFolder:FindFirstChild(subItem.itemType)
				end
			end

			if typeof(item) == "table" and item.itemType then
				item.instance = invFolder:FindFirstChild(item.itemType)
			end
		end
	end

	return result
end

-- omg 1 1 1 11!!
local function getSword()
	-- Initialize the highest power value and the returning item to nil.
	local highestPower = -9e9
	local returningItem = nil

	-- Get the inventory of the local player.
	local inventory = GetInventory(lplr)

	-- Loop through the items in the inventory.
	for _, item in pairs(inventory.items) do
		-- Check if the item is a sword.
		local power = table.find(BedwarsSwords, item.itemType)
		if not power then
			-- Skip the item if it is not a sword.
			continue
		end

		-- Check if the power of the current sword is higher than the current highest power.
		if power > highestPower then
			-- Set the returning item to the current sword and update the highest power value.
			returningItem = item
			highestPower = power
		end
	end

	-- Return the item with the highest power.
	return returningItem
end

local function getNearestPlayer(maxDist)
	-- define the position or object that you want to use as the reference point
	local referencePoint = game.Players.LocalPlayer.Character.HumanoidRootPart.Position

	-- get the list of players currently connected to the game
	local players = game:GetService("Players"):GetPlayers()

	-- initialize variables to store the nearest player and their distance
	local nearestPlayer = nil
	local nearestDistance = maxDist

	-- loop through all the players and find the nearest one
	for _, player in pairs(players) do

		if player ~= game.Players.LocalPlayer then
			-- calculate the distance between the reference point and the player
			local distance = (referencePoint - player.Character.PrimaryPart.Position).magnitude

			-- check if this player is closer than the current nearest player
			if distance < nearestDistance then
				-- update the nearest player and distance
				nearestPlayer = player
				nearestDistance = distance
			end

		end
	end
	if nearestPlayer then
		return nearestPlayer
	end
end


--rest of script ig

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Moon 3.0", "DarkTheme")

local Combat = Window:NewTab("Combat")
local Movement = Window:NewTab("Movement")
local Player = Window:NewTab("Player")
local Render = Window:NewTab("Render")
local Misc = Window:NewTab("Misc")

local RenderSection = Render:NewSection("Render")
local MiscSection = Misc:NewSection("Misc")

runcode(function()
	local KillAuraSection = Combat:NewSection("KillAura")
	local Distance = {["Value"] = 18}
	local AuraEnabled = false
	KillAuraSection:NewToggle("KillAura", "attacks players around you.", function(enabled)
		if enabled then
			AuraEnabled = true
			local anims = {
				Normal = {
					{CFrame = CFrame.new(1, -1, 2) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.2},
					{CFrame = CFrame.new(-1, 1, -2.2) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.2}
				},
			}
			local origC0 = cam.Viewmodel.RightHand.RightWrist.C0
			local ui2 = Instance.new("ScreenGui")
			local nearestID = nil
			ui2.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
			repeat
				if isalive(lplr) and lplr.Character:FindFirstChild("Humanoid").Health > 0.1 then
					for _,v in pairs(game.Players:GetPlayers()) do
						if v ~= lplr then
							nearestID = v
							target = v.Name
							if v.Team ~= lplr.Team and v ~= lplr and isalive(v) and v.Character:FindFirstChild("HumanoidRootPart") and (v.Character.HumanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).Magnitude < 20 then
								local sword = getSword()
								if sword ~= nil then
									function swing()
										spawn(function()
											pcall(function()
												for i,v in pairs(anims.Normal) do 
													anim = game:GetService("TweenService"):Create(cam.Viewmodel.RightHand.RightWrist, TweenInfo.new(v.Time), {C0 = origC0 * v.CFrame})
													anim:Play()
													task.wait(v.Time)
												end
											end)
										end)
									end
									coroutine.wrap(swing)()

									Client:Get(bedwars["SwordRemote"]):SendToServer({
										["weapon"] = sword.tool,
										["entityInstance"] = v.Character,																																																																																							
										["validate"] = {
											["raycast"] = {
												["cameraPosition"] = hashFunc(cam.CFrame.Position),
												["cursorDirection"] = hashFunc(Ray.new(cam.CFrame.Position, v.Character:FindFirstChild("HumanoidRootPart").Position).Unit.Direction)
											},
											["targetPosition"] = hashFunc(v.Character:FindFirstChild("HumanoidRootPart").Position),
											["selfPosition"] = hashFunc(lplr.Character:FindFirstChild("HumanoidRootPart").Position + ((lplr.Character:FindFirstChild("HumanoidRootPart").Position - v.Character:FindFirstChild("HumanoidRootPart").Position).magnitude > 14 and (CFrame.lookAt(lplr.Character:FindFirstChild("HumanoidRootPart").Position, v.Character:FindFirstChild("HumanoidRootPart").Position).LookVector * 4) or Vector3.new(0, 0, 0)))
										},
										["chargedAttack"] = {["chargeRatio"] = 1}
									})
								end
							end
						end
					end
				end
				task.wait(0.22);	
				bedwars["SwordController"].lastAttack = game:GetService("Workspace"):GetServerTimeNow() - 0.11
				local function redo()
					if cam.Viewmodel.RightHand.RightWrist.C0 ~= origC0 then
						pcall(function()
							anim:Cancel()
						end)
						anim2 = game:GetService("TweenService"):Create(cam.Viewmodel.RightHand.RightWrist, TweenInfo.new(0.364), {C0 = origC0})
						anim2:Play()
					end
				end
				coroutine.wrap(redo)()
			until not AuraEnabled
		else
			AuraEnabled = false
		end
	end)
end)

runcode(function()
	local VelocitySection = Combat:NewSection("Velocity")
	VelocitySection:NewToggle("Velocity", "Allows you to not take knockback", function(enabled)
		if enabled then
			KnockbackTable["kbDirectionStrength"] = 0
			KnockbackTable["kbUpwardStrength"] = 0
		else
			KnockbackTable["kbDirectionStrength"] = 100
			KnockbackTable["kbUpwardStrength"] = 100
		end
	end)
end)

runcode(function()
	local SprintSection = Combat:NewSection("Sprint")
	local isSprinting = false
	SprintSection:NewToggle("AutoSprint", "auto sprints for u", function(enabled)
		if enabled then
			isSprinting = true
			repeat wait()
				if (not bedwars["SprintController"].sprinting) then
					bedwars["SprintController"]:startSprinting()
				end
			until not isSprinting
		else
			isSprinting = false
		end
	end)
end)

runcode(function()
	local SpeedRepeat = false
	local SpeedSection = Movement:NewSection("Speed")
	local You = lplr.Name
	local speed1 = 0.06
	SpeedSection:NewToggle("Speed - Mode 1", "cframe mode 1!1!1", function(enabled)
		if enabled then
			SpeedRepeat = true
			repeat wait()
				if uis:IsKeyDown(Enum.KeyCode.W) then
					game:GetService("Workspace")[You].HumanoidRootPart.CFrame = game:GetService("Workspace")[You].HumanoidRootPart.CFrame * CFrame.new(0,0,-speed1)
				end;
				if uis:IsKeyDown(Enum.KeyCode.A) then
					game:GetService("Workspace")[You].HumanoidRootPart.CFrame = game:GetService("Workspace")[You].HumanoidRootPart.CFrame * CFrame.new(-speed1,0,0)
				end;
				if uis:IsKeyDown(Enum.KeyCode.S) then
					game:GetService("Workspace")[You].HumanoidRootPart.CFrame = game:GetService("Workspace")[You].HumanoidRootPart.CFrame * CFrame.new(0,0,speed1)
				end;
				if uis:IsKeyDown(Enum.KeyCode.D) then
					game:GetService("Workspace")[You].HumanoidRootPart.CFrame = game:GetService("Workspace")[You].HumanoidRootPart.CFrame * CFrame.new(speed1,0,0)
				end;
			until not SpeedRepeat
		else
			SpeedRepeat = false
		end
	end)
	SpeedSection:NewTextBox("SpeedAmount1", "recommended 0.06", function(speed2)
		speed1 = speed2
	end)

	local speed3 = 24
	local SpeedRepeat2 = false
	SpeedSection:NewToggle("Speed - Mode 2", "cframe mode 1!1!1", function(enabled)
		if enabled then
			SpeedRepeat2 = true
			repeat wait()
				lplr.Character.Humanoid.WalkSpeed = speed3
			until not SpeedRepeat2
		else
			SpeedRepeat2 = false
		end
	end)
	SpeedSection:NewTextBox("SpeedAmount2", "recommended 24", function(speed4)
		speed3 = speed4
	end)
end)

runcode(function()
	local LongjumpSection = Movement:NewSection("Longjump")
	LongjumpSection:NewToggle("Longjump - Toggle", "very long jump fr", function(enabled)
		if enabled then
			game.Workspace.Gravity = 1
			wait()
			lplr.Character.Humanoid:ChangeState(3)
		else
			game.Workspace.Gravity = 196.2
		end
	end)
	LongjumpSection:NewKeybind("Longjump - Bind", "very long jump fr", Enum.KeyCode.J, function()
		game.Workspace.Gravity = 1
		wait()
		lplr.Character.Humanoid:ChangeState(3)
		wait(2.3)
		game.Workspace.Gravity = 196.2
	end)	
end)

runcode(function()
	local HighjumpSection = Movement:NewSection("Highjump")
	HighjumpSection:NewToggle("Highjump - Toggle", "very high jump fr", function(enabled)
		if enabled then
			game.Workspace.Gravity = 1
			for i = 1, 9 do
				lplr.character.HumanoidRootPart.Velocity = lplr.character.HumanoidRootPart.Velocity + Vector3.new(0,50,0)
				task.wait()
			end
		else
			game.Workspace.Gravity = 196.2
		end
	end)
	HighjumpSection:NewKeybind("Highjump - Bind", "very high jump fr", Enum.KeyCode.H, function()
		game.Workspace.Gravity = 1
		for i = 1, 9 do
			lplr.character.HumanoidRootPart.Velocity = lplr.character.HumanoidRootPart.Velocity + Vector3.new(0,50,0)
			task.wait(0.1)
		end
		game.Workspace.Gravity = 196.2
	end)	
end)

runcode(function()
	local FlightSection = Movement:NewSection("Flight")
	FlightSection:NewToggle("Flight - Toggle", "coolio", function(enabled)
		if enabled then
			game.Workspace.Gravity = 0
		else
			game.Workspace.Gravity = 196.2
		end
	end)
	FlightSection:NewKeybind("Flight - Bind", "coolio", Enum.KeyCode.R, function()
		game.Workspace.Gravity = 0
		wait(2.3)
		game.Workspace.Gravity = 196.2
	end)	
end)

runcode(function()
	local nofallenabled = false
	local NoFallSection = Player:NewSection("NoFall")
	NoFallSection:NewToggle("NoFall", "allows for no fall damage", function(enabled)
		if enabled then
			nofallenabled = true
			repeat wait()
				game:GetService("ReplicatedStorage").rbxts_include.node_modules:FindFirstChild("@rbxts").net.out._NetManaged.GroundHit:FireServer()
			until not nofallenabled
		else
			nofallenabled = false
		end
	end)	
end)

runcode(function()
	local TeleportAmount1 = 15
	local AcBypassEnabled = false
	local AnticheatBypassSection = Player:NewSection("AnticheatBypass")
	AnticheatBypassSection:NewToggle("AnticheatBypass", "allows you to bypass the anticheat speed check", function(enabled)
		if enabled then
			local oldchar
			local clone
			oldchar = lplr.Character
			oldchar.Archivable = true
			clone = oldchar:Clone()
			oldchar.PrimaryPart.Anchored = false
			local humc = oldchar.Humanoid:Clone()
			humc.Parent = lplr.Character
			game:GetService("RunService").Stepped:connect(function()
				local mag = (clone.PrimaryPart.Position - oldchar.PrimaryPart.Position).Magnitude
				if mag >= 18 then
					oldchar:SetPrimaryPartCFrame(clone.PrimaryPart.CFrame)
				end
			end)
			cam.CameraSubject = clone.Humanoid 
			clone.Parent = workspace
			lplr.Character = clone
			for _,v in pairs(lplr.Character:GetChildren()) do
				v.Transparency = 0.5
			end
		else
			lplr.Character.Humanoid.Health = 0
		end
	end)
	AnticheatBypass:NewTextBox("TeleportAmount", "recommended 14", function(TeleportAmount2)
		TeleportAmount1 = TeleportAmount2
	end)
end)
