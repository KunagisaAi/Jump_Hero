local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

local charging = false
local chargeStartTime = 0
local chargeValue = 0
local maxCharge = 2 -- 最大蓄力秒数
local minCharge = 0.2 -- 最小蓄力秒数
local chargeDecaySpeed = 0.7 -- 达到最大后每秒减少的蓄力量
local lastUpdate = 0
local chargeTimeout = false

-- 获取角色和 HumanoidRootPart
local function getCharacterParts()
	if not localPlayer.Character then return nil, nil end
	local hrp = localPlayer.Character:FindFirstChild("HumanoidRootPart")
	local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
	return humanoid, hrp
end

-- 判断角色是否在地面
local function isOnGround()
	local humanoid, _ = getCharacterParts()
	if humanoid then
		local state = humanoid:GetState()
		-- 只允许在这些状态下蓄力
		if state == Enum.HumanoidStateType.Running or
			state == Enum.HumanoidStateType.Landed or
			state == Enum.HumanoidStateType.Physics or
			state == Enum.HumanoidStateType.Seated then
			return true
		end
	end
	return false
end

-- 蓄力跳跃动作
local function doJump(power)
	local humanoid, hrp = getCharacterParts()
	if humanoid and hrp then
		-- 计算跳跃方向：角色朝向的XZ平面
		local look = hrp.CFrame.LookVector
		local jumpPower = 50 + 100 * power -- 跳跃高度（可调）
		local forwardPower = 30 + 120 * power -- 向前速度（可调）
		-- 先让角色进入跳跃状态
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		-- 设置速度
		hrp.Velocity = Vector3.new(look.X * forwardPower, jumpPower, look.Z * forwardPower)
	end
end

-- 蓄力过程每帧更新（不再更新蓄力条UI）
local function onRenderStep()
	if charging then
		local now = tick()
		if not chargeTimeout then
			chargeValue = now - chargeStartTime
			if chargeValue >= maxCharge then
				chargeValue = maxCharge
				chargeTimeout = true
				lastUpdate = now
			end
		else
			-- 达到最大后缓慢减少
			local dt = now - lastUpdate
			lastUpdate = now
			chargeValue = chargeValue - chargeDecaySpeed * dt
			if chargeValue <= 0 then
				chargeValue = 0
				charging = false
				chargeTimeout = false
				return
			end
		end
		-- 不再更新蓄力条UI
	end
end

-- 空格键按下/松开处理
local function handleJumpAction(actionName, inputState, inputObj)
	if inputState == Enum.UserInputState.Begin then
		if not charging and isOnGround() then
			charging = true
			chargeTimeout = false
			chargeStartTime = tick()
			lastUpdate = chargeStartTime
			chargeValue = 0
			RunService:BindToRenderStep("JumpCharge", Enum.RenderPriority.Input.Value, onRenderStep)
		end
	elseif inputState == Enum.UserInputState.End then
		if charging then
			RunService:UnbindFromRenderStep("JumpCharge")
			-- 只有松开空格且角色还在地面才能跳跃
			if isOnGround() and chargeValue >= minCharge and chargeValue > 0 and not (chargeTimeout and chargeValue <= 0) then
				-- 执行跳跃
				doJump(math.clamp(chargeValue, minCharge, maxCharge) / maxCharge)
			end
			charging = false
			chargeTimeout = false
			chargeValue = 0
		end
	end
	return Enum.ContextActionResult.Sink
end

-- 绑定空格键
ContextActionService:BindAction("CustomChargeJump", handleJumpAction, false, Enum.KeyCode.Space)

-- 角色重生时重置（不再重置蓄力条UI）
local function onCharacterAdded(character)
	charging = false
	chargeTimeout = false
	chargeValue = 0
end

if localPlayer then
	localPlayer.CharacterAdded:Connect(onCharacterAdded)
	if localPlayer.Character then
		onCharacterAdded(localPlayer.Character)
	end
end

