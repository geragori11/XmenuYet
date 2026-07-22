-- [File: src/ConfigManager.lua]
local HttpService = game:GetService("HttpService")
local Theme = import("src/Theme.lua")

local ConfigManager = {}
ConfigManager.FolderPath = "xmenu2_configs"

function ConfigManager.EnsureFolder()
    if not isfolder(ConfigManager.FolderPath) then
        makefolder(ConfigManager.FolderPath)
    end
end

function ConfigManager.Save(configName, libraryObj)
    ConfigManager.EnsureFolder()
    local path = ConfigManager.FolderPath .. "/" .. configName .. ".json"

    local function DoSave()
        local saveTable = {}
        for flagKey, flagData in pairs(libraryObj.Flags) do
            saveTable[flagKey] = flagData.Value
        end
        local json = HttpService:JSONEncode(saveTable)
        writefile(path, json)
        print("[Config] Успешно сохранён:", configName)
        if ConfigManager.RefreshList then ConfigManager.RefreshList() end
    end

    -- Проверка на существование файла для вызова подтверждения
    if isfile(path) then
        libraryObj:ShowConfirm(
            "Перезапись конфига",
            "Вы точно хотите сохранить изменения в уже существующий конфиг '" .. configName .. "'?",
            function() DoSave() end,
            function() print("[Config] Сохранение отменено пользователем") end
        )
    else
        DoSave()
    end
end

function ConfigManager.Load(configName, libraryObj)
    local path = ConfigManager.FolderPath .. "/" .. configName .. ".json"
    if isfile(path) then
        local raw = readfile(path)
        local data = HttpService:JSONDecode(raw)

        if data then
            for flagKey, storedVal in pairs(data) do
                if libraryObj.Flags[flagKey] and libraryObj.Flags[flagKey].Set then
                    libraryObj.Flags[flagKey].Set(storedVal)
                end
            end
            print("[Config] Успешно загружен:", configName)
        end
    end
end

function ConfigManager.Delete(configName)
    local path = ConfigManager.FolderPath .. "/" .. configName .. ".json"
    if isfile(path) then
        delfile(path)
    end
end

function ConfigManager.ListConfigs()
    ConfigManager.EnsureFolder()
    return listfiles(ConfigManager.FolderPath)
end

function ConfigManager.RenderUI(container, libraryObj)
    local AddTextInput = import("src/Elements/TextInput.lua")
    local currentConfigName = "default"

    AddTextInput(container, "Имя конфига...", function(txt)
        currentConfigName = txt
    end)

    local saveBtn = Instance.new("TextButton")
    saveBtn.Name = "SaveConfigButton"
    saveBtn.Size = UDim2.new(1, 0, 0, 26)
    saveBtn.BackgroundColor3 = Theme.ElementBackground
    saveBtn.Text = "💾  Сохранить конфиг"
    saveBtn.TextColor3 = Theme.AccentColor
    saveBtn.Font = Enum.Font.SourceSansBold
    saveBtn.TextSize = 12
    saveBtn.LayoutOrder = #container:GetChildren()
    saveBtn.Parent = container

    local saveCorner = Instance.new("UICorner")
    saveCorner.CornerRadius = Theme.ElementCorner
    saveCorner.Parent = saveBtn

    local listFrame = Instance.new("Frame")
    listFrame.Name = "ConfigListHolder"
    listFrame.Size = UDim2.new(1, 0, 0, 24)
    listFrame.BackgroundTransparency = 1
    listFrame.LayoutOrder = #container:GetChildren()
    listFrame.Parent = container

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 4)
    listLayout.Parent = listFrame

    ConfigManager.RefreshList = function()
        for _, child in ipairs(listFrame:GetChildren()) do
            if not child:IsA("UIListLayout") then child:Destroy() end
        end

        local files = ConfigManager.ListConfigs()

        if #files == 0 then
            listFrame.Size = UDim2.new(1, 0, 0, 24)
            local emptyLabel = Instance.new("TextLabel")
            emptyLabel.Size = UDim2.new(1, 0, 1, 0)
            emptyLabel.BackgroundTransparency = 1
            emptyLabel.Text = "Нет сохранённых конфигов"
            emptyLabel.TextColor3 = Theme.SubTextColor
            emptyLabel.Font = Enum.Font.SourceSansItalic
            emptyLabel.TextSize = 11
            emptyLabel.Parent = listFrame
        else
            listFrame.Size = UDim2.new(1, 0, 0, #files * 34)

            for idx, filePath in ipairs(files) do
                local fileName = string.match(filePath, "([^/]+)%.json$") or filePath

                local card = Instance.new("Frame")
                card.Size = UDim2.new(1, 0, 0, 30)
                card.BackgroundColor3 = Theme.ElementBackground
                card.LayoutOrder = idx
                card.Parent = listFrame

                local cardCorner = Instance.new("UICorner")
                cardCorner.CornerRadius = Theme.ElementCorner
                cardCorner.Parent = card

                local nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.new(0.38, -4, 1, 0)
                nameLabel.Position = UDim2.new(0, 4, 0, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = "📄 " .. fileName
                nameLabel.TextColor3 = Theme.TextColor
                nameLabel.Font = Enum.Font.SourceSans
                nameLabel.TextSize = 11
                nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
                nameLabel.Parent = card

                -- Кнопка "Загрузить"
                local loadBtn = Instance.new("TextButton")
                loadBtn.Size = UDim2.new(0.32, 0, 0.8, 0)
                loadBtn.Position = UDim2.new(0.39, 0, 0.1, 0)
                loadBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 70)
                loadBtn.Text = "Загрузить"
                loadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                loadBtn.Font = Enum.Font.SourceSansBold
                loadBtn.TextSize = 10
                loadBtn.Parent = card

                local loadCorner = Instance.new("UICorner")
                loadCorner.CornerRadius = UDim.new(0, 4)
                loadCorner.Parent = loadBtn

                loadBtn.MouseButton1Click:Connect(function()
                    ConfigManager.Load(fileName, libraryObj)
                end)

                -- Кнопка "Удалить"
                local delBtn = Instance.new("TextButton")
                delBtn.Size = UDim2.new(0.25, 0, 0.8, 0)
                delBtn.Position = UDim2.new(0.72, 0, 0.1, 0)
                delBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
                delBtn.Text = "Удалить"
                delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                delBtn.Font = Enum.Font.SourceSansBold
                delBtn.TextSize = 10
                delBtn.Parent = card

                local delCorner = Instance.new("UICorner")
                delCorner.CornerRadius = UDim.new(0, 4)
                delCorner.Parent = delBtn

                delBtn.MouseButton1Click:Connect(function()
                    ConfigManager.Delete(fileName)
                    ConfigManager.RefreshList()
                end)
            end
        end
    end

    saveBtn.MouseButton1Click:Connect(function()
        if currentConfigName and currentConfigName ~= "" then
            ConfigManager.Save(currentConfigName, libraryObj)
        end
    end)

    ConfigManager.RefreshList()
end

return ConfigManager