local RunService = game:GetService("RunService")

local localChar = script:FindFirstAncestorWhichIsA("Model")
local ReticleService = require(script.Parent:WaitForChild("ReticleService"))

--- // MAIN
RunService.RenderStepped:Connect(ReticleService.UpdateReticle)
localChar.ChildAdded:Connect(ReticleService.UpdateWandState)
localChar.ChildRemoved:Connect(ReticleService.UpdateWandState)
