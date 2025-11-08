local Selection = game:GetService("Selection")

--创建一个插件工具栏
local toolbar = plugin:CreateToolbar("编辑器扩展")
local button = toolbar:CreateButton("批处理后代", "批处理后代", "rbxassetid://14978048121")
button.ClickableWhenViewportHidden = true


--为按钮添加UIScale
local function AddButtonUIScale(child)
	if not child:IsA("ImageButton") and not child:IsA("TextButton") then
		return
	end
	local buttonScale = child:FindFirstChild("UIScale") :: UIScale
	if not buttonScale then
		buttonScale = Instance.new("UIScale", child)
		buttonScale.Name = "UIScale"
	end
end

--为按钮添加属性
local function AddButtonAttribute(child)
	if not child:IsA("ImageButton") and not child:IsA("TextButton") then
		return
	end
	if child:GetAttribute("HasInteractionEffect") == nil then
		child:SetAttribute("HasInteractionEffect", true)
	end
end

--取消物体碰撞，添加锚定
local function CancelCollide(child)
	if not child:IsA("BasePart") and not child:IsA("UnionOperation") then
		return
	end
	child.CanCollide = false
	child.CanTouch = false
	child.CanQuery = false
	child.Anchored = true
end

--填入要执行的具体内容
local function Work(child)
	AddButtonUIScale(child)
	AddButtonAttribute(child)
end
	
--对选中对象及其后代进行批处理操作
button.Click:Connect(function()
	local selectedObjects = Selection:Get()
	for _, object in ipairs(selectedObjects) do
		Work(object)
		for _, child in object:GetDescendants() do
			Work(child)
		end
	end
	print("批处理完成")
end)