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

-- 蓄力条UI变量
local jumpUI
local chargeBar
local chargeBackground
local chargeBarImage

-- 获取蓄力条UI
local function getJumpUI()
	if not jumpUI then
		jumpUI = localPlayer.PlayerGui:WaitForChild("JumpUI", 10)
		if jumpUI then
			local chargeBarFrame = jumpUI:FindFirstChild("ChargeBarFrame")
			chargeBar = chargeBarFrame:FindFirstChild("ChargeBar")
			chargeBarImage = chargeBar:FindFirstChild("ImageLabel")
			chargeBackground = jumpUI:FindFirstChild("ChargeBackGroud")
		end
	end
	return jumpUI, chargeBarImage, chargeBackground
end

-- 显示或隐藏蓄力条
local function setChargeBarVisible(visible)
	local ui, bar, bg = getJumpUI()
	if ui then
		ui.Enabled = visible
	end
end

-- 更新蓄力条显示
local function updateChargeBar(value)
	local ui, bar, bg = getJumpUI()
	if bar then
		-- 计算蓄力比例 (0到1之间)
		local chargeRatio = math.clamp(value / maxCharge, 0, 1)
		-- 更新蓄力条的尺寸
		bar.Size = UDim2.new(chargeRatio, 0, 1, 0)
	end
end

-- 重置蓄力条
local function resetChargeBar()
	local ui, bar, bg = getJumpUI()
	if bar then
		bar.Size = UDim2.new(0, 0, 1, 0)
		setChargeBarVisible(false)
	end
end

-- 获取角色和 HumanoidRootPart
local function getCharacterParts()
	if not localPlayer.Character then return nil, nil end
	local hrp = localPlayer.Character:FindFirstChild("HumanoidRootPart")
	local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
	return humanoid, hrp
end

-- 禁用Humanoid的默认跳跃功能
local function disableDefaultJump()
	local humanoid, _ = getCharacterParts()
	if humanoid then
		-- 禁用Humanoid的默认跳跃行为
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
		-- 设置JumpPower为0，确保默认跳跃不会生效
		humanoid.JumpPower = 0
		-- 设置JumpHeight为0，进一步确保默认跳跃不会生效
		humanoid.JumpHeight = 0
		-- 禁用自动跳跃
		humanoid.AutoJumpEnabled = false
		print("默认跳跃功能已禁用")
	end
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

-- 蓄力过程每帧更新
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
				resetChargeBar()
				return
			end
		end
		-- 更新蓄力条UI
		updateChargeBar(chargeValue)
	end
end

-- 跳跃键按下/松开处理
local function handleJumpAction(actionName, inputState, inputObj)
	if inputState == Enum.UserInputState.Begin then
		if not charging and isOnGround() then
			charging = true
			chargeTimeout = false
			chargeStartTime = tick()
			lastUpdate = chargeStartTime
			chargeValue = 0
			-- 显示蓄力条
			setChargeBarVisible(true)
			updateChargeBar(0)
			RunService:BindToRenderStep("JumpCharge", Enum.RenderPriority.Input.Value, onRenderStep)
		end
	elseif inputState == Enum.UserInputState.End then
		if charging then
			RunService:UnbindFromRenderStep("JumpCharge")
			-- 只有松开跳跃键且角色还在地面才能跳跃
			if isOnGround() and chargeValue >= minCharge and chargeValue > 0 and not (chargeTimeout and chargeValue <= 0) then
				-- 执行跳跃
				doJump(math.clamp(chargeValue, minCharge, maxCharge) / maxCharge)
			end
			charging = false
			chargeTimeout = false
			chargeValue = 0
			-- 重置蓄力条
			resetChargeBar()
		end
	end
	return Enum.ContextActionResult.Sink
end

-- 绑定跳跃键输入设备
ContextActionService:BindAction("CustomChargeJump", handleJumpAction, true, Enum.PlayerActions.CharacterJump)

-- 配置触摸按钮的大小和位置
 --ContextActionService:SetPosition("CustomChargeJump", UDim2.new(0.2, 0, 0.2, 0))
 --ContextActionService:SetSize("CustomChargeJump", UDim2.new(0.2, 0, 0.2, 0))

-- 角色重生时重置
local function onCharacterAdded(character)
	charging = false
	chargeTimeout = false
	chargeValue = 0
	resetChargeBar()
	-- 禁用默认跳跃功能
	disableDefaultJump()
end

-- 初始化UI
local function initializeUI()
	-- 等待PlayerGui加载
	if localPlayer:FindFirstChild("PlayerGui") then
		getJumpUI()
		resetChargeBar()
	else
		localPlayer:WaitForChild("PlayerGui"):WaitForChild("JumpUI", 10)
		getJumpUI()
		resetChargeBar()
	end
	-- 禁用默认跳跃功能
	disableDefaultJump()
end

if localPlayer then
	localPlayer.CharacterAdded:Connect(onCharacterAdded)
	if localPlayer.Character then
		onCharacterAdded(localPlayer.Character)
	end

	-- 初始化UI
	initializeUI()
end