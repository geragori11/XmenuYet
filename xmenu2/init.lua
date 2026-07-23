-- [File: init.lua]
local Library = {}
Library.__index = Library

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

Library.Theme = import("src/Theme.lua")
Library.Draggable = import("src/Draggable.lua")
Library.ConfigManager = import("src/ConfigManager.lua")

Library.Flags = {}
Library.ActiveUI = nil
Library.Modules = {}

function Library.new(title)
    local self = setmetatable({}, Library)

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = title or "XClientMenu"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui

    self.ScreenGui = screenGui
    self.Columns = {}
    self.ToggleKey = Enum.KeyCode.K
    self.DefaultWidth = 190
    self.ColumnHeight = 420
    self.Modules = {}
    self.ColorPickerOverlay = nil

    Library.ActiveUI = self

    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == self.ToggleKey then
            self.ScreenGui.Enabled = not self.ScreenGui.Enabled
        end
    end)

    return self
end

function Library:RegisterFlag(flagName, initialValue, setCallback)
    Library.Flags[flagName] = {
        Value = initialValue,
        Set = setCallback
    }
end

function Library:ShowConfirm(title, message, onYes, onNo)
    local overlay = Instance.new("Frame")
    overlay.Name = "ConfirmOverlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.5
    overlay.ZIndex = 100
    overlay.Parent = self.ScreenGui

    local modal = Instance.new("Frame")
    modal.Size = UDim2.new(0, 260, 0, 130)
    modal.Position = UDim2.new(0.5, -130, 0.5, -65)
    modal.BackgroundColor3 = Library.Theme.ColumnBackground
    modal.ZIndex = 101
    modal.Parent = overlay

    local modalCorner = Instance.new("UICorner")
    modalCorner.CornerRadius = Library.Theme.ColumnCorner
    modalCorner.Parent = modal

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -16, 0, 25)
    titleLbl.Position = UDim2.new(0, 8, 0, 8)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Library.Theme.TextColor
    titleLbl.Font = Enum.Font.SourceSansBold
    titleLbl.TextSize = 13
    titleLbl.ZIndex = 102
    titleLbl.Parent = modal

    local descLbl = Instance.new("TextLabel")
    descLbl.Size = UDim2.new(1, -16, 0, 40)
    descLbl.Position = UDim2.new(0, 8, 0, 35)
    descLbl.BackgroundTransparency = 1
    descLbl.Text = message
    descLbl.TextColor3 = Library.Theme.SubTextColor
    descLbl.Font = Enum.Font.SourceSans
    descLbl.TextSize = 11
    descLbl.TextWrapped = true
    descLbl.ZIndex = 102
    descLbl.Parent = modal

    local yesBtn = Instance.new("TextButton")
    yesBtn.Size = UDim2.new(0.43, 0, 0, 28)
    yesBtn.Position = UDim2.new(0.05, 0, 1, -36)
    yesBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 70)
    yesBtn.Text = "Да"
    yesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    yesBtn.Font = Enum.Font.SourceSansBold
    yesBtn.TextSize = 12
    yesBtn.ZIndex = 102
    yesBtn.Parent = modal

    local yesCorner = Instance.new("UICorner")
    yesCorner.CornerRadius = Library.Theme.ElementCorner
    yesCorner.Parent = yesBtn

    local noBtn = Instance.new("TextButton")
    noBtn.Size = UDim2.new(0.43, 0, 0, 28)
    noBtn.Position = UDim2.new(0.52, 0, 1, -36)
    noBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    noBtn.Text = "Нет"
    noBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    noBtn.Font = Enum.Font.SourceSansBold
    noBtn.TextSize = 12
    noBtn.ZIndex = 102
    noBtn.Parent = modal

    local noCorner = Instance.new("UICorner")
    noCorner.CornerRadius = Library.Theme.ElementCorner
    noCorner.Parent = noBtn

    yesBtn.MouseButton1Click:Connect(function()
        overlay:Destroy()
        if onYes then onYes() end
    end)

    noBtn.MouseButton1Click:Connect(function()
        overlay:Destroy()
        if onNo then onNo() end
    end)
end

function Library:IsOverlappingMoreThan(frame1, frame2, threshold)
    local absPos1 = frame1.AbsolutePosition
    local absSize1 = frame1.AbsoluteSize
    local absPos2 = frame2.AbsolutePosition
    local absSize2 = frame2.AbsoluteSize

    local left = math.max(absPos1.X, absPos2.X)
    local right = math.min(absPos1.X + absSize1.X, absPos2.X + absSize2.X)
    local top = math.max(absPos1.Y, absPos2.Y)
    local bottom = math.min(absPos1.Y + absSize1.Y, absPos2.Y + absSize2.Y)

    if right > left and bottom > top then
        local overlapArea = (right - left) * (bottom - top)
        local area1 = absSize1.X * absSize1.Y
        if area1 > 0 and overlapArea / area1 > threshold then
            return true
        end
    end
    return false
end

function Library:AddColumn(title, customWidth)
    local width = customWidth or self.DefaultWidth

    local columnFrame = Instance.new("Frame")
    columnFrame.Name = title .. "Column"
    columnFrame.Size = UDim2.new(0, width, 0, self.ColumnHeight)

    local lastCol = self.Columns[#self.Columns]
    local xOffset = 20
    if lastCol then
        local lastPos = lastCol.Frame.Position
        xOffset = lastPos.X.Offset + width + 10
    end
    local initialPos = UDim2.new(0, xOffset, 0, 50)
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

    local sysLayout = Instance.new("UIListLayout")
    sysLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sysLayout.Padding = UDim.new(0, 6)
    sysLayout.Parent = container

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 2)
    padding.PaddingBottom = UDim.new(0, 6)
    padding.Parent = container

    local modulesContainer = Instance.new("Frame")
    modulesContainer.Name = "ModulesContainer"
    modulesContainer.Size = UDim2.new(1, 0, 0, 0)
    modulesContainer.AutomaticSize = Enum.AutomaticSize.Y
    modulesContainer.BackgroundTransparency = 1
    modulesContainer.LayoutOrder = 1
    modulesContainer.Parent = container

    local modulesLayout = Instance.new("UIListLayout")
    modulesLayout.SortOrder = Enum.SortOrder.LayoutOrder
    modulesLayout.Padding = UDim.new(0, 6)
    modulesLayout.Parent = modulesContainer

    local colObj = {
        Title = title,
        Frame = columnFrame,
        Container = container,
        ModulesContainer = modulesContainer,
        InitialPos = initialPos,
        Library = self
    }

    Library.Draggable.Enable(columnFrame, header, function(frame, startPos)
        local overlap = false
        for _, otherCol in ipairs(self.Columns) do
            if otherCol.Frame ~= frame then
                if self:IsOverlappingMoreThan(frame, otherCol.Frame, 0.8) then
                    overlap = true
                    break
                end
            end
        end

        if overlap then
            frame.Position = startPos
        else
            colObj.InitialPos = frame.Position
        end
    end)

    table.insert(self.Columns, colObj)
    return colObj
end

function Library:GetColumn(title)
    if not self or not self.Columns then return nil end
    for _, col in ipairs(self.Columns) do
        if col.Title:lower() == title:lower() then
            return col
        end
    end
    return nil
end

function Library:AddModule(module)
    if not module or not module.Name or not module.Page then
        warn("[Library] Модуль должен содержать поля Name и Page")
        return
    end
    table.insert(self.Modules, module)
end

function Library:RenderModules()
    local grouped = {}
    for _, mod in ipairs(self.Modules) do
        local page = mod.Page
        if not grouped[page] then
            grouped[page] = {}
        end
        local section = mod.Section or "Общие"
        if not grouped[page][section] then
            grouped[page][section] = {}
        end
        table.insert(grouped[page][section], mod)
    end

    for _, col in ipairs(self.Columns) do
        local modulesContainer = col.ModulesContainer
        for _, child in ipairs(modulesContainer:GetChildren()) do
            if not child:IsA("UIListLayout") then
                child:Destroy()
            end
        end

        local pageModules = grouped[col.Title]
        if pageModules then
            local sectionNames = {}
            for sec, _ in pairs(pageModules) do
                table.insert(sectionNames, sec)
            end
            table.sort(sectionNames)

            local layoutOrder = 0
            for _, secName in ipairs(sectionNames) do
                local mods = pageModules[secName]
                if #mods > 0 then
                    local header = Instance.new("TextLabel")
                    header.Name = "Section_" .. secName
                    header.Size = UDim2.new(1, 0, 0, 20)
                    header.BackgroundTransparency = 1
                    header.Text = secName:upper()
                    header.TextColor3 = Library.Theme.SectionHeader
                    header.Font = Enum.Font.SourceSansBold
                    header.TextSize = 12
                    header.TextXAlignment = Enum.TextXAlignment.Left
                    header.LayoutOrder = layoutOrder
                    layoutOrder = layoutOrder + 1
                    header.Parent = modulesContainer

                    local AddToggle = import("src/Elements/Toggle.lua")
                    for _, mod in ipairs(mods) do
                        local flagName = "Module_" .. mod.Name .. "_" .. tostring(math.random(100000))
                        local toggleObj = AddToggle(
                            modulesContainer,
                            mod.Name,
                            mod.Default or false,
                            flagName,
                            function(state)
                                if mod.OnToggle then
                                    mod.OnToggle(state)
                                end
                            end
                        )
                        toggleObj.main.LayoutOrder = layoutOrder
                        layoutOrder = layoutOrder + 1

                        if mod.Settings then
                            mod.Settings(toggleObj.settings)
                        end
                    end
                end
            end
        end
    end
end

return Library