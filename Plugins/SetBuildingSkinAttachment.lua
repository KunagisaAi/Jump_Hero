local Selection = game:GetService("Selection")

--创建一个插件工具栏
local toolbar = plugin:CreateToolbar("编辑器扩展")
local button = toolbar:CreateButton("建筑皮肤点位同步", "建筑皮肤点位同步", "rbxassetid://14978048121")
button.ClickableWhenViewportHidden = true

	
button.Click:Connect(function()
	local selectedObjects = Selection:Get()
	local objectRefer --参照皮肤
	local objects = {} --待处理皮肤
	for _, object in selectedObjects do
		if string.find(object.Name, "Blue") then
			objectRefer = object
		else
			table.insert(objects, object)
		end
	end
	if objectRefer == nil then
		return
	end
	
	local attachmentRefers = {} --记录参照皮肤的点位信息
	for _, des in objectRefer:GetDescendants() do
		if des:IsA("Attachment") then
			attachmentRefers[des.Name] = des
		end
	end
	
	--将参照皮肤的点位信息同步至待处理皮肤
	for _, object in objects do
		for _, des in object:GetDescendants() do
			if des:IsA("Attachment") and attachmentRefers[des.Name] then
				des.CFrame = attachmentRefers[des.Name].CFrame
			end
		end
	end
	print("处理完成")
end)