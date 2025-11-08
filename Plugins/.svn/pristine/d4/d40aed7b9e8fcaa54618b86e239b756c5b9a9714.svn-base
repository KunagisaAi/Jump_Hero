--!strict
local plugin: Plugin = plugin
local studioService: StudioService = game:GetService("StudioService")
local runService: RunService = game:GetService("RunService")
local selection: Selection = game:GetService("Selection")
local studio: Studio = settings().Studio

type UVAnimationEditorGui = {
	dockWidgetGui: DockWidgetPluginGui,
	animationNameTitleText: TextLabel,
	animationNameValueText: TextBox,
	selectTextureTipText: TextLabel,
	createUVAnimationButton: TextButton,
	uvAnimationEditorFrame: Frame,
	uSpeedTitleText: TextLabel,
	uSpeedValueText: TextBox,
	vSpeedTitleText: TextLabel,
	vSpeedValueText: TextBox,
	uvAnimationTestButton: TextButton,
	resetUVOffsetButton: TextButton,
}

type SpriteAnimationEditorGui = {
	dockWidgetGui: DockWidgetPluginGui,
	selectTextureTipText: TextLabel,
	animationNameTitleText: TextLabel,
	animationNameValueText: TextBox,
	createSpriteAnimationButton: TextButton,
	spriteAnimationEditorFrame: Frame,
	frameRateTitleText: TextLabel,
	frameRateValueText: TextBox,
	frameCountTitleText: TextLabel,
	frameCountValueText: TextBox,
	imageColumnCountTitleText: TextLabel,
	imageColumnCountValueText: TextBox,
	spriteAnimationTestButton: TextButton,
	resetUVOffsetButton: TextButton,
}

type RotateAnimationEditorGui = {
	dockWidgetGui: DockWidgetPluginGui,
	selectPVInstanceTipText: TextLabel,
	animationNameTitleText: TextLabel,
	animationNameValueText: TextBox,
	createRotateAnimationButton: TextButton,
	rotateAnimationEditorFrame: Frame,
	xSpeedTitleText: TextLabel,
	xSpeedValueText: TextBox,
	ySpeedTitleText: TextLabel,
	ySpeedValueText: TextBox,
	zSpeedTitleText: TextLabel,
	zSpeedValueText: TextBox,
	rotateAnimationTestButton: TextButton,
	resetRotationButton: TextButton,
}

local WidgetInfo: DockWidgetPluginGuiInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, true, false, 400, 600, 200, 300)

local textColor: Color3
local buttonColor: Color3
local buttonBorderColor: Color3
local inputFieldColor: Color3
local inputFieldBorderColor: Color3

local uvAnimationTesting: boolean = false
local uvAnimationEditorGui: UVAnimationEditorGui
local spriteAnimationTesting: boolean = false
local spriteAnimationTime: number = 0
local spriteAnimationEditorGui: SpriteAnimationEditorGui
local rotateAnimationTesting: boolean = false
local rotateAnimationEditorGui: RotateAnimationEditorGui

local function UpdateCurrentThemeColors()
	local currentTheme: StudioTheme = studio.Theme :: StudioTheme
	textColor = currentTheme:GetColor(Enum.StudioStyleGuideColor.MainText, Enum.StudioStyleGuideModifier.Default)
	buttonColor = currentTheme:GetColor(Enum.StudioStyleGuideColor.Button, Enum.StudioStyleGuideModifier.Default)
	buttonBorderColor = currentTheme:GetColor(Enum.StudioStyleGuideColor.ButtonBorder, Enum.StudioStyleGuideModifier.Default)
	inputFieldColor = currentTheme:GetColor(Enum.StudioStyleGuideColor.InputFieldBackground, Enum.StudioStyleGuideModifier.Default)
	inputFieldBorderColor = currentTheme:GetColor(Enum.StudioStyleGuideColor.InputFieldBorder, Enum.StudioStyleGuideModifier.Default)
end

local function UpdateGuiTheme(gui: GuiBase2d)
	for descendantIndex: number, descendant: Instance in gui:GetDescendants() do
		if descendant:IsA("TextLabel") then
			descendant.TextColor3 = textColor
		elseif descendant:IsA("TextBox") then
			descendant.BackgroundColor3 = inputFieldColor
			descendant.BorderColor3 = inputFieldBorderColor
			descendant.TextColor3 = textColor
		elseif descendant:IsA("TextButton") then
			descendant.BackgroundColor3 = buttonColor
			descendant.BorderColor3 = buttonBorderColor
			descendant.TextColor3 = textColor
		end
	end
end

local function OnCreateUVAnimationButtonActivated(inputObject: InputObject, clickCount: number)
	local selectedInstances: {Instance} = selection:Get()
	if #selectedInstances ~= 1 then
		return
	end
	local selectedTexture: Instance = selectedInstances[1]
	if not selectedTexture:IsA("Texture") then
		return
	end
	if uvAnimationEditorGui == nil then
		return
	end
	local animationValuesName: string = uvAnimationEditorGui.animationNameValueText.Text .. "Values"
	local uvAnimationValues: Folder = selectedTexture:FindFirstChild(animationValuesName) :: Folder
	if uvAnimationValues ~= nil then
		return
	end
	uvAnimationValues = Instance.new("Folder")
	uvAnimationValues.Name = animationValuesName
	uvAnimationValues.Parent = selectedTexture
	local uSpeedValue: NumberValue = Instance.new("NumberValue")
	uSpeedValue.Name = "USpeed"
	uSpeedValue.Parent = uvAnimationValues
	local vSpeedValue: NumberValue = Instance.new("NumberValue")
	vSpeedValue.Name = "VSpeed"
	vSpeedValue.Parent = uvAnimationValues
end

local function OnUVAnimationUSpeedValueFocusLost(enterPressed: boolean, inputThatCausedFocusLoss: InputObject)
	local selectedInstances: {Instance} = selection:Get()
	if #selectedInstances ~= 1 then
		return
	end
	local selectedTexture: Instance = selectedInstances[1]
	if not selectedTexture:IsA("Texture") then
		return
	end
	if uvAnimationEditorGui == nil then
		return
	end
	local animationValuesName: string = uvAnimationEditorGui.animationNameValueText.Text .. "Values"
	local uvAnimationValues: Folder = selectedTexture:FindFirstChild(animationValuesName) :: Folder
	if uvAnimationValues == nil then
		return
	end
	local uSpeedValue: NumberValue = uvAnimationValues:FindFirstChild("USpeed") :: NumberValue
	if uSpeedValue == nil then
		return
	end
	local uSpeed: number? = tonumber(uvAnimationEditorGui.uSpeedValueText.Text)
	if uSpeed == nil then
		uSpeedValue.Value = 0
		uvAnimationEditorGui.uSpeedValueText.Text = "0"
	else
		uSpeedValue.Value = uSpeed
	end
end

local function OnUVAnimationVSpeedValueFocusLost(enterPressed: boolean, inputThatCausedFocusLoss: InputObject)
	local selectedInstances: {Instance} = selection:Get()
	if #selectedInstances ~= 1 then
		return
	end
	local selectedTexture: Instance = selectedInstances[1]
	if not selectedTexture:IsA("Texture") then
		return
	end
	if uvAnimationEditorGui == nil then
		return
	end
	local animationValuesName: string = uvAnimationEditorGui.animationNameValueText.Text .. "Values"
	local uvAnimationValues: Folder = selectedTexture:FindFirstChild(animationValuesName) :: Folder
	if uvAnimationValues == nil then
		return
	end
	local vSpeedValue: NumberValue = uvAnimationValues:FindFirstChild("VSpeed") :: NumberValue
	if vSpeedValue == nil then
		return
	end
	local vSpeed: number? = tonumber(uvAnimationEditorGui.vSpeedValueText.Text)
	if vSpeed == nil then
		vSpeedValue.Value = 0
		uvAnimationEditorGui.vSpeedValueText.Text = "0"
	else
		vSpeedValue.Value = vSpeed
	end
end

local function StartUVAnimationTest()
	uvAnimationTesting = true
	uvAnimationEditorGui.uvAnimationTestButton.Text = "停止测试"
end

local function StopUVAnimationTest()
	uvAnimationTesting = false
	uvAnimationEditorGui.uvAnimationTestButton.Text = "开始测试"
end

local function OnUVAnimationTestButtonActivated(inputObject: InputObject, clickCount: number)
	if uvAnimationTesting then
		StopUVAnimationTest()
	else
		StartUVAnimationTest()
	end
end

local function OnResetUVOffsetButtonActivated(inputObject: InputObject, clickCount: number)
	local selectedInstances: {Instance} = selection:Get()
	if #selectedInstances ~= 1 then
		return
	end
	local selectedTexture: Instance = selectedInstances[1]
	if not selectedTexture:IsA("Texture") then
		return
	end
	selectedTexture.OffsetStudsU = 0
	selectedTexture.OffsetStudsV = 0
end

local function OnUVAnimationButtonClick()
	if uvAnimationEditorGui ~= nil then
		uvAnimationEditorGui.dockWidgetGui.Enabled = true
		return
	end
	local dockWidgetGui: DockWidgetPluginGui = plugin:CreateDockWidgetPluginGui("UVAnimationEditor", WidgetInfo)
	dockWidgetGui.Title = "UV动画编辑器"
	
	--选择Texture提示文字
	local selectTextureTipText: TextLabel = Instance.new("TextLabel")
	selectTextureTipText.BackgroundTransparency = 1
	selectTextureTipText.Position = UDim2.new(0, 0, 0, 20)
	selectTextureTipText.Size = UDim2.new(1, 0, 0, 20)
	selectTextureTipText.TextSize = 14
	selectTextureTipText.Text = "请选择一个Texture"
	selectTextureTipText.Parent = dockWidgetGui
	
	--动画名字
	local animationNameTitleText: TextLabel = Instance.new("TextLabel")
	animationNameTitleText.BackgroundTransparency = 1
	animationNameTitleText.Position = UDim2.new(0, 10, 0, 20)
	animationNameTitleText.Size = UDim2.new(0.5, -20, 0, 20)
	animationNameTitleText.TextSize = 14
	animationNameTitleText.Text = "动画名字"
	animationNameTitleText.TextXAlignment = Enum.TextXAlignment.Left
	animationNameTitleText.Parent = dockWidgetGui
	local animationNameValueText: TextBox = Instance.new("TextBox")
	animationNameValueText.Position = UDim2.new(0.5, 10, 0, 20)
	animationNameValueText.Size = UDim2.new(0.5, -20, 0, 20)
	animationNameValueText.TextSize = 14
	animationNameValueText.Text = "UVAnimation"
	animationNameValueText.TextXAlignment = Enum.TextXAlignment.Left
	animationNameValueText.Parent = dockWidgetGui
	animationNameValueText.ClearTextOnFocus = false
	
	--创建UV动画按钮
	local createUVAnimationButton: TextButton = Instance.new("TextButton")
	createUVAnimationButton.Position = UDim2.new(0, 10, 0, 50)
	createUVAnimationButton.Size = UDim2.new(1, -20, 0, 20)
	createUVAnimationButton.TextSize = 14
	createUVAnimationButton.Text = "创建UV动画"
	createUVAnimationButton.Parent = dockWidgetGui
	createUVAnimationButton.Activated:Connect(OnCreateUVAnimationButtonActivated)
	
	--UV动画编辑
	local uvAnimationEditorFrame: Frame = Instance.new("Frame")
	uvAnimationEditorFrame.BackgroundTransparency = 1
	uvAnimationEditorFrame.Size = UDim2.new(1, 0, 1, 0)
	uvAnimationEditorFrame.Parent = dockWidgetGui
	--u速度
	local uSpeedTitleText: TextLabel = Instance.new("TextLabel")
	uSpeedTitleText.BackgroundTransparency = 1
	uSpeedTitleText.Position = UDim2.new(0, 10, 0, 50)
	uSpeedTitleText.Size = UDim2.new(0.5, -20, 0, 20)
	uSpeedTitleText.TextSize = 14
	uSpeedTitleText.Text = "U速度"
	uSpeedTitleText.TextXAlignment = Enum.TextXAlignment.Left
	uSpeedTitleText.Parent = uvAnimationEditorFrame
	local uSpeedValueText: TextBox = Instance.new("TextBox")
	uSpeedValueText.Position = UDim2.new(0.5, 10, 0, 50)
	uSpeedValueText.Size = UDim2.new(0.5, -20, 0, 20)
	uSpeedValueText.TextSize = 14
	uSpeedValueText.Text = "0"
	uSpeedValueText.TextXAlignment = Enum.TextXAlignment.Left
	uSpeedValueText.Parent = uvAnimationEditorFrame
	uSpeedValueText.ClearTextOnFocus = false
	uSpeedValueText.FocusLost:Connect(OnUVAnimationUSpeedValueFocusLost)
	--v速度
	local vSpeedTitleText: TextLabel = Instance.new("TextLabel")
	vSpeedTitleText.BackgroundTransparency = 1
	vSpeedTitleText.Position = UDim2.new(0, 10, 0, 80)
	vSpeedTitleText.Size = UDim2.new(0.5, -20, 0, 20)
	vSpeedTitleText.TextSize = 14
	vSpeedTitleText.Text = "V速度"
	vSpeedTitleText.TextXAlignment = Enum.TextXAlignment.Left
	vSpeedTitleText.Parent = uvAnimationEditorFrame
	local vSpeedValueText: TextBox = Instance.new("TextBox")
	vSpeedValueText.Position = UDim2.new(0.5, 10, 0, 80)
	vSpeedValueText.Size = UDim2.new(0.5, -20, 0, 20)
	vSpeedValueText.TextSize = 14
	vSpeedValueText.Text = "0"
	vSpeedValueText.TextXAlignment = Enum.TextXAlignment.Left
	vSpeedValueText.Parent = uvAnimationEditorFrame
	vSpeedValueText.ClearTextOnFocus = false
	vSpeedValueText.FocusLost:Connect(OnUVAnimationVSpeedValueFocusLost)
	--UV动画测试按钮
	local uvAnimationTestButton: TextButton = Instance.new("TextButton")
	uvAnimationTestButton.Position = UDim2.new(0, 10, 0, 110)
	uvAnimationTestButton.Size = UDim2.new(1, -20, 0, 20)
	uvAnimationTestButton.TextSize = 14
	uvAnimationTestButton.Text = "开始测试"
	uvAnimationTestButton.Parent = uvAnimationEditorFrame
	uvAnimationTestButton.Activated:Connect(OnUVAnimationTestButtonActivated)
	--重置UV偏移按钮
	local resetUVOffsetButton: TextButton = Instance.new("TextButton")
	resetUVOffsetButton.Position = UDim2.new(0, 10, 0, 140)
	resetUVOffsetButton.Size = UDim2.new(1, -20, 0, 20)
	resetUVOffsetButton.TextSize = 14
	resetUVOffsetButton.Text = "重置UV偏移"
	resetUVOffsetButton.Parent = uvAnimationEditorFrame
	resetUVOffsetButton.Activated:Connect(OnResetUVOffsetButtonActivated)

	uvAnimationEditorGui = {
		dockWidgetGui = dockWidgetGui,
		animationNameTitleText = animationNameTitleText,
		animationNameValueText = animationNameValueText,
		selectTextureTipText = selectTextureTipText,
		createUVAnimationButton = createUVAnimationButton,
		uvAnimationEditorFrame = uvAnimationEditorFrame,
		uSpeedTitleText = uSpeedTitleText,
		uSpeedValueText = uSpeedValueText,
		vSpeedTitleText = vSpeedTitleText,
		vSpeedValueText = vSpeedValueText,
		uvAnimationTestButton = uvAnimationTestButton,
		resetUVOffsetButton = resetUVOffsetButton,
	}
	UpdateGuiTheme(dockWidgetGui)
end

local function UpdateUVAnimationEditor(deltaTime: number)
	if uvAnimationEditorGui == nil or not uvAnimationEditorGui.dockWidgetGui.Enabled then
		return
	end
	local selectedInstances: {Instance} = selection:Get()
	if #selectedInstances ~= 1 then
		if uvAnimationTesting then
			StopUVAnimationTest()
		end
		uvAnimationEditorGui.selectTextureTipText.Visible = true
		uvAnimationEditorGui.animationNameTitleText.Visible = false
		uvAnimationEditorGui.animationNameValueText.Visible = false
		uvAnimationEditorGui.createUVAnimationButton.Visible = false
		uvAnimationEditorGui.uvAnimationEditorFrame.Visible = false
		return
	end
	local selectedTexture: Instance = selectedInstances[1]
	if not selectedTexture:IsA("Texture") then
		if uvAnimationTesting then
			StopUVAnimationTest()
		end
		uvAnimationEditorGui.selectTextureTipText.Visible = true
		uvAnimationEditorGui.animationNameTitleText.Visible = false
		uvAnimationEditorGui.animationNameValueText.Visible = false
		uvAnimationEditorGui.createUVAnimationButton.Visible = false
		uvAnimationEditorGui.uvAnimationEditorFrame.Visible = false
		return
	end
	uvAnimationEditorGui.animationNameTitleText.Visible = true
	uvAnimationEditorGui.animationNameValueText.Visible = true
	local animationValuesName: string = uvAnimationEditorGui.animationNameValueText.Text .. "Values"
	local uvAnimationValues: Folder = selectedTexture:FindFirstChild(animationValuesName) :: Folder
	if uvAnimationValues == nil then
		if uvAnimationTesting then
			StopUVAnimationTest()
		end
		uvAnimationEditorGui.selectTextureTipText.Visible = false
		uvAnimationEditorGui.createUVAnimationButton.Visible = true
		uvAnimationEditorGui.uvAnimationEditorFrame.Visible = false
		return
	end
	uvAnimationEditorGui.selectTextureTipText.Visible = false
	uvAnimationEditorGui.createUVAnimationButton.Visible = false
	uvAnimationEditorGui.uvAnimationEditorFrame.Visible = true
	local uSpeedValue: NumberValue = uvAnimationValues:FindFirstChild("USpeed") :: NumberValue
	if uSpeedValue == nil then
		return
	end
	local vSpeedValue: NumberValue = uvAnimationValues:FindFirstChild("VSpeed") :: NumberValue
	if vSpeedValue == nil then
		return
	end
	if not uvAnimationEditorGui.uSpeedValueText:IsFocused() then
		local uSpeedValueTextContent: string = tostring(uSpeedValue.Value)
		if uvAnimationEditorGui.uSpeedValueText.Text ~= uSpeedValueTextContent then
			uvAnimationEditorGui.uSpeedValueText.Text = tostring(uSpeedValue.Value)
		end
	end
	if not uvAnimationEditorGui.vSpeedValueText:IsFocused() then
		local vSpeedValueTextContent: string = tostring(vSpeedValue.Value)
		if uvAnimationEditorGui.vSpeedValueText.Text ~= vSpeedValueTextContent then
			uvAnimationEditorGui.vSpeedValueText.Text = tostring(vSpeedValue.Value)
		end
	end
	if uvAnimationTesting then
		selectedTexture.OffsetStudsU += uSpeedValue.Value * deltaTime
		selectedTexture.OffsetStudsV += vSpeedValue.Value * deltaTime
	end
end

local function OnCreateSpriteAnimationButtonActivated(inputObject: InputObject, clickCount: number)
	local selectedInstances: {Instance} = selection:Get()
	if #selectedInstances ~= 1 then
		return
	end
	local selectedTexture: Instance = selectedInstances[1]
	if not selectedTexture:IsA("Texture") then
		return
	end
	if spriteAnimationEditorGui == nil then
		return
	end
	local animationValuesName: string = spriteAnimationEditorGui.animationNameValueText.Text .. "Values"
	local spriteAnimationValues: Folder = selectedTexture:FindFirstChild(animationValuesName) :: Folder
	if spriteAnimationValues ~= nil then
		return
	end
	spriteAnimationValues = Instance.new("Folder")
	spriteAnimationValues.Name = animationValuesName
	spriteAnimationValues.Parent = selectedTexture
	local frameRateValue: IntValue = Instance.new("IntValue")
	frameRateValue.Name = "FrameRate"
	frameRateValue.Parent = spriteAnimationValues
	frameRateValue.Value = 30
	local frameCountValue: IntValue = Instance.new("IntValue")
	frameCountValue.Name = "FrameCount"
	frameCountValue.Parent = spriteAnimationValues
	local imageColumnCount: IntValue = Instance.new("IntValue")
	imageColumnCount.Name = "ImageColumnCount"
	imageColumnCount.Parent = spriteAnimationValues
end

local function OnSpriteAnimationFrameRateValueFocusLost(enterPressed: boolean, inputThatCausedFocusLoss: InputObject)
	local selectedInstances: {Instance} = selection:Get()
	if #selectedInstances ~= 1 then
		return
	end
	local selectedTexture: Instance = selectedInstances[1]
	if not selectedTexture:IsA("Texture") then
		return
	end
	if spriteAnimationEditorGui == nil then
		return
	end
	local animationValuesName: string = spriteAnimationEditorGui.animationNameValueText.Text .. "Values"
	local spriteAnimationValues: Folder = selectedTexture:FindFirstChild(animationValuesName) :: Folder
	if spriteAnimationValues == nil then
		return
	end
	local frameRateValue: IntValue = spriteAnimationValues:FindFirstChild("FrameRate") :: IntValue
	if frameRateValue == nil then
		return
	end
	local frameRate: number? = tonumber(spriteAnimationEditorGui.frameRateValueText.Text)
	if frameRate == nil or frameRate <= 0 then
		frameRateValue.Value = 0
		spriteAnimationEditorGui.frameRateValueText.Text = "0"
	else
		frameRateValue.Value = math.floor(frameRate)
	end
end

local function OnSpriteAnimationFrameCountValueFocusLost(enterPressed: boolean, inputThatCausedFocusLoss: InputObject)
	local selectedInstances: {Instance} = selection:Get()
	if #selectedInstances ~= 1 then
		return
	end
	local selectedTexture: Instance = selectedInstances[1]
	if not selectedTexture:IsA("Texture") then
		return
	end
	if spriteAnimationEditorGui == nil then
		return
	end
	local animationValuesName: string = spriteAnimationEditorGui.animationNameValueText.Text .. "Values"
	local spriteAnimationValues: Folder = selectedTexture:FindFirstChild(animationValuesName) :: Folder
	if spriteAnimationValues == nil then
		return
	end
	local frameCountValue: IntValue = spriteAnimationValues:FindFirstChild("FrameCount") :: IntValue
	if frameCountValue == nil then
		return
	end
	local frameCount: number? = tonumber(spriteAnimationEditorGui.frameCountValueText.Text)
	if frameCount == nil or frameCount <= 0 then
		frameCountValue.Value = 0
		spriteAnimationEditorGui.frameCountValueText.Text = "0"
	else
		frameCountValue.Value = math.floor(frameCount)
	end
end

local function OnSpriteAnimationImageCloumnCountValueFocusLost(enterPressed: boolean, inputThatCausedFocusLoss: InputObject)
	local selectedInstances: {Instance} = selection:Get()
	if #selectedInstances ~= 1 then
		return
	end
	local selectedTexture: Instance = selectedInstances[1]
	if not selectedTexture:IsA("Texture") then
		return
	end
	if spriteAnimationEditorGui == nil then
		return
	end
	local animationValuesName: string = spriteAnimationEditorGui.animationNameValueText.Text .. "Values"
	local spriteAnimationValues: Folder = selectedTexture:FindFirstChild(animationValuesName) :: Folder
	if spriteAnimationValues == nil then
		return
	end
	local imageColumnCountValue: IntValue = spriteAnimationValues:FindFirstChild("ImageColumnCount") :: IntValue
	if imageColumnCountValue == nil then
		return
	end
	local imageColumnCount: number? = tonumber(spriteAnimationEditorGui.imageColumnCountValueText.Text)
	if imageColumnCount == nil or imageColumnCount <= 0 then
		imageColumnCountValue.Value = 0
		spriteAnimationEditorGui.imageColumnCountValueText.Text = "0"
	else
		imageColumnCountValue.Value = math.floor(imageColumnCount)
	end
end

local function StartSpriteAnimationTest()
	spriteAnimationTesting = true
	spriteAnimationTime = 0
	spriteAnimationEditorGui.spriteAnimationTestButton.Text = "停止测试"
end

local function StopSpriteAnimationTest()
	spriteAnimationTesting = false
	spriteAnimationEditorGui.spriteAnimationTestButton.Text = "开始测试"
end

local function OnSpriteAnimationTestButtonActivated(inputObject: InputObject, clickCount: number)
	if spriteAnimationTesting then
		StopSpriteAnimationTest()
	else
		StartSpriteAnimationTest()
	end
end

local function OnSpriteAnimationButtonClick()
	if spriteAnimationEditorGui ~= nil then
		spriteAnimationEditorGui.dockWidgetGui.Enabled = true
		return
	end
	local dockWidgetGui: DockWidgetPluginGui = plugin:CreateDockWidgetPluginGui("SpriteAnimationEditor", WidgetInfo)
	dockWidgetGui.Title = "序列帧动画编辑器"
	
	--选择Texture提示文字
	local selectTextureTipText: TextLabel = Instance.new("TextLabel")
	selectTextureTipText.BackgroundTransparency = 1
	selectTextureTipText.Position = UDim2.new(0, 0, 0, 20)
	selectTextureTipText.Size = UDim2.new(1, 0, 0, 20)
	selectTextureTipText.TextSize = 14
	selectTextureTipText.Text = "请选择一个Texture"
	selectTextureTipText.Parent = dockWidgetGui
	
	--动画名字
	local animationNameTitleText: TextLabel = Instance.new("TextLabel")
	animationNameTitleText.BackgroundTransparency = 1
	animationNameTitleText.Position = UDim2.new(0, 10, 0, 20)
	animationNameTitleText.Size = UDim2.new(0.5, -20, 0, 20)
	animationNameTitleText.TextSize = 14
	animationNameTitleText.Text = "动画名字"
	animationNameTitleText.TextXAlignment = Enum.TextXAlignment.Left
	animationNameTitleText.Parent = dockWidgetGui
	local animationValueText: TextBox = Instance.new("TextBox")
	animationValueText.Position = UDim2.new(0.5, 10, 0, 20)
	animationValueText.Size = UDim2.new(0.5, -20, 0, 20)
	animationValueText.TextSize = 14
	animationValueText.Text = "SpriteAnimation"
	animationValueText.TextXAlignment = Enum.TextXAlignment.Left
	animationValueText.Parent = dockWidgetGui
	animationValueText.ClearTextOnFocus = false

	--创建序列帧动画按钮
	local createSpriteAnimationButton: TextButton = Instance.new("TextButton")
	createSpriteAnimationButton.Position = UDim2.new(0, 10, 0, 50)
	createSpriteAnimationButton.Size = UDim2.new(1, -20, 0, 20)
	createSpriteAnimationButton.TextSize = 14
	createSpriteAnimationButton.Text = "创建序列帧动画"
	createSpriteAnimationButton.Parent = dockWidgetGui
	createSpriteAnimationButton.Activated:Connect(OnCreateSpriteAnimationButtonActivated)

	--序列帧动画编辑
	local spriteAnimationEditorFrame: Frame = Instance.new("Frame")
	spriteAnimationEditorFrame.BackgroundTransparency = 1
	spriteAnimationEditorFrame.Size = UDim2.new(1, 0, 1, 0)
	spriteAnimationEditorFrame.Parent = dockWidgetGui
	--帧率
	local frameRateTitleText: TextLabel = Instance.new("TextLabel")
	frameRateTitleText.BackgroundTransparency = 1
	frameRateTitleText.Position = UDim2.new(0, 10, 0, 50)
	frameRateTitleText.Size = UDim2.new(0.5, -20, 0, 20)
	frameRateTitleText.TextSize = 14
	frameRateTitleText.Text = "帧率"
	frameRateTitleText.TextXAlignment = Enum.TextXAlignment.Left
	frameRateTitleText.Parent = spriteAnimationEditorFrame
	local frameRateValueText: TextBox = Instance.new("TextBox")
	frameRateValueText.Position = UDim2.new(0.5, 10, 0, 50)
	frameRateValueText.Size = UDim2.new(0.5, -20, 0, 20)
	frameRateValueText.TextSize = 14
	frameRateValueText.Text = "30"
	frameRateValueText.TextXAlignment = Enum.TextXAlignment.Left
	frameRateValueText.Parent = spriteAnimationEditorFrame
	frameRateValueText.ClearTextOnFocus = false
	frameRateValueText.FocusLost:Connect(OnSpriteAnimationFrameRateValueFocusLost)
	--帧数
	local frameCountTitleText: TextLabel = Instance.new("TextLabel")
	frameCountTitleText.BackgroundTransparency = 1
	frameCountTitleText.Position = UDim2.new(0, 10, 0, 80)
	frameCountTitleText.Size = UDim2.new(0.5, -20, 0, 20)
	frameCountTitleText.TextSize = 14
	frameCountTitleText.Text = "帧数"
	frameCountTitleText.TextXAlignment = Enum.TextXAlignment.Left
	frameCountTitleText.Parent = spriteAnimationEditorFrame
	local frameCountValueText: TextBox = Instance.new("TextBox")
	frameCountValueText.Position = UDim2.new(0.5, 10, 0, 80)
	frameCountValueText.Size = UDim2.new(0.5, -20, 0, 20)
	frameCountValueText.TextSize = 14
	frameCountValueText.Text = "0"
	frameCountValueText.TextXAlignment = Enum.TextXAlignment.Left
	frameCountValueText.Parent = spriteAnimationEditorFrame
	frameCountValueText.ClearTextOnFocus = false
	frameCountValueText.FocusLost:Connect(OnSpriteAnimationFrameCountValueFocusLost)
	--图片列数
	local imageColumnCountTitleText: TextLabel = Instance.new("TextLabel")
	imageColumnCountTitleText.BackgroundTransparency = 1
	imageColumnCountTitleText.Position = UDim2.new(0, 10, 0, 110)
	imageColumnCountTitleText.Size = UDim2.new(0.5, -20, 0, 20)
	imageColumnCountTitleText.TextSize = 14
	imageColumnCountTitleText.Text = "图片列数"
	imageColumnCountTitleText.TextXAlignment = Enum.TextXAlignment.Left
	imageColumnCountTitleText.Parent = spriteAnimationEditorFrame
	local imageColumnCountValueText: TextBox = Instance.new("TextBox")
	imageColumnCountValueText.Position = UDim2.new(0.5, 10, 0, 110)
	imageColumnCountValueText.Size = UDim2.new(0.5, -20, 0, 20)
	imageColumnCountValueText.TextSize = 14
	imageColumnCountValueText.Text = "0"
	imageColumnCountValueText.TextXAlignment = Enum.TextXAlignment.Left
	imageColumnCountValueText.Parent = spriteAnimationEditorFrame
	imageColumnCountValueText.ClearTextOnFocus = false
	imageColumnCountValueText.FocusLost:Connect(OnSpriteAnimationImageCloumnCountValueFocusLost)
	--序列帧动画测试按钮
	local spriteAnimationTestButton: TextButton = Instance.new("TextButton")
	spriteAnimationTestButton.Position = UDim2.new(0, 10, 0, 140)
	spriteAnimationTestButton.Size = UDim2.new(1, -20, 0, 20)
	spriteAnimationTestButton.TextSize = 14
	spriteAnimationTestButton.Text = "开始测试"
	spriteAnimationTestButton.Parent = spriteAnimationEditorFrame
	spriteAnimationTestButton.Activated:Connect(OnSpriteAnimationTestButtonActivated)
	--重置UV偏移按钮
	local resetUVOffsetButton: TextButton = Instance.new("TextButton")
	resetUVOffsetButton.Position = UDim2.new(0, 10, 0, 170)
	resetUVOffsetButton.Size = UDim2.new(1, -20, 0, 20)
	resetUVOffsetButton.TextSize = 14
	resetUVOffsetButton.Text = "重置UV偏移"
	resetUVOffsetButton.Parent = spriteAnimationEditorFrame
	resetUVOffsetButton.Activated:Connect(OnResetUVOffsetButtonActivated)

	spriteAnimationEditorGui = {
		dockWidgetGui = dockWidgetGui,
		selectTextureTipText = selectTextureTipText,
		animationNameTitleText = animationNameTitleText,
		animationNameValueText = animationValueText,
		createSpriteAnimationButton = createSpriteAnimationButton,
		spriteAnimationEditorFrame = spriteAnimationEditorFrame,
		frameRateTitleText = frameRateTitleText,
		frameRateValueText = frameRateValueText,
		frameCountTitleText = frameCountTitleText,
		frameCountValueText = frameCountValueText,
		imageColumnCountTitleText = imageColumnCountTitleText,
		imageColumnCountValueText = imageColumnCountValueText,
		spriteAnimationTestButton = spriteAnimationTestButton,
		resetUVOffsetButton = resetUVOffsetButton,
	}
	UpdateGuiTheme(dockWidgetGui)
end

local function UpdateSpriteAnimationEditor(deltaTime: number)
	if spriteAnimationEditorGui == nil or not spriteAnimationEditorGui.dockWidgetGui.Enabled then
		return
	end
	local selectedInstances: {Instance} = selection:Get()
	if #selectedInstances ~= 1 then
		if spriteAnimationTesting then
			StopSpriteAnimationTest()
		end
		spriteAnimationEditorGui.selectTextureTipText.Visible = true
		spriteAnimationEditorGui.animationNameTitleText.Visible = false
		spriteAnimationEditorGui.animationNameValueText.Visible = false
		spriteAnimationEditorGui.createSpriteAnimationButton.Visible = false
		spriteAnimationEditorGui.spriteAnimationEditorFrame.Visible = false
		return
	end
	local selectedTexture: Instance = selectedInstances[1]
	if not selectedTexture:IsA("Texture") then
		if spriteAnimationTesting then
			StopSpriteAnimationTest()
		end
		spriteAnimationEditorGui.selectTextureTipText.Visible = true
		spriteAnimationEditorGui.animationNameTitleText.Visible = false
		spriteAnimationEditorGui.animationNameValueText.Visible = false
		spriteAnimationEditorGui.createSpriteAnimationButton.Visible = false
		spriteAnimationEditorGui.spriteAnimationEditorFrame.Visible = false
		return
	end
	spriteAnimationEditorGui.animationNameTitleText.Visible = true
	spriteAnimationEditorGui.animationNameValueText.Visible = true
	local animationValuesName: string = spriteAnimationEditorGui.animationNameValueText.Text .. "Values"
	local spriteAnimationValues: Folder = selectedTexture:FindFirstChild(animationValuesName) :: Folder
	if spriteAnimationValues == nil then
		if spriteAnimationTesting then
			StopSpriteAnimationTest()
		end
		spriteAnimationEditorGui.selectTextureTipText.Visible = false
		spriteAnimationEditorGui.createSpriteAnimationButton.Visible = true
		spriteAnimationEditorGui.spriteAnimationEditorFrame.Visible = false
		return
	end
	spriteAnimationEditorGui.selectTextureTipText.Visible = false
	spriteAnimationEditorGui.createSpriteAnimationButton.Visible = false
	spriteAnimationEditorGui.spriteAnimationEditorFrame.Visible = true
	local frameRateValue: IntValue = spriteAnimationValues:FindFirstChild("FrameRate") :: IntValue
	if frameRateValue == nil then
		return
	end
	local frameCountValue: IntValue = spriteAnimationValues:FindFirstChild("FrameCount") :: IntValue
	if frameCountValue == nil then
		return
	end
	local imageColumnCountValue: IntValue = spriteAnimationValues:FindFirstChild("ImageColumnCount") :: IntValue
	if imageColumnCountValue == nil then
		return
	end
	if not spriteAnimationEditorGui.frameRateValueText:IsFocused() then
		local frameRateValueTextContent: string = tostring(frameRateValue.Value)
		if spriteAnimationEditorGui.frameRateValueText.Text ~= frameRateValueTextContent then
			spriteAnimationEditorGui.frameRateValueText.Text = tostring(frameRateValue.Value)
		end
	end
	if not spriteAnimationEditorGui.frameCountValueText:IsFocused() then
		local frameCountValueTextContent: string = tostring(frameCountValue.Value)
		if spriteAnimationEditorGui.frameCountValueText.Text ~= frameCountValueTextContent then
			spriteAnimationEditorGui.frameCountValueText.Text = tostring(frameCountValue.Value)
		end
	end
	if not spriteAnimationEditorGui.imageColumnCountValueText:IsFocused() then
		local imageColumnCountValueTextContent: string = tostring(imageColumnCountValue.Value)
		if spriteAnimationEditorGui.imageColumnCountValueText.Text ~= imageColumnCountValueTextContent then
			spriteAnimationEditorGui.imageColumnCountValueText.Text = tostring(imageColumnCountValue.Value)
		end
	end
	if spriteAnimationTesting then
		spriteAnimationTime += deltaTime
		local frameIndex: number = math.floor(spriteAnimationTime * frameRateValue.Value) % frameCountValue.Value
		local lineIndex: number = math.floor(frameIndex / imageColumnCountValue.Value)
		local columnIndex: number = frameIndex - lineIndex * imageColumnCountValue.Value
		selectedTexture.OffsetStudsU = selectedTexture.StudsPerTileU / imageColumnCountValue.Value * columnIndex
		selectedTexture.OffsetStudsV = selectedTexture.StudsPerTileV / imageColumnCountValue.Value * lineIndex
	end
end

local function OnCreateRotateAnimationButtonActivated(inputObject: InputObject, clickCount: number)
	local selectedInstances: {Instance} = selection:Get()
	if #selectedInstances ~= 1 then
		return
	end
	local selectedInstance: Instance = selectedInstances[1]
	if not selectedInstance:IsA("PVInstance") then
		return
	end
	if rotateAnimationEditorGui == nil then
		return
	end
	local animationValuesName: string = rotateAnimationEditorGui.animationNameValueText.Text .. "Values"
	local rotateAnimationValues: Folder = selectedInstance:FindFirstChild(animationValuesName) :: Folder
	if rotateAnimationValues ~= nil then
		return
	end
	rotateAnimationValues = Instance.new("Folder")
	rotateAnimationValues.Name = animationValuesName
	rotateAnimationValues.Parent = selectedInstance
	local xSpeedValue: NumberValue = Instance.new("NumberValue")
	xSpeedValue.Name = "XSpeed"
	xSpeedValue.Parent = rotateAnimationValues
	local ySpeedValue: NumberValue = Instance.new("NumberValue")
	ySpeedValue.Name = "YSpeed"
	ySpeedValue.Parent = rotateAnimationValues
	local zSpeedValue: NumberValue = Instance.new("NumberValue")
	zSpeedValue.Name = "ZSpeed"
	zSpeedValue.Parent = rotateAnimationValues
end

local function OnRotateAnimationXSpeedValueFocusLost(enterPressed: boolean, inputThatCausedFocusLoss: InputObject)
	local selectedInstances: {Instance} = selection:Get()
	if #selectedInstances ~= 1 then
		return
	end
	local selectedInstance: Instance = selectedInstances[1]
	if not selectedInstance:IsA("PVInstance") then
		return
	end
	if rotateAnimationEditorGui == nil then
		return
	end
	local animationValuesName: string = rotateAnimationEditorGui.animationNameValueText.Text .. "Values"
	local rotateAnimationValues: Folder = selectedInstance:FindFirstChild(animationValuesName) :: Folder
	if rotateAnimationValues == nil then
		return
	end
	local xSpeedValue: NumberValue = rotateAnimationValues:FindFirstChild("XSpeed") :: NumberValue
	if xSpeedValue == nil then
		return
	end
	local xSpeed: number? = tonumber(rotateAnimationEditorGui.xSpeedValueText.Text)
	if xSpeed == nil then
		xSpeedValue.Value = 0
		rotateAnimationEditorGui.xSpeedValueText.Text = "0"
	else
		xSpeedValue.Value = xSpeed
	end
end

local function OnRotateAnimationYSpeedValueFocusLost(enterPressed: boolean, inputThatCausedFocusLoss: InputObject)
	local selectedInstances: {Instance} = selection:Get()
	if #selectedInstances ~= 1 then
		return
	end
	local selectedInstance: Instance = selectedInstances[1]
	if not selectedInstance:IsA("PVInstance") then
		return
	end
	if rotateAnimationEditorGui == nil then
		return
	end
	local animationValuesName: string = rotateAnimationEditorGui.animationNameValueText.Text .. "Values"
	local rotateAnimationValues: Folder = selectedInstance:FindFirstChild(animationValuesName) :: Folder
	if rotateAnimationValues == nil then
		return
	end
	local ySpeedValue: NumberValue = rotateAnimationValues:FindFirstChild("YSpeed") :: NumberValue
	if ySpeedValue == nil then
		return
	end
	local ySpeed: number? = tonumber(rotateAnimationEditorGui.ySpeedValueText.Text)
	if ySpeed == nil then
		ySpeedValue.Value = 0
		rotateAnimationEditorGui.ySpeedValueText.Text = "0"
	else
		ySpeedValue.Value = ySpeed
	end
end

local function OnRotateAnimationZSpeedValueFocusLost(enterPressed: boolean, inputThatCausedFocusLoss: InputObject)
	local selectedInstances: {Instance} = selection:Get()
	if #selectedInstances ~= 1 then
		return
	end
	local selectedInstance: Instance = selectedInstances[1]
	if not selectedInstance:IsA("PVInstance") then
		return
	end
	if rotateAnimationEditorGui == nil then
		return
	end
	local animationValuesName: string = rotateAnimationEditorGui.animationNameValueText.Text .. "Values"
	local rotateAnimationValues: Folder = selectedInstance:FindFirstChild(animationValuesName) :: Folder
	if rotateAnimationValues == nil then
		return
	end
	local zSpeedValue: NumberValue = rotateAnimationValues:FindFirstChild("ZSpeed") :: NumberValue
	if zSpeedValue == nil then
		return
	end
	local zSpeed: number? = tonumber(rotateAnimationEditorGui.zSpeedValueText.Text)
	if zSpeed == nil then
		zSpeedValue.Value = 0
		rotateAnimationEditorGui.xSpeedValueText.Text = "0"
	else
		zSpeedValue.Value = zSpeed
	end
end

local function StartRotateAnimationTest()
	rotateAnimationTesting = true
	rotateAnimationEditorGui.rotateAnimationTestButton.Text = "停止测试"
end

local function StopRotateAnimationTest()
	rotateAnimationTesting = false
	rotateAnimationEditorGui.rotateAnimationTestButton.Text = "开始测试"
end

local function OnRotateAnimationTestButtonActivated(inputObject: InputObject, clickCount: number)
	if rotateAnimationTesting then
		StopRotateAnimationTest()
	else
		StartRotateAnimationTest()
	end
end

local function OnResetRotationButtonActivated(inputObject: InputObject, clickCount: number)
	local selectedInstances: {Instance} = selection:Get()
	if #selectedInstances ~= 1 then
		return
	end
	local selectedInstance: Instance = selectedInstances[1]
	if not selectedInstance:IsA("PVInstance") then
		return
	end
	selectedInstance:PivotTo(CFrame.new(selectedInstance:GetPivot().Position))
end

local function OnRotateAnimationButtonClick()
	if rotateAnimationEditorGui ~= nil then
		rotateAnimationEditorGui.dockWidgetGui.Enabled = true
		return
	end
	local dockWidgetGui: DockWidgetPluginGui = plugin:CreateDockWidgetPluginGui("RotateAnimationEditor", WidgetInfo)
	dockWidgetGui.Title = "旋转动画编辑器"

	--选择PVInstance提示文字
	local selectPVInstanceTipText: TextLabel = Instance.new("TextLabel")
	selectPVInstanceTipText.BackgroundTransparency = 1
	selectPVInstanceTipText.Position = UDim2.new(0, 0, 0, 20)
	selectPVInstanceTipText.Size = UDim2.new(1, 0, 0, 20)
	selectPVInstanceTipText.TextSize = 14
	selectPVInstanceTipText.Text = "请选择一个Part | MeshPart | Model"
	selectPVInstanceTipText.Parent = dockWidgetGui
	
	--动画名字
	local animationNameTitleText: TextLabel = Instance.new("TextLabel")
	animationNameTitleText.BackgroundTransparency = 1
	animationNameTitleText.Position = UDim2.new(0, 10, 0, 20)
	animationNameTitleText.Size = UDim2.new(0.5, -20, 0, 20)
	animationNameTitleText.TextSize = 14
	animationNameTitleText.Text = "动画名字"
	animationNameTitleText.TextXAlignment = Enum.TextXAlignment.Left
	animationNameTitleText.Parent = dockWidgetGui
	local animationValueText: TextBox = Instance.new("TextBox")
	animationValueText.Position = UDim2.new(0.5, 10, 0, 20)
	animationValueText.Size = UDim2.new(0.5, -20, 0, 20)
	animationValueText.TextSize = 14
	animationValueText.Text = "RotateAnimation"
	animationValueText.TextXAlignment = Enum.TextXAlignment.Left
	animationValueText.Parent = dockWidgetGui
	animationValueText.ClearTextOnFocus = false

	--创建旋转动画按钮
	local createRotateAnimationButton: TextButton = Instance.new("TextButton")
	createRotateAnimationButton.Position = UDim2.new(0, 10, 0, 50)
	createRotateAnimationButton.Size = UDim2.new(1, -20, 0, 20)
	createRotateAnimationButton.TextSize = 14
	createRotateAnimationButton.Text = "创建旋转动画"
	createRotateAnimationButton.Parent = dockWidgetGui
	createRotateAnimationButton.Activated:Connect(OnCreateRotateAnimationButtonActivated)

	--旋转动画编辑
	local rotateAnimationEditorFrame: Frame = Instance.new("Frame")
	rotateAnimationEditorFrame.BackgroundTransparency = 1
	rotateAnimationEditorFrame.Size = UDim2.new(1, 0, 1, 0)
	rotateAnimationEditorFrame.Parent = dockWidgetGui
	--x轴速度
	local xSpeedTitleText: TextLabel = Instance.new("TextLabel")
	xSpeedTitleText.BackgroundTransparency = 1
	xSpeedTitleText.Position = UDim2.new(0, 10, 0, 50)
	xSpeedTitleText.Size = UDim2.new(0.5, -20, 0, 20)
	xSpeedTitleText.TextSize = 14
	xSpeedTitleText.Text = "x轴速度"
	xSpeedTitleText.TextXAlignment = Enum.TextXAlignment.Left
	xSpeedTitleText.Parent = rotateAnimationEditorFrame
	local xSpeedValueText: TextBox = Instance.new("TextBox")
	xSpeedValueText.Position = UDim2.new(0.5, 10, 0, 50)
	xSpeedValueText.Size = UDim2.new(0.5, -20, 0, 20)
	xSpeedValueText.TextSize = 14
	xSpeedValueText.Text = "0"
	xSpeedValueText.TextXAlignment = Enum.TextXAlignment.Left
	xSpeedValueText.Parent = rotateAnimationEditorFrame
	xSpeedValueText.ClearTextOnFocus = false
	xSpeedValueText.FocusLost:Connect(OnRotateAnimationXSpeedValueFocusLost)
	--y轴速度
	local ySpeedTitleText: TextLabel = Instance.new("TextLabel")
	ySpeedTitleText.BackgroundTransparency = 1
	ySpeedTitleText.Position = UDim2.new(0, 10, 0, 80)
	ySpeedTitleText.Size = UDim2.new(0.5, -20, 0, 20)
	ySpeedTitleText.TextSize = 14
	ySpeedTitleText.Text = "y轴速度"
	ySpeedTitleText.TextXAlignment = Enum.TextXAlignment.Left
	ySpeedTitleText.Parent = rotateAnimationEditorFrame
	local ySpeedValueText: TextBox = Instance.new("TextBox")
	ySpeedValueText.Position = UDim2.new(0.5, 10, 0, 80)
	ySpeedValueText.Size = UDim2.new(0.5, -20, 0, 20)
	ySpeedValueText.TextSize = 14
	ySpeedValueText.Text = "0"
	ySpeedValueText.TextXAlignment = Enum.TextXAlignment.Left
	ySpeedValueText.Parent = rotateAnimationEditorFrame
	ySpeedValueText.ClearTextOnFocus = false
	ySpeedValueText.FocusLost:Connect(OnRotateAnimationYSpeedValueFocusLost)
	--z轴速度
	local zSpeedTitleText: TextLabel = Instance.new("TextLabel")
	zSpeedTitleText.BackgroundTransparency = 1
	zSpeedTitleText.Position = UDim2.new(0, 10, 0, 110)
	zSpeedTitleText.Size = UDim2.new(0.5, -20, 0, 20)
	zSpeedTitleText.TextSize = 14
	zSpeedTitleText.Text = "z轴速度"
	zSpeedTitleText.TextXAlignment = Enum.TextXAlignment.Left
	zSpeedTitleText.Parent = rotateAnimationEditorFrame
	local zSpeedValueText: TextBox = Instance.new("TextBox")
	zSpeedValueText.Position = UDim2.new(0.5, 10, 0, 110)
	zSpeedValueText.Size = UDim2.new(0.5, -20, 0, 20)
	zSpeedValueText.TextSize = 14
	zSpeedValueText.Text = "0"
	zSpeedValueText.TextXAlignment = Enum.TextXAlignment.Left
	zSpeedValueText.Parent = rotateAnimationEditorFrame
	zSpeedValueText.ClearTextOnFocus = false
	zSpeedValueText.FocusLost:Connect(OnRotateAnimationZSpeedValueFocusLost)
	--旋转动画测试按钮
	local rotateAnimationTestButton: TextButton = Instance.new("TextButton")
	rotateAnimationTestButton.Position = UDim2.new(0, 10, 0, 140)
	rotateAnimationTestButton.Size = UDim2.new(1, -20, 0, 20)
	rotateAnimationTestButton.TextSize = 14
	rotateAnimationTestButton.Text = "开始测试"
	rotateAnimationTestButton.Parent = rotateAnimationEditorFrame
	rotateAnimationTestButton.Activated:Connect(OnRotateAnimationTestButtonActivated)
	--重置UV偏移按钮
	local resetRotationButton: TextButton = Instance.new("TextButton")
	resetRotationButton.Position = UDim2.new(0, 10, 0, 170)
	resetRotationButton.Size = UDim2.new(1, -20, 0, 20)
	resetRotationButton.TextSize = 14
	resetRotationButton.Text = "重置旋转"
	resetRotationButton.Parent = rotateAnimationEditorFrame
	resetRotationButton.Activated:Connect(OnResetRotationButtonActivated)

	rotateAnimationEditorGui = {
		dockWidgetGui = dockWidgetGui,
		selectPVInstanceTipText = selectPVInstanceTipText,
		animationNameTitleText = animationNameTitleText,
		animationNameValueText = animationValueText,
		createRotateAnimationButton = createRotateAnimationButton,
		rotateAnimationEditorFrame = rotateAnimationEditorFrame,
		xSpeedTitleText = xSpeedTitleText,
		xSpeedValueText = xSpeedValueText,
		ySpeedTitleText = ySpeedTitleText,
		ySpeedValueText = ySpeedValueText,
		zSpeedTitleText = zSpeedTitleText,
		zSpeedValueText = zSpeedValueText,
		rotateAnimationTestButton = rotateAnimationTestButton,
		resetRotationButton = resetRotationButton,
	}
	UpdateGuiTheme(dockWidgetGui)
end

local function UpdateRotateAnimationEditor(deltaTime: number)
	if rotateAnimationEditorGui == nil or not rotateAnimationEditorGui.dockWidgetGui.Enabled then
		return
	end
	local selectedInstances: {Instance} = selection:Get()
	if #selectedInstances ~= 1 then
		if rotateAnimationTesting then
			StopRotateAnimationTest()
		end
		rotateAnimationEditorGui.selectPVInstanceTipText.Visible = true
		rotateAnimationEditorGui.animationNameTitleText.Visible = false
		rotateAnimationEditorGui.animationNameValueText.Visible = false
		rotateAnimationEditorGui.createRotateAnimationButton.Visible = false
		rotateAnimationEditorGui.rotateAnimationEditorFrame.Visible = false
		return
	end
	local selectedInstance: Instance = selectedInstances[1]
	if not selectedInstance:IsA("PVInstance") then
		if rotateAnimationTesting then
			StopRotateAnimationTest()
		end
		rotateAnimationEditorGui.selectPVInstanceTipText.Visible = true
		rotateAnimationEditorGui.animationNameTitleText.Visible = false
		rotateAnimationEditorGui.animationNameValueText.Visible = false
		rotateAnimationEditorGui.createRotateAnimationButton.Visible = false
		rotateAnimationEditorGui.rotateAnimationEditorFrame.Visible = false
		return
	end
	rotateAnimationEditorGui.animationNameTitleText.Visible = true
	rotateAnimationEditorGui.animationNameValueText.Visible = true
	local animationValuesName: string = rotateAnimationEditorGui.animationNameValueText.Text .. "Values"
	local rotateAnimationValues: Folder = selectedInstance:FindFirstChild(animationValuesName) :: Folder
	if rotateAnimationValues == nil then
		if rotateAnimationTesting then
			StopRotateAnimationTest()
		end
		rotateAnimationEditorGui.selectPVInstanceTipText.Visible = false
		rotateAnimationEditorGui.createRotateAnimationButton.Visible = true
		rotateAnimationEditorGui.rotateAnimationEditorFrame.Visible = false
		return
	end
	rotateAnimationEditorGui.selectPVInstanceTipText.Visible = false
	rotateAnimationEditorGui.createRotateAnimationButton.Visible = false
	rotateAnimationEditorGui.rotateAnimationEditorFrame.Visible = true
	local xSpeedValue: NumberValue = rotateAnimationValues:FindFirstChild("XSpeed") :: NumberValue
	if xSpeedValue == nil then
		return
	end
	local ySpeedValue: NumberValue = rotateAnimationValues:FindFirstChild("YSpeed") :: NumberValue
	if ySpeedValue == nil then
		return
	end
	local zSpeedValue: NumberValue = rotateAnimationValues:FindFirstChild("ZSpeed") :: NumberValue
	if zSpeedValue == nil then
		return
	end
	if not rotateAnimationEditorGui.xSpeedValueText:IsFocused() then
		local xSpeedValueTextContent: string = tostring(xSpeedValue.Value)
		if rotateAnimationEditorGui.xSpeedValueText.Text ~= xSpeedValueTextContent then
			rotateAnimationEditorGui.xSpeedValueText.Text = tostring(xSpeedValue.Value)
		end
	end
	if not rotateAnimationEditorGui.ySpeedValueText:IsFocused() then
		local ySpeedValueTextContent: string = tostring(ySpeedValue.Value)
		if rotateAnimationEditorGui.ySpeedValueText.Text ~= ySpeedValueTextContent then
			rotateAnimationEditorGui.ySpeedValueText.Text = tostring(ySpeedValue.Value)
		end
	end
	if not rotateAnimationEditorGui.zSpeedValueText:IsFocused() then
		local zSpeedValueTextContent: string = tostring(zSpeedValue.Value)
		if rotateAnimationEditorGui.zSpeedValueText.Text ~= zSpeedValueTextContent then
			rotateAnimationEditorGui.zSpeedValueText.Text = tostring(zSpeedValue.Value)
		end
	end
	if rotateAnimationTesting then
		local rotateX: number = math.rad(xSpeedValue.Value) * deltaTime
		local rotateY: number = math.rad(ySpeedValue.Value) * deltaTime
		local rotateZ: number = math.rad(zSpeedValue.Value) * deltaTime
		selectedInstance:PivotTo(selectedInstance:GetPivot() * CFrame.Angles(rotateX, rotateY, rotateZ))
	end
end

local function OnUpdate(deltaTime: number)
	UpdateUVAnimationEditor(deltaTime)
	UpdateSpriteAnimationEditor(deltaTime)
	UpdateRotateAnimationEditor(deltaTime)
end

local function OnThemeChanged()
	UpdateCurrentThemeColors()
	if uvAnimationEditorGui ~= nil and uvAnimationEditorGui.dockWidgetGui ~= nil then
		UpdateGuiTheme(uvAnimationEditorGui.dockWidgetGui)
	end
	if spriteAnimationEditorGui ~= nil and spriteAnimationEditorGui.dockWidgetGui ~= nil then
		UpdateGuiTheme(spriteAnimationEditorGui.dockWidgetGui)
	end
	if rotateAnimationEditorGui ~= nil and rotateAnimationEditorGui.dockWidgetGui ~= nil then
		UpdateGuiTheme(rotateAnimationEditorGui.dockWidgetGui)
	end
end

local toolbar: PluginToolbar = plugin:CreateToolbar("动画扩展")
local uvAnimationButton: PluginToolbarButton = toolbar:CreateButton("UV动画", "", "rbxassetid://14978048121")
uvAnimationButton.ClickableWhenViewportHidden = true
uvAnimationButton.Click:Connect(OnUVAnimationButtonClick)
local spriteAnimationButton: PluginToolbarButton = toolbar:CreateButton("序列帧动画", "", "rbxassetid://14978048121")
spriteAnimationButton.ClickableWhenViewportHidden = true
spriteAnimationButton.Click:Connect(OnSpriteAnimationButtonClick)
local rotateAnimationButton: PluginToolbarButton = toolbar:CreateButton("旋转动画", "", "rbxassetid://14978048121")
rotateAnimationButton.ClickableWhenViewportHidden = true
rotateAnimationButton.Click:Connect(OnRotateAnimationButtonClick)

runService.Heartbeat:Connect(OnUpdate)
UpdateCurrentThemeColors()
studio.ThemeChanged:Connect(OnThemeChanged)