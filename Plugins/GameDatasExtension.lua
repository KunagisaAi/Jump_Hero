--!strict
local replicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local studioService: StudioService = game:GetService("StudioService")
local httpService: HttpService = game:GetService("HttpService")
local scriptEditorService: ScriptEditorService = game:GetService("ScriptEditorService")

local function TableToLuaCode(luaTable, indentLevel)
	local result = "{\n"
	local indent = string.rep("\t", indentLevel)
	local nextIndent = string.rep("\t", indentLevel + 1)
	for key, value in luaTable do
		local keyStr
		local keyType: string = typeof(key)
		if keyType == "string" then
			keyStr = string.format('["%s"]', key)
		elseif keyType == "number" then
			keyStr = string.format("[%d]", key)
		else
			continue
		end
		local valueStr
		local valueType: string = typeof(value)
		if valueType == "string" then
			value = string.gsub(value, "\"", "\\\"")
			value = string.gsub(value, "\n", "\\n")
			valueStr = string.format('"%s"', value)
		elseif valueType == "number" then
			valueStr = tostring(value)
		elseif valueType == "boolean" then
			valueStr = tostring(value)
		elseif valueType == "table" then
			valueStr = TableToLuaCode(value, indentLevel + 1)
		else
			continue
		end
		result = result .. string.format("%s%s = %s,\n", nextIndent, keyStr, valueStr)
	end
	result = result .. indent .. "}"
	return result
end

local function OnReadJsonDatasButtonClick()
	local success: boolean, result: any = pcall(function() 
		local scripts = replicatedStorage:FindFirstChild("Scripts")
		local sharedScripts = scripts:FindFirstChild("Shared")
		local gameConfigScript: ModuleScript = sharedScripts:FindFirstChild("GameConfig") :: ModuleScript
		local files: {Instance} = studioService:PromptImportFiles({"json"})
		if files ~= nil then
			for fileIndex: number, file: Instance in files do
				if not file:IsA("File") then
					continue
				end
				local dataFileName: string = string.gsub(file.Name, ".json", "")
				local dataScript: ModuleScript = gameConfigScript:FindFirstChild(dataFileName) :: ModuleScript
				if dataScript == nil then
					dataScript = Instance.new("ModuleScript")
					dataScript.Name = dataFileName
					dataScript.Parent = gameConfigScript
				end
				scriptEditorService:UpdateSourceAsync(dataScript, function(oldContent)
					local jsonContent: string = file:GetBinaryContents()
					local dataTable: any = httpService:JSONDecode(jsonContent)
					return "return " .. TableToLuaCode(dataTable, 0)
				end)
			end
		end
	end)
	if success then
		print("读取Json数据成功")
	else
		error(result)
	end
end

local toolbar = plugin:CreateToolbar("游戏数据扩展") :: PluginToolbar
local readJsonDatasButton: PluginToolbarButton = toolbar:CreateButton("读取Json数据", "", "rbxassetid://14978048121")
readJsonDatasButton.ClickableWhenViewportHidden = true
readJsonDatasButton.Click:Connect(OnReadJsonDatasButtonClick)