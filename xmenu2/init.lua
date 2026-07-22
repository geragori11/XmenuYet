-- [File: init.lua]
local Library = {}
Library.__index = Library

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

Library.Theme = import("src/Theme.lua")
Library.Draggable = import("src/Draggable.lua")
Library.ConfigManager = import("src/ConfigManager.lua")

function Library.new(title)
    local self = setmetatable({}, Library)

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = title or "XClientMenu"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui

    self.ScreenGui = screenGui
    self.Columns = {}

    -- БИНД ПО УМОЛЧАНИЮ: Клавиша K
    self.ToggleKey = Enum.KeyCode.K
    self.ColumnWidth = 180
    self.ColumnHeight = 400

    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == self.ToggleKey then
            self.ScreenGui.Enabled = not self.ScreenGui.Enabled
        end
    end)

    return self
end

local function calculateOverlapRatio(frameA, frameB)
    local posA, sizeA = frameA.AbsolutePosition, frameA.AbsoluteSize
    local posB, sizeB = frameB.AbsolutePosition, frameB.AbsoluteSize

    local xOverlap = math.max(0, math.min(posA.X + sizeA.X, posB.X + sizeB.X) - math.max(posA.X, posB.X))
    local yOverlap = math.max(0, math.min(posA.Y + sizeA.Y, posB.Y + sizeB.Y) - math.max(posA.Y, posB.Y))

    local overlapArea = xOverlap * yOverlap
    local areaA = sizeA.X * sizeA.Y

    if areaA == 0 then return 0 end
    return overlapArea / areaA
end

function Library:FindFreePosition(column)
    for index = 0, 10 do
        local testPos = UDim2.new(0, 20 + index * (self.ColumnWidth + 10), 0, 50)
        local isOccupied = false

        for _, col in ipairs(self.Columns) do
            if col.Frame ~= column.Frame then
                local dist = (Vector2.new(col.Frame.Position.X.Offset, col.Frame.Position.Y.Offset) -
                              Vector2.new(testPos.X.Offset, testPos.Y.Offset)).Magnitude
                if dist < (self.ColumnWidth * 0.8) then
                    isOccupied = true
                    break
                end
            end
        end

        if not isOccupied then
            return testPos
        end
    end
    return UDim2.new(0, 20, 0, 50)
end

function Library:AddColumn(title)
    local columnFrame = Instance.new("Frame")
    columnFrame.Name = title .. "Column"
    columnFrame.Size = UDim2.new(0, self.ColumnWidth, 0, self.ColumnHeight)

    local initialPos = UDim2.new(0, 20 + (#self.Columns * (self.ColumnWidth + 10)), 0, 50)
    columnFrame.Position = initialPos
    columnFrame.BackgroundColor3 = Library.Theme.ColumnBackground
    columnFrame.BorderSizePixel = 0
    columnFrame.Parent = self.ScreenGui

    local colCorner = Instance.new("UICorner")
    colCorner.CornerRadius = Library.Theme.ColumnCorner
    colCorner.Parent = columnFrame

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 32)
    header.BackgroundColor3 = Library.Theme.HeaderBackground
    header.BorderSizePixel = 0
    header.Parent = columnFrame

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = Library.Theme.ColumnCorner
    headerCorner.Parent = header

    local headerText = Instance.new("TextLabel")
    headerText.Size = UDim2.new(1, 0, 1, 0)
    headerText.BackgroundTransparency = 1
    headerText.Text = title:upper()
    headerText.TextColor3 = Library.Theme.TextColor
    headerText.Font = Enum.Font.SourceSansBold
    headerText.TextSize = 14
    headerText.Parent = header

    local container = Instance.new("ScrollingFrame")
    container.Name = "Container"
    container.Size = UDim2.new(1, -8, 1, -40)
    container.Position = UDim2.new(0, 4, 0, 36)
    container.BackgroundTransparency = 1
    container.ScrollBarThickness = 3
    container.AutomaticCanvasSize = Enum.AutomaticSize.Y
    container.CanvasSize = UDim2.new(0, 0, 0, 0)
    container.Parent = columnFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 6)
    listLayout.Parent = container

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 2)
    padding.PaddingBottom = UDim.new(0, 6)
    padding.Parent = container

    local colObj = {
        Frame = columnFrame,
        Container = container,
        LastValidPos = initialPos,
        Library = self
    }

    Library.Draggable.Enable(columnFrame, header, function(draggedFrame)
        local isOverlapping = false

        for _, col in ipairs(self.Columns) do
            if col.Frame ~= draggedFrame then
                local overlap = calculateOverlapRatio(draggedFrame, col.Frame)
                if overlap >= 0.80 then
                    isOverlapping = true
                    break
                end
            end
        end

        local targetPos = colObj.LastValidPos

        if isOverlapping then
            local lastPosOccupied = false
            for _, col in ipairs(self.Columns) do
                if col.Frame ~= draggedFrame then
                    local dist = (Vector2.new(col.Frame.Position.X.Offset, col.Frame.Position.Y.Offset) -
                                  Vector2.new(colObj.LastValidPos.X.Offset, colObj.LastValidPos.Y.Offset)).Magnitude
                    if dist < (self.ColumnWidth * 0.8) then
                        lastPosOccupied = true
                        break
                    end
                end
            end

            if lastPosOccupied then
                targetPos = self:FindFreePosition(colObj)
            end

            TweenService:Create(draggedFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = targetPos
            }):Play()
        else
            colObj.LastValidPos = draggedFrame.Position
        end
    end)

    table.insert(self.Columns, colObj)
    return colObj
end

function Library:SetColumnSize(width, height)
    self.ColumnWidth = width
    self.ColumnHeight = height
    for _, col in ipairs(self.Columns) do
        col.Frame.Size = UDim2.new(0, width, 0, height)
    end
end

return Library