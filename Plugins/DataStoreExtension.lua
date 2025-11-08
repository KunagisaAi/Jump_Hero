--!strict
local replicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local dataStoreService: DataStoreService = game:GetService("DataStoreService")
local players: Players = game:GetService("Players")
local httpService: HttpService = game:GetService("HttpService")
local studioService: StudioService = game:GetService("StudioService")
local studio: Studio = settings().Studio

local WidgetInfo: DockWidgetPluginGuiInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, true, false, 400, 600, 200, 300)

local textColor: Color3
local buttonColor: Color3
local buttonBorderColor: Color3
local inputFieldColor: Color3
local inputFieldBorderColor: Color3

local toolbar = plugin:CreateToolbar("游戏存档扩展") :: PluginToolbar
local dataStoreToolButton: PluginToolbarButton = toolbar:CreateButton("游戏存档工具", "", "rbxassetid://14978048121")
dataStoreToolButton.ClickableWhenViewportHidden = true
local dataStoreToolGui: DockWidgetPluginGui?

local function UpdateCurrentThemeColors()
	local currentTheme: StudioTheme = studio.Theme :: StudioTheme
	textColor = currentTheme:GetColor(Enum.StudioStyleGuideColor.MainText, Enum.StudioStyleGuideModifier.Default)
	buttonColor = currentTheme:GetColor(Enum.StudioStyleGuideColor.Button, Enum.StudioStyleGuideModifier.Default)
	buttonBorderColor = currentTheme:GetColor(Enum.StudioStyleGuideColor.ButtonBorder, Enum.StudioStyleGuideModifier.Default)
	inputFieldColor = currentTheme:GetColor(Enum.StudioStyleGuideColor.InputFieldBackground, Enum.StudioStyleGuideModifier.Default)
	inputFieldBorderColor = currentTheme:GetColor(Enum.StudioStyleGuideColor.InputFieldBorder, Enum.StudioStyleGuideModifier.Default)
end

local function UpdateGuiTheme(gui: DockWidgetPluginGui)
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

local function OnThemeChanged()
	UpdateCurrentThemeColors()
	if dataStoreToolGui ~= nil then
		UpdateGuiTheme(dataStoreToolGui)
	end
end


local function SafeGet(dataStore: DataStore, key: string): any
	return dataStore:GetAsync(key)
end

local function SafeSet(dataStore: DataStore, key: string, value: any): any
	local success: boolean, result: any = pcall(function() 
		dataStore:SetAsync(key, value)
	end)
	return result
end

local function SafeUpdate(dataStore, key: string, transformFunction: (currentValue: any) -> ()): any
	local success: boolean, result: any = pcall(function() 
		dataStore:UpdateAsync(key, transformFunction)
	end)
	return result
end

--部分重置奴隶交易存储信息
local function ResetSlaveTradeStoreInfo1(playerId: number, infoOld)
	local slaveTradeStoreInfoDataStore = dataStoreService:GetDataStore("SlaveTradeStoreInfo")
	infoOld.slaveIds = {}
	infoOld.slaveTotalValue = 0
	infoOld.tradeRecordPendings = {}
	SafeSet(slaveTradeStoreInfoDataStore, tostring(playerId), infoOld)
end

--保留两位小数后（防止浮点误差）向上取整
local function FormatNumber(n: number): number
	local n0 = tonumber(string.format("%.2f", n))
	if n0 then
		return math.ceil(n0)
	else
		return n
	end
end

local function FormatNumber1(n: number): number
	local n0 = tonumber(string.format("%.2f", n))
	if n0 then
		return math.floor(n0)
	else
		return n
	end
end

--检查指定玩家的世界身价排行榜数据库中是否为最新值，不是则更新
local function CheckPlayerValueInWorldValueSortedDataStore(playerId: number, valueNow: number)
	local valueSortedDataStore: OrderedDataStore = dataStoreService:GetOrderedDataStore("Value")
	SafeUpdate(valueSortedDataStore, tostring(playerId), function(currentInfo: number)
		--已更新
		if currentInfo == valueNow then
			return
		end
		currentInfo = valueNow
		return currentInfo
	end)
end

--重置玩家的部分奴隶交易信息
local function ResetSlaveTradeStoreInfo()
	--只有雪地生存需要重置
	if game.GameId ~= 6376748064 and game.GameId ~= 5969091473 then
		return
	end
	local playerInfoDataStore: DataStore = dataStoreService:GetDataStore("PlayerInfo")
	local slaveTradeStoreInfoDataStore = dataStoreService:GetDataStore("SlaveTradeStoreInfo")
	local playerIdA = studioService:GetUserId()
	local playerInfoA = SafeGet(playerInfoDataStore, tostring(playerIdA)) 
	local infoOldA = SafeGet(slaveTradeStoreInfoDataStore, tostring(playerIdA))
	local slaveIds = infoOldA.slaveIds
	--部分重置玩家A的信息
	ResetSlaveTradeStoreInfo1(playerIdA, infoOldA)
	print("已部分重置你的信息"..playerIdA)

	local nowTime = DateTime.now().UnixTimestamp
	--更新玩家A的所有奴隶B的信息（相当于玩家A把所有奴隶出售给系统）
	for _, slaveId in slaveIds do
		--确定购买时的奴隶身价
		local valueFirst = 0
		local tradeRecords = playerInfoA.slaveTradeInfo.tradeRecords
		for i = #tradeRecords, 1, -1 do
			if tradeRecords[i].slaveId == slaveId and not tradeRecords[i].isSale then
				valueFirst = math.abs(tradeRecords[i].coinChange)
				break
			end
		end
		--尝试更新奴隶B身价，所属奴隶主，被购买时间
		local slaveTradeStoreInfoOldB = SafeGet(slaveTradeStoreInfoDataStore, tostring(slaveId))
		SafeUpdate(slaveTradeStoreInfoDataStore, tostring(slaveId),
			function(currentInfo)
				--奴隶已被其他人买走
				if currentInfo.slaveOwnerId ~= playerIdA then
					return nil
				end
				if currentInfo.slaveOwnerUpdateTime ~= slaveTradeStoreInfoOldB.slaveOwnerUpdateTime then
					return nil
				end
				--print(currentInfo.value, currentInfo.value * (1 + GameConfig.SlaveValueAddPerBuy))
				if valueFirst ~= 0 then
					currentInfo.value = FormatNumber(valueFirst) --恢复身价
				end
				currentInfo.slaveLastOwnerId = currentInfo.slaveOwnerId
				currentInfo.slaveOwnerId = nil
				currentInfo.slaveOwnerUpdateTime = nowTime 
				return currentInfo
			end)
		print("已更新你之前拥有奴隶的信息"..slaveId)
		--更新世界身价排行榜
		CheckPlayerValueInWorldValueSortedDataStore(slaveId, FormatNumber(valueFirst))
	end

	----更新玩家A的奴隶主C的信息（相当于玩家A被出售给系统）
	--local oldSlaveOwnerId = infoOldA.slaveOwnerId
	--if oldSlaveOwnerId then
	--	local value: number = infoOldA.value
	--	local slaveValueLast = FormatNumber1(value/1.1) --A上一次身价
	--	local tradeRecordC = {
	--		isSale = true, --出售
	--		coinChange = FormatNumber(slaveValueLast * 1.05), --获得金币
	--		slaveOwnerId = nil, --新奴隶主Id
	--		slaveId = playerIdA, --奴隶Id
	--		tradeTime = nowTime, --交易时间
	--	}
	--	SafeUpdate(slaveTradeStoreInfoDataStore, tostring(oldSlaveOwnerId),
	--		function(currentInfo, dataStoreKeyInfo: DataStoreKeyInfo?)
	--			--校验currentInfo，是否可以购买
	--			local slaveIndex: number? = table.find(currentInfo.slaveIds, playerIdA)
	--			--奴隶已被他人买走
	--			if slaveIndex == nil then
	--				return nil
	--			end
	--			--其他校验
	--			--移除奴隶
	--			table.remove(currentInfo.slaveIds, slaveIndex)
	--			--添加待处理交易记录
	--			table.insert(currentInfo.tradeRecordPendings, tradeRecordC)
	--			return currentInfo
	--		end)
	--	print("已更新你奴隶主的信息"..oldSlaveOwnerId)
	--end
	print("奴隶信息部分重置完毕")
end


local function OnDataStoreToolButtonClick()
	if dataStoreToolGui ~= nil then
		dataStoreToolGui.Enabled = true
		return
	end

	local dockWidgetGui: DockWidgetPluginGui = plugin:CreateDockWidgetPluginGui("DataStoreTool", WidgetInfo)
	dockWidgetGui.Title = "游戏存档工具"

	--清除自己的游戏存档按钮
	local clearLocalPlayerDataStoreButton: TextButton = Instance.new("TextButton")
	clearLocalPlayerDataStoreButton.Position = UDim2.new(0, 10, 0, 20)
	clearLocalPlayerDataStoreButton.Size = UDim2.new(1, -20, 0, 20)
	clearLocalPlayerDataStoreButton.TextSize = 14
	clearLocalPlayerDataStoreButton.Text = "清除自己的游戏存档"
	clearLocalPlayerDataStoreButton.Parent = dockWidgetGui
	clearLocalPlayerDataStoreButton.Activated:Connect(function(inputObject: InputObject, clickCount: number) 
		ResetSlaveTradeStoreInfo()
		local playerInfoDataStore: DataStore = dataStoreService:GetDataStore("PlayerInfo")
		local success: boolean, result: any = pcall(function()
			playerInfoDataStore:RemoveAsync(tostring(studioService:GetUserId()))
		end)
		if success then
			print("清除数据成功")
		else
			error(result)
		end
	end)

	--清除多人测试游戏存档按钮
	local clearMultiplayerDataStoreButton: TextButton = Instance.new("TextButton")
	clearMultiplayerDataStoreButton.Position = UDim2.new(0, 10, 0, 50)
	clearMultiplayerDataStoreButton.Size = UDim2.new(1, -20, 0, 20)
	clearMultiplayerDataStoreButton.TextSize = 14
	clearMultiplayerDataStoreButton.Text = "清除多人测试游戏存档"
	clearMultiplayerDataStoreButton.Parent = dockWidgetGui
	clearMultiplayerDataStoreButton.Activated:Connect(function(inputObject: InputObject, clickCount: number) 
		local playerInfoDataStore: DataStore = dataStoreService:GetDataStore("PlayerInfo")
		local success: boolean, result: any = pcall(function()
			for playerId: number = -1, -8, -1 do
				playerInfoDataStore:RemoveAsync(tostring(playerId))
			end
		end)
		if success then
			print("清除数据成功")
		else
			error(result)
		end
	end)
	--打印自己的存档
	local printLocalPlayerDataStoreButton: TextButton = Instance.new("TextButton")
	printLocalPlayerDataStoreButton.Position = UDim2.new(0, 10, 0, 80)
	printLocalPlayerDataStoreButton.Size = UDim2.new(1, -20, 0, 20)
	printLocalPlayerDataStoreButton.TextSize = 14
	printLocalPlayerDataStoreButton.Text = "打印自己的存档"
	printLocalPlayerDataStoreButton.Parent = dockWidgetGui
	printLocalPlayerDataStoreButton.Activated:Connect(function(inputObject: InputObject, clickCount: number) 
		local playerInfoDataStore: DataStore = dataStoreService:GetDataStore("PlayerInfo")
		local success: boolean, result: any = pcall(function()
			return playerInfoDataStore:GetAsync(tostring(studioService:GetUserId()))
		end)
		if success then
			print("\n" .. httpService:JSONEncode(result) .. "\n")
		else
			print(result)
		end
	end)
	--从文件中读取存档
	local readDataStoreFromFileButton: TextButton = Instance.new("TextButton")
	readDataStoreFromFileButton.Position = UDim2.new(0, 10, 0, 110)
	readDataStoreFromFileButton.Size = UDim2.new(1, -20, 0, 20)
	readDataStoreFromFileButton.TextSize = 14
	readDataStoreFromFileButton.Text = "从文件中读取存档"
	readDataStoreFromFileButton.Parent = dockWidgetGui
	readDataStoreFromFileButton.Activated:Connect(function(inputObject: InputObject, clickCount: number)
		ResetSlaveTradeStoreInfo()
		local playerInfoDataStore: DataStore = dataStoreService:GetDataStore("PlayerInfo")
		local file: File = studioService:PromptImportFile() :: File
		local data = httpService:JSONDecode(file:GetBinaryContents())
		local success: boolean, result: any = pcall(function()
			playerInfoDataStore:SetAsync(tostring(studioService:GetUserId()), data)
		end)
		if success then
			print("读取存档成功")
		else
			error(result)
		end
	end)

	--玩家id输入框
	local userIdTitleText: TextLabel = Instance.new("TextLabel")
	userIdTitleText.BackgroundTransparency = 1
	userIdTitleText.Position = UDim2.new(0, 10, 0, 170)
	userIdTitleText.Size = UDim2.new(0.5, -20, 0, 20)
	userIdTitleText.TextSize = 14
	userIdTitleText.Text = "玩家UID"
	userIdTitleText.TextXAlignment = Enum.TextXAlignment.Left
	userIdTitleText.Parent = dockWidgetGui
	local userIdValueText: TextBox = Instance.new("TextBox")
	userIdValueText.Position = UDim2.new(0.5, 10, 0, 170)
	userIdValueText.Size = UDim2.new(0.5, -20, 0, 20)
	userIdValueText.TextSize = 14
	userIdValueText.Text = ""
	userIdValueText.TextXAlignment = Enum.TextXAlignment.Left
	userIdValueText.Parent = dockWidgetGui
	userIdValueText.ClearTextOnFocus = false

	--使用其他玩家ID的游戏存档按钮
	local useOtherPlayerDataStoreButton: TextButton = Instance.new("TextButton")
	useOtherPlayerDataStoreButton.Position = UDim2.new(0, 10, 0, 200)
	useOtherPlayerDataStoreButton.Size = UDim2.new(1, -20, 0, 20)
	useOtherPlayerDataStoreButton.TextSize = 14
	useOtherPlayerDataStoreButton.Text = "使用玩家存档（输入UID）"
	useOtherPlayerDataStoreButton.Parent = dockWidgetGui
	useOtherPlayerDataStoreButton.Activated:Connect(function(inputObject: InputObject, clickCount: number)
		ResetSlaveTradeStoreInfo()
		local playerInfoDataStore: DataStore = dataStoreService:GetDataStore("PlayerInfo")
		local success: boolean, result: any = pcall(function()
			local playerSaveInfo = playerInfoDataStore:GetAsync(userIdValueText.Text)
			if playerSaveInfo == nil then
				print("覆盖玩家 " .. userIdValueText.Text .. " 游戏存档失败，玩家游戏存档为空")
				return
			end
			playerInfoDataStore:SetAsync(tostring(studioService:GetUserId()), playerSaveInfo)
		end)
		if success then
			print("覆盖玩家 " .. userIdValueText.Text .. " 游戏存档成功")
		else
			error(result)
		end 
	end)
	
	--玩家用户名输入框
	local userIdTitleText: TextLabel = Instance.new("TextLabel")
	userIdTitleText.BackgroundTransparency = 1
	userIdTitleText.Position = UDim2.new(0, 10, 0, 230)
	userIdTitleText.Size = UDim2.new(0.5, -20, 0, 20)
	userIdTitleText.TextSize = 14
	userIdTitleText.Text = "玩家用户名"
	userIdTitleText.TextXAlignment = Enum.TextXAlignment.Left
	userIdTitleText.Parent = dockWidgetGui
	local userIdValueText: TextBox = Instance.new("TextBox")
	userIdValueText.Position = UDim2.new(0.5, 10, 0, 230)
	userIdValueText.Size = UDim2.new(0.5, -20, 0, 20)
	userIdValueText.TextSize = 14
	userIdValueText.Text = ""
	userIdValueText.TextXAlignment = Enum.TextXAlignment.Left
	userIdValueText.Parent = dockWidgetGui
	userIdValueText.ClearTextOnFocus = false
	
	--使用其他玩家用户名的游戏存档按钮
	local useOtherPlayerDataStoreButton: TextButton = Instance.new("TextButton")
	useOtherPlayerDataStoreButton.Position = UDim2.new(0, 10, 0, 260)
	useOtherPlayerDataStoreButton.Size = UDim2.new(1, -20, 0, 20)
	useOtherPlayerDataStoreButton.TextSize = 14
	useOtherPlayerDataStoreButton.Text = "使用玩家存档（输入用户名）"
	useOtherPlayerDataStoreButton.Parent = dockWidgetGui
	useOtherPlayerDataStoreButton.Activated:Connect(function(inputObject: InputObject, clickCount: number)
		ResetSlaveTradeStoreInfo()
		local playerInfoDataStore: DataStore = dataStoreService:GetDataStore("PlayerInfo")
		local success: boolean, result: any = pcall(function()
			-- 输入目标用户名
			local username = userIdValueText.Text
			-- 查找玩家的信息
			local success, userId = pcall(function()
				return players:GetUserIdFromNameAsync(username)
			end)
			if success then
				print("玩家UID为:", userId)
			else
				warn("获取玩家UID失败:", userId)
				return
			end
			local playerSaveInfo = playerInfoDataStore:GetAsync(tostring(userId))
			if playerSaveInfo == nil then
				print("覆盖玩家 " .. userIdValueText.Text .. " 游戏存档失败，玩家游戏存档为空")
				return
			end
			playerInfoDataStore:SetAsync(tostring(studioService:GetUserId()), playerSaveInfo)
		end)
		if success then
			print("覆盖玩家 " .. userIdValueText.Text .. " 游戏存档成功")
		else
			error(result)
		end 
	end)

	dataStoreToolGui = dockWidgetGui
	UpdateGuiTheme(dockWidgetGui)
end

UpdateCurrentThemeColors()

studio.ThemeChanged:Connect(OnThemeChanged)
dataStoreToolButton.Click:Connect(OnDataStoreToolButtonClick)