-- Set DevMode attribute to false outside of testing

-- 	~REQUIRED OBJECTS~
-- ReplicatedStorage.RemoteEvents.HitmarkerEvent
-- StarterGui: HitmarkerGui

-- ~Example usage in a server script~
--local ReplicatedStorage = game:GetService("ReplicatedStorage")
--local hitmarkerEvent = ReplicatedStorage.HitmarkerEvent
--local targetPlayer = -- defined elsewhere
--hitmarkerEvent:FireClient(targetPlayer)

-- ~Example usage on the client~ - I'm not sure when you might use it on the client, but the option is there
--local Players = game:GetService("Players")
--local localPlayer = Players.LocalPlayer
--local HitmarkerModule = require(localPlayer:WaitForChild("PlayerGui"):WaitForChild("HitmarkerGui"):WaitForChild("HitmarkerModule"))
--HitmarkerModule.ShowHitmarker()

-- // SERVICES
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // OBJECTS
local HitmarkerClientModule = require(script.Parent.HitmarkerClientModule)
local hitmarkerEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("HitmarkerEvent")

-- Example client usage. Show hitmarker on left mouse click
if script:GetAttribute("DevMode") then
	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			print("Showing hitmarker via mouse click.")
			HitmarkerClientModule.ShowHitmarker()
		end
	end)
end

-- Show hitmarker from server
hitmarkerEvent.OnClientEvent:Connect(HitmarkerClientModule.ShowHitmarker)
