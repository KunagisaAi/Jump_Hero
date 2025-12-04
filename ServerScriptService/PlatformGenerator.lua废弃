local Workspace = game:GetService("Workspace")

-- 假设原有平台生成逻辑如下
-- function createPlatform(position, size, color)
--     local platform = Instance.new("Part")
--     platform.Position = position
--     platform.Size = size
--     platform.Color = color
--     platform.Anchored = true
--     platform.Parent = Workspace
--     return platform
-- end

-- 在平台中心生成标记
local function createCenterMark(platform)
    local mark = Instance.new("Part")
    mark.Shape = Enum.PartType.Ball
    mark.Size = Vector3.new(0.5, 0.5, 0.5)
    mark.Position = platform.Position
    mark.Anchored = true
    mark.CanCollide = false
    mark.Color = Color3.new(1, 0, 0) -- 红色标记
    mark.Material = Enum.Material.Neon
    mark.Name = "CenterMark"
    mark.Parent = platform
end

function createPlatform(position, size, color)
    local platform = Instance.new("Part")
    platform.Position = position
    platform.Size = size
    platform.Color = color
    platform.Anchored = true
    platform.Parent = Workspace
    -- 如果是金钱平台则添加中心标记
    if color == Color3.fromRGB(54, 165, 71) then
        createCenterMark(platform)
    end
    return platform
end

