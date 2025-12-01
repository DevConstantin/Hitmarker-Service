local HitmarkerModule = {}

-- // SERVICES
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

-- // OBJECTS
-- UI objects
local hitmarkerGui = script.Parent
local templatesFolder = hitmarkerGui.HitmarkerTemplates
local hitmarkerImageTemplate = templatesFolder.HitmarkerImage
local hitmarkerSoundTemplate = templatesFolder.HitmarkerSound
local hitmarkerContainer = hitmarkerGui.HitmarkersContainer -- Stores cloned hitmarker instances

local defaultColorCorrection = Lighting:WaitForChild("ColorCorrection")
local koColorCorrection = Lighting:WaitForChild("KO_ColorCorrection") -- Used for KO effect
local koBlur = Lighting:WaitForChild("KO_Blur")

-- // CONFIG
local USE_SOUND = true -- Should a sound play on hit?
local HITMARKER_COOLDOWN = 0.08 -- Minimum seconds between hitmarkers
local HITMARKER_VISIBLE_DURATION = 0.2 -- How long the hitmarker stays fully visible
local HITMARKER_FADE_DURATION = 0.37 -- How long it takes to fade out
local KO_BLUR_SIZE = 5
local KO_BLUR_T = 3 -- Also used for color correction duration
local CC_KO_COLOR = koColorCorrection.TintColor
local CC_BRIGHTNESS = koColorCorrection.Brightness
local CC_CONTRAST = koColorCorrection.Brightness
local CC_SATURATION = koColorCorrection.Brightness

local tweenInfo = TweenInfo.new(HITMARKER_FADE_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local koEffectTweenInfo = TweenInfo.new(KO_BLUR_T, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false)

local knockoutBlurTween = TweenService:Create(koBlur, koEffectTweenInfo, { Size = 0 })

-- // VARIABLES
local lastHitmarkerTime = 0
local currentCCTween, ccTweenCompletedConnect = nil

-- // FUNCTIONS

local function inCinematicMode()
	local cinematicModeStyle = Lighting:GetAttribute("CinematicModeStyle")
	return cinematicModeStyle == "Enabled" or cinematicModeStyle == "Black_Bars"
end

local function runKOEffect(applyKOEffect)
	if not applyKOEffect then
		return
	end
	--if koColorCorrection.Enabled then return end
	defaultColorCorrection.Enabled = false

	if ccTweenCompletedConnect then
		ccTweenCompletedConnect:Disconnect()
	end
	if currentCCTween then
		currentCCTween:Cancel()
	end

	-- Reset values, giving you that 'impact' pop-up effect
	koColorCorrection.TintColor = CC_KO_COLOR
	koColorCorrection.Brightness = CC_BRIGHTNESS
	koColorCorrection.Contrast = CC_CONTRAST
	koColorCorrection.Saturation = CC_SATURATION
	koColorCorrection.Enabled = true
	koBlur.Size = KO_BLUR_SIZE

	local ccTween = TweenService:Create(koColorCorrection, koEffectTweenInfo, {
		TintColor = defaultColorCorrection.TintColor,
		Brightness = defaultColorCorrection.Brightness,
		Contrast = defaultColorCorrection.Contrast,
		Saturation = defaultColorCorrection.Saturation,
	})

	currentCCTween = ccTween
	ccTween:Play()

	ccTweenCompletedConnect = ccTween.Completed:Connect(function()
		koColorCorrection.Enabled = false
		defaultColorCorrection.Enabled = true
	end)

	--task.delay(KO_BLUR_T, function()  end)
	if knockoutBlurTween.PlaybackState ~= Enum.PlaybackState.Playing then
		knockoutBlurTween:Play()
	end
end

-- Function to show the hitmarker
function HitmarkerModule.ShowHitmarker(applyKOEffect)
	if inCinematicMode() then
		return
	end

	-- Cooldown to prevent hitmarker spam (for abilities that do damage with a loop and such)
	if (os.clock() - lastHitmarkerTime) < HITMARKER_COOLDOWN then
		return
	end
	lastHitmarkerTime = os.clock()

	-- Clone image template, position it at cursor, & parent
	local newHitmarkerImage = hitmarkerImageTemplate:Clone()
	local mouseLocation = UserInputService:GetMouseLocation()

	if applyKOEffect then
		newHitmarkerImage.ImageColor3 = Color3.fromRGB(255, 16, 20)
	end
	newHitmarkerImage.Position = UDim2.new(0, mouseLocation.X, 0, mouseLocation.Y)
	newHitmarkerImage.Visible = true
	newHitmarkerImage.Parent = hitmarkerContainer

	-- Sound is optional
	if USE_SOUND then
		-- Create, parent, and play sound
		local newHitmarkerSound = hitmarkerSoundTemplate:Clone()
		newHitmarkerSound.Parent = newHitmarkerImage -- Parent to image for easy cleanup
		newHitmarkerSound:Play()
	end

	runKOEffect(applyKOEffect)

	local runServiceConnect = nil -- Used to attach hitmarker image to mouse position

	-- Animate & cleanup (fade out)
	task.delay(HITMARKER_VISIBLE_DURATION, function()
		if not newHitmarkerImage or not newHitmarkerImage.Parent then
			return
		end -- Check if already somehow destroyed

		local tween = TweenService:Create(
			newHitmarkerImage,
			tweenInfo,
			{ ImageTransparency = 1, Size = UDim2.new(0.07, 0, 0.135, 0) }
		)

		tween.Completed:Connect(function()
			if newHitmarkerImage and newHitmarkerImage.Parent then
				if runServiceConnect then
					runServiceConnect:Disconnect()
				end
				newHitmarkerImage:Destroy()
			end
		end)

		tween:Play()
	end)

	-- Attach hitmarker to mouse position
	runServiceConnect = RunService.Heartbeat:Connect(function()
		if newHitmarkerImage and newHitmarkerImage.Parent then
			print("Updating hitmarker position!")
			mouseLocation = UserInputService:GetMouseLocation()
			newHitmarkerImage.Position = UDim2.new(0, mouseLocation.X, 0, mouseLocation.Y)
		else
			runServiceConnect:Disconnect()
		end
	end)
end

if hitmarkerImageTemplate.Visible then
	hitmarkerImageTemplate.Visible = false
end
if not hitmarkerGui.Enabled then
	hitmarkerGui.Enabled = true
end

return HitmarkerModule
