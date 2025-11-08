--!strict
local replicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local studioService: StudioService = game:GetService("StudioService")

type SourceGameText = {
	key: string,
	source: string,
}

local function parseCSVLine(line): {string}
	local result: {string} = {}
	local pos: number = 1
	local len: number = #line
	while pos <= len do
		if string.sub(line, pos, pos) == '"' then
			--处理带引号的字段
			local c: string = ""
			local startPos: number = pos + 1
			repeat
				local nextQuote = string.find(line, '"', startPos)
				if nextQuote == nil then
					error("CSV 行中带引号的字段未闭合: " .. line)
				end
				c = string.sub(line, nextQuote + 1, nextQuote + 1)
				if c == '"' then
					startPos = nextQuote + 2 -- 引号内的双引号
				else
					table.insert(result, string.sub(line, pos, nextQuote))
					pos = nextQuote + 1
					break
				end
			until false
		else
			--处理不带引号的字段
			local nextComma: number? = string.find(line, ',', pos)
			if nextComma == nil then
				table.insert(result, string.sub(line, pos))
				break
			else
				table.insert(result, string.sub(line, pos, nextComma - 1))
				pos = nextComma + 1
			end
		end
	end
	return result
end

local function isCompleteCSVLine(line)
	local quoteCount = 0
	for i = 1, #line do
		if line:sub(i, i) == '"' then
			quoteCount += 1
		end
	end
	return quoteCount % 2 == 0
end

local function parseCSV(content: string): ({string}, {{[string]: string}})
	local result: {{[string]: string}} = {}
	local rows = {}

	--组合多行成完整记录（处理字段中真实换行）
	local lines: {string} = string.split(content, "\n")
	local buffer: string = ""
	for _, line: string in ipairs(lines) do
		if buffer ~= "" then
			buffer ..= "\n" .. line
		else
			buffer = line
		end
		if isCompleteCSVLine(buffer) then
			table.insert(rows, buffer)
			buffer = ""
		end
	end
	if buffer ~= "" then
		error("CSV 最后一条记录引号未闭合: " .. buffer)
	end
	--解析
	local headers: {string} = parseCSVLine(rows[1])
	for i: number = 2, #rows do
		local row = parseCSVLine(rows[i])
		if #row > 0 then
			local entry: {[string]: string} = {}
			for j: number = 1, #headers do
				entry[headers[j]] = row[j]
			end
			table.insert(result, entry)
		end
	end
	--提取语言代码
	local languageCodes: {string} = {}
	for i: number = 5, #headers do
		table.insert(languageCodes, headers[i])
	end
	return languageCodes, result
end

local function AddSourceGameText(source: string, key:string, sourceGameTexts: {SourceGameText})
	for sourceGameTextIndex: number, sourceGameText: SourceGameText in sourceGameTexts do
		if key == "" then
			if sourceGameText.key == "" and sourceGameText.source == source then
				return
			end
		else
			if sourceGameText.key == key then
				return
			end
		end
	end
	local sourceGameText: SourceGameText = {
		key = key,
		source = source
	}
	table.insert(sourceGameTexts, sourceGameText)
end

local function CaptureDataTableGameTexts(dataTable, sourceGameTexts: {SourceGameText})
	for key, value in dataTable do
		local keyType: string = typeof(key)
		local valueType: string = typeof(value)
		if valueType == "table" then
			if string.sub(key, -2) == "_t" then
				local textKey = value["key"]
				local textSource = value["source"]
				if textKey ~= nil and textSource ~= nil and typeof(textKey) == "string" and typeof(textSource) == "string" then
					AddSourceGameText(textSource, textKey, sourceGameTexts)
				else
					CaptureDataTableGameTexts(value, sourceGameTexts)
				end
			else
				CaptureDataTableGameTexts(value, sourceGameTexts)
			end
		elseif string.sub(key, -2) == "_t" and valueType == "string" and value ~= "" and keyType == "string" then
			AddSourceGameText(value, "", sourceGameTexts)
		end
	end
end

local function CaptureSourceGameTexts(): {SourceGameText}
	local sourceGameTexts: {SourceGameText} = {}
	--抓取UI文本
	local models = replicatedStorage:FindFirstChild("Models")
	local uiOrigins = replicatedStorage:FindFirstChild("UI")
	local uiParents: {Instance} = {workspace, models, uiOrigins}
	for uiParentIndex: number, uiParent: Instance in uiParents do
		for descendantIndex: number, descendant: Instance in uiParent:GetDescendants() do
			if descendant:IsA("TextLabel") then
				if descendant.AutoLocalize and descendant.Text ~= "" then
					AddSourceGameText(descendant.Text, "", sourceGameTexts)
				end
			elseif descendant:IsA("TextButton") then
				if descendant.AutoLocalize and descendant.Text ~= "" then
					AddSourceGameText(descendant.Text, "", sourceGameTexts)
				end
			elseif descendant:IsA("TextBox") then
				if descendant.AutoLocalize and descendant.PlaceholderText ~= "" then
					AddSourceGameText(descendant.PlaceholderText, "", sourceGameTexts)
				end
			elseif descendant:IsA("ProximityPrompt") then
				if descendant.AutoLocalize then
					if descendant.ObjectText ~= nil then
						AddSourceGameText(descendant.ObjectText, "", sourceGameTexts)
					end
					if descendant.ActionText ~= nil then
						AddSourceGameText(descendant.ActionText, "", sourceGameTexts)
					end
				end
			end
		end
	end
	--抓取脚本中的文本
	local scripts = replicatedStorage:FindFirstChild("Scripts")
	local sharedScripts = scripts:FindFirstChild("Shared")
	--抓取GameTexts脚本中的文本
	local gameTextsScript: ModuleScript = sharedScripts:FindFirstChild("GameTexts") :: ModuleScript
	local getGameTextsFunction = loadstring(gameTextsScript.Source)
	if getGameTextsFunction ~= nil then
		local GameTexts = getGameTextsFunction()
		for key: string, keySource: {key: string, source: string} in GameTexts do
			AddSourceGameText(keySource.source, keySource.key, sourceGameTexts)
		end
	end
	--抓取静态数据中的文本
	local gameConfigScript: ModuleScript = sharedScripts:FindFirstChild("GameConfig") :: ModuleScript
	for childIndex: number, child: Instance in gameConfigScript:GetChildren() do
		if not child:IsA("ModuleScript") then
			continue
		end
		local dataFunction = loadstring(child.Source)
		if dataFunction ~= nil then
			local data = dataFunction()
			CaptureDataTableGameTexts(data, sourceGameTexts)
		end
	end
	return sourceGameTexts
end

local function OnCaptureNewGameTextsButtonClick()
	local file: File = studioService:PromptImportFile({"csv"}) :: File
	if file ~= nil then
		local sourceGameTexts: {SourceGameText} = CaptureSourceGameTexts()
		local jsonContent: string = file:GetBinaryContents():gsub("^\239\187\191", "")
		local langueCodes:{string}, csvContent: {{[string]: string}} = parseCSV(jsonContent)
		local newSourceGameTexts: {SourceGameText} = {}
		for sourceGameTextIndex: number, sourceGameText: SourceGameText in sourceGameTexts do
			sourceGameText.source = sourceGameText.source:gsub("\"", "\"\"")
			if sourceGameText.source:find(",") ~= nil or sourceGameText.source:find("\"") ~= nil or sourceGameText.source:find("\n") ~= nil then
				sourceGameText.source = "\"" .. sourceGameText.source .. "\""
			end
			local isNew: boolean = true
			for lineIndex: number, lineContent: {[string]: string} in csvContent do
				local lineContentKey: string? = lineContent["Key"]
				local lineContentSource: string? = lineContent["Source"]
				if (lineContentKey ~= nil and lineContentKey ~= "" and lineContentKey == sourceGameText.key)
					or lineContentSource == sourceGameText.source then
					isNew = false
					break
				end
			end
			if isNew then
				table.insert(newSourceGameTexts, sourceGameText)
			end
		end
		if #newSourceGameTexts == 0 then
			print("抓取完成，无新增文本")
		else
			local newGameTextsContent: string = "抓取完成，新增文本:\n"
			for newSourceGameTextIndex: number, newSourceGameText: SourceGameText in newSourceGameTexts do
				newGameTextsContent = newGameTextsContent .. newSourceGameText.key .. ",,," .. newSourceGameText.source
				for i: number = 1, #langueCodes do
					newGameTextsContent = newGameTextsContent .. ","
				end
				newGameTextsContent = newGameTextsContent .. "\n"
			end
			print(newGameTextsContent)
		end
	end
end

local function OnFindUselessGameTextsButtonClick()
	local file: File = studioService:PromptImportFile({"csv"}) :: File
	if file ~= nil then
		local sourceGameTexts: {SourceGameText} = CaptureSourceGameTexts()
		local jsonContent: string = file:GetBinaryContents():gsub("^\239\187\191", "")
		local langueCodes:{string}, csvContent: {{[string]: string}} = parseCSV(jsonContent)
		local usefulSourceGameTexts: {SourceGameText} = {}
		for sourceGameTextIndex: number, sourceGameText: SourceGameText in sourceGameTexts do
			sourceGameText.source = sourceGameText.source:gsub("\"", "\"\"")
			if sourceGameText.source:find(",") ~= nil or sourceGameText.source:find("\"") ~= nil or sourceGameText.source:find("\n") ~= nil then
				sourceGameText.source = "\"" .. sourceGameText.source .. "\""
			end
			table.insert(usefulSourceGameTexts, sourceGameText)
		end
		local uselessSourceGameTexts: {SourceGameText} = {}
		for lineIndex: number, lineContent: {[string]: string} in csvContent do
			local isUseful: boolean = false
			local lineContentKey: string? =  lineContent["Key"]
			local lineContentSource: string = lineContent["Source"]
			for _, usefulSourceGameText: SourceGameText in usefulSourceGameTexts do
				if (lineContentKey ~= nil and lineContentKey ~= "" and lineContentKey == usefulSourceGameText.key)
					or lineContentSource == usefulSourceGameText.source then
					isUseful = true
					break
				end
			end
			if not isUseful then
				local uselessSourceGameText: SourceGameText = {
					key = lineContentKey or "",
					source = lineContentSource,
				}
				table.insert(uselessSourceGameTexts, uselessSourceGameText)
			end
		end
		if #uselessSourceGameTexts == 0 then
			print("未查找到无用文本")
		else
			print("查找到无用文本：", uselessSourceGameTexts)
		end
	end
end

local toolbar = plugin:CreateToolbar("本地化扩展") :: PluginToolbar
local captureNewGameTextsButton: PluginToolbarButton = toolbar:CreateButton("抓取新翻译文本", "", "rbxassetid://14978048121")
captureNewGameTextsButton.ClickableWhenViewportHidden = true
captureNewGameTextsButton.Click:Connect(OnCaptureNewGameTextsButtonClick)
local findUselessGameTextsButton: PluginToolbarButton = toolbar:CreateButton("查找未使用的文本", "", "rbxassetid://14978048121")
findUselessGameTextsButton.ClickableWhenViewportHidden = true
findUselessGameTextsButton.Click:Connect(OnFindUselessGameTextsButtonClick)