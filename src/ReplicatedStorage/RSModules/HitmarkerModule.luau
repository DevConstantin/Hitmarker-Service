-- Used by the server to send hitmarkers to client

local hitmarkerModule = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local hitmarkerEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("HitmarkerEvent")

-- @param applyKOEffect: Set to true to apply an additional KO effect if the player managed to KO a target
function hitmarkerModule.sendHitmarker(player, applyKOEffect : boolean)
	hitmarkerEvent:FireClient(player, applyKOEffect)
end

return hitmarkerModule
