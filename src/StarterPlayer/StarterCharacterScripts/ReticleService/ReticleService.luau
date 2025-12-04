local ReticleService = {}

--- // SERVICES
local Debis = game:GetService("Debris")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

--- // OBJECTS
local currentCamera = Workspace.CurrentCamera
local localPlayer = Players.LocalPlayer
local localChar = script:FindFirstAncestorWhichIsA("Model")
local mouse = localPlayer:GetMouse()

--- // CONFIG
local MAX_DISTANCE = 1000
local RETICLE_ID_WHITE = "rbxassetid://98327244362788"
local RETICLE_ID_RED = "rbxassetid://87385051712919"
local USE_DEBUG = false

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude -- Or Blacklist
raycastParams.FilterDescendantsInstances = { localChar } --, workspace.Zones, workspace.InvisibleParts, workspace.SeasonSystemParts.SnowRegionNodes, workspace.SeasonSystemParts.LesserTerrainRegionNodes, workspace.WhompingWillowHitboxes, localPlayer.Character, workspace.Pianos, workspace.Rings, workspace.PvP_Region, workspace.WerewolfBlockRegions}

local hasWand: boolean = false

--- // FUNCTIONS
local function resetReticle()
	if mouse.Icon ~= "" then -- Reset mouse icon to default
		mouse.Icon = ""
	end
end

-- Update reticle state. Used by RunService in main script
function ReticleService.UpdateReticle(dt)
	if not hasWand then
		resetReticle()
		return
	end

	local target, hitPos = ReticleService.GetMouseHitWithFilters()

	if USE_DEBUG and hitPos then
		local hitMarker = Instance.new("Part")
		hitMarker.Size = Vector3.new(0.5, 0.5, 0.5)
		hitMarker.Color = Color3.fromRGB(255, 0, 0)
		hitMarker.Anchored = true
		hitMarker.CanCollide = false
		hitMarker.Position = hitPos
		hitMarker.Parent = workspace
		Debis:AddItem(hitMarker, dt or 0.1)
	end

	local char = target and target:FindFirstAncestorWhichIsA("Model")
	if char and ReticleService.CanSpellHit(char) then
		mouse.Icon = RETICLE_ID_RED -- "rbxassetid://140686867601037"
	else
		mouse.Icon = RETICLE_ID_WHITE -- "rbxassetid://132287726719230"
	end
end

function ReticleService.UpdateWandState()
	local wand = localChar:FindFirstChild("Wand")
	if not wand then
		hasWand = false
		return
	end

	if wand and wand:FindFirstChild("WandTip") then -- Wand detected, and it has the wand tip
		hasWand = true
		return
	-- Wand (likely an accessory) detected, but it's missing a wand tip. Check if the player has a proper wand
	-- This should hypothetically never execute because the game deletes wand accessories upon joining
	else
		for _, wand in ipairs(localChar:GetChildren()) do
			if wand.Name == "Wand" and wand:FindFirstChild("WandTip") then
				hasWand = true
				break
			end
		end
	end

	hasWand = false
end

--- Validation methods

function ReticleService.GetMouseHitWithFilters(): (Instance?, Vector3)
	local guiInset = GuiService:GetGuiInset()
	local mouseLocation = UserInputService:GetMouseLocation()
	local unitRay = currentCamera:ScreenPointToRay(mouseLocation.X, mouseLocation.Y - guiInset.Y)
	local result = Workspace:Raycast(unitRay.Origin, unitRay.Direction * MAX_DISTANCE, raycastParams)

	if result then
		return result.Instance, result.Position
	else
		return nil, unitRay.Origin + unitRay.Direction * MAX_DISTANCE
	end
end

-- Check if the target character can be hit
function ReticleService.CanSpellHit(char: Model) : boolean
	local hum = char:FindFirstChild("Humanoid")
	if not hum or hum.Health <= 0 then
		return false
	end

	local playerHit = Players:GetPlayerFromCharacter(char)
	if playerHit then
		-- Ensure that only players who are dueling / not dueling can hit one another
		if localPlayer:GetAttribute("IsDuelling") ~= playerHit:GetAttribute("IsDuelling") then
			return false
		end
	end

	local hasForceField = char:FindFirstChildWhichIsA("ForceField")
	if hasForceField then
		return false
	end

	return true
end

return ReticleService