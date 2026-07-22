-- init.lua
local Library = {}
Library.__index = Library

local CoreGui = game:GetService("CoreGui")

-- Подгрузка локальных модулей через import()
Library.Theme = import("src/Theme.lua")
Library.Draggable = import("src/Draggable.lua")
Library.ConfigManager = import("src/ConfigManager.lua")

function Library.new(title)
    local self = setmetatable({}, Library)

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = title or "DropdownMenu"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui

    self.ScreenGui = screenGui
    self.Columns = {}
    return self
end

function Library:AddColumn(title)
    local columnFrame = Instance.new("Frame")
    columnFrame.Name = title .. "Column"
    columnFrame.Size = UDim2.new(0, 180, 0, 400)
    columnFrame.Position = UDim2.new(0, 20 + (#self.Columns * 190), 0, 50)
    columnFrame.BackgroundColor3 = Library.Theme.ColumnBackground
    columnFrame.BorderSizePixel = 0
    columnFrame.Parent = self.ScreenGui

    local header = Instance.new("TextLabel")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundColor3 = Library.Theme.HeaderBackground
    header.Text = title:upper()
    header.TextColor3 = Library.Theme.TextColor
    header.Font = Enum.Font.SourceSansBold
    header.TextSize = 14
    header.Parent = columnFrame

    local container = Instance.new("ScrollingFrame")
    container.Name = "Container"
    container.Size = UDim2.new(1, 0, 1, -30)
    container.Position = UDim2.new(0, 0, 0, 30)
    container.BackgroundTransparency = 1
    container.ScrollBarThickness = 2
    container.Parent = columnFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 4)
    listLayout.Parent = container

    Library.Draggable.Enable(columnFrame, header)

    local colObj = {
        Frame = columnFrame,
        Container = container,
        Library = self
    }

    table.insert(self.Columns, colObj)
    return colObj
end

return Library