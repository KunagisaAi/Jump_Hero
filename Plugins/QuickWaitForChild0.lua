local Selection = game:GetService("Selection")

--创建一个插件工具栏
local toolbar = plugin:CreateToolbar("代码扩展")
local button = toolbar:CreateButton("获取对象路径", "获取所选对象的路径", "rbxassetid://14978048121")
button.ClickableWhenViewportHidden = true

--规范对象名
local function NormalizeName(str: string, className: string?)
	if str == "Shared" then
		str = "sharedScripts"
	elseif str == "Client" then
		str = "clientScripts"
	elseif className == "Folder" then
		str = str .. "Folder"
	elseif className == "BindableEvent" or className == "RemoteEvent" then
		str = str .. "Event"
	end
	--首字母小写
	if #str <= 1 then
		return string.lower(str)
	end
	return string.lower(string.sub(str, 1, 1)) .. string.sub(str, 2)
end

--构建RemoteEvent函数
local function CreateRemoteEventFunction(objectName: string) : string
	local prefix = "Request"
	local prefix2 = "Notify"
	local prefix3 = "NotifyPlayer"
	local printText
	if string.sub(objectName, 1, string.len(prefix)) == prefix then
		printText = "\n\nfunction NetMsg.Fire"..objectName.."()\n"
			..NormalizeName(objectName, "RemoteEvent")..":FireServer()\nend\n"
			.."\nfunction NetMsg.Connect"..objectName.."(callback: (player: Player) -> ())\n"
			..NormalizeName(objectName, "RemoteEvent")..".OnServerEvent:Connect(callback)\nend\n"
	elseif string.sub(objectName, 1, string.len(prefix2)) == prefix2 then
		if string.sub(objectName, 1, string.len(prefix3)) == prefix3 then
			printText = "\n\nfunction NetMsg.Fire"..objectName.."(player: Player)\n"
				..NormalizeName(objectName, "RemoteEvent")..":FireClient(player)\nend\n"
				.."\nfunction NetMsg.Connect"..objectName.."(callback: () -> ())\n"
				..NormalizeName(objectName, "RemoteEvent")..".OnClientEvent:Connect(callback)\nend\n"
		else
			printText = "\n\nfunction NetMsg.Fire"..objectName.."()\n"
				..NormalizeName(objectName, "RemoteEvent")..":FireAllClients()\nend\n"
				.."\nfunction NetMsg.Connect"..objectName.."(callback: () -> ())\n"
				..NormalizeName(objectName, "RemoteEvent")..".OnClientEvent:Connect(callback)\nend\n"
		end
	end
	return printText
end

--构建BindableEvent函数
local function CreateBindableEventFunction(scriptName: string, objectName: string) : string
	local printText = "\n\nfunction "..scriptName..".Fire"..objectName.."()\n"
		..NormalizeName(objectName, "BindableEvent")..":Fire()\nend\n"
		.."\nfunction "..scriptName..".Connect"..objectName.."(callback: () -> ())\n"
		..NormalizeName(objectName, "BindableEvent")..".Event:Connect(callback)\nend\n"
	return printText
end

--当按钮被点击时执行
button.Click:Connect(function()
	local selectedObjects = Selection:Get()
	local printTextAll = ""
	local names: {[string]: boolen} = {} --避免重复
	--依次处理所选中对象
	for _, object in ipairs(selectedObjects) do
		local printText = ""
		local objectLeave = object
		local objectRoot
		--自叶到根
		while true do
			if object.Parent:IsA("DataModel") then
				objectRoot = object
				if not object:IsA("Workspace") and not names[object.Name] then
					printText = "local "..NormalizeName(object.Name).." = game:GetService(\""..object.Name.."\")\n" .. printText
				end
				names[object.Name] = true
				break
			end
			if not names[object.Name] then
				if object:IsA("ModuleScript") then
					printText = "local "..object.Name.." = require("..NormalizeName(object.Parent.Name, object.Parent.ClassName)..":FindFirstChild(\""..object.Name.."\"))\n" .. printText
				elseif object:IsA("Folder") then
					printText = "local "..NormalizeName(object.Name, object.ClassName).." = "..NormalizeName(object.Parent.Name, object.Parent.ClassName)..":FindFirstChild(\""..object.Name.."\")\n" .. printText
				else
					printText = "local "..NormalizeName(object.Name, object.ClassName)..": " .. object.ClassName .. " = "..NormalizeName(object.Parent.Name, object.Parent.ClassName)..":FindFirstChild(\""..object.Name.."\") :: "..object.ClassName.."\n" .. printText
				end
			end
			names[object.Name] = true
			object = object.Parent
		end
		--构造消息传递函数
		if objectLeave:IsA("RemoteEvent") then
			printText = printText .. CreateRemoteEventFunction(objectLeave.Name)
		elseif objectLeave:IsA("BindableEvent") then
			if objectRoot:IsA("ReplicatedStorage") then
				printText = printText .. CreateBindableEventFunction("ClientMsg", objectLeave.Name)
			elseif objectRoot:IsA("ServerStorage") then
				printText = printText .. CreateBindableEventFunction("ServerMsg", objectLeave.Name)
			end
		end
		printTextAll = printTextAll .. printText
	end
	print("\n" .. printTextAll)
end)