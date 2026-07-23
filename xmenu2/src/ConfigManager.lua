-- [File: src/ConfigManager.lua]
local HttpService = game:GetService("HttpService")
local Theme = import("src/Theme.lua")
local Library = import("init.lua")

local ConfigManager = {}
ConfigManager.FolderPath = "xmenu2_configs"
ConfigManager.ValidConfigs = {}
ConfigManager.RefreshList = nil

function ConfigManager.SerializeValue(val)
    if type(val) == "table" and val.R and val.G and val.B then
        return { __type = "Color3", R = val.R, G = val.G, B = val.B }
    else
        return val
    end
end

function ConfigManager.DeserializeValue(val)
    if type(val) == "table" and val.__type == "Color3" then
        return Color3.new(val.R, val.G, val.B)
    else
        return val
    end
end

function ConfigManager.EnsureFolder()
    if not isfolder(ConfigManager.FolderPath) then
        makefolder(ConfigManager.FolderPath)
    end
end

function ConfigManager.NormalizeConfigName(name)
    if not name or name == "" then return name end
    return name:gsub("%.json$", "", 1):gsub("%.JSON$", "", 1)
end

function ConfigManager.GetFilePath(configName)
    configName = ConfigManager.NormalizeConfigName(configName)
    if not configName or configName == "" then return nil end
    return ConfigManager.FolderPath .. "/" .. configName .. ".json"
end

function ConfigManager.Exists(configName)
    local path = ConfigManager.GetFilePath(configName)
    return path and isfile(path)
end

function ConfigManager.IsValidConfigFile(filePath)
    local success, data = pcall(function()
        local raw = readfile(filePath)
        return HttpService:JSONDecode(raw)
    end)
    return success and data ~= nil
end

function ConfigManager.ScanFolder()
    ConfigManager.EnsureFolder()
    local files = listfiles(ConfigManager.FolderPath)
    local valid = {}
    for _, filePath in ipairs(files) do
        if filePath:lower():match("%.json$") then
            if ConfigManager.IsValidConfigFile(filePath) then
                local name = filePath:match("([^/\\]+)%.json$")
                if name then
                    table.insert(valid, name)
                end
            else
                warn("[Config] Повреждённый файл (пропущен):", filePath)
            end
        end
    end
    table.sort(valid)
    return valid
end

function ConfigManager.Save(configName, libraryObj)
    configName = ConfigManager.NormalizeConfigName(configName)
    if not configName or configName == "" then
        print("[Config] Ошибка: имя конфига не может быть пустым")
        return
    end

    ConfigManager.EnsureFolder()
    local path = ConfigManager.GetFilePath(configName)

    local function DoSave()
        local saveTable = {}
        for flagKey, flagData in pairs(Library.Flags) do
            saveTable[flagKey] = ConfigManager.SerializeValue(flagData.Value)
        end
        local json = HttpService:JSONEncode(saveTable)
        writefile(path, json)
        print("[Config] Сохранён:", configName)
        ConfigManager.ValidConfigs = ConfigManager.ScanFolder()
        if ConfigManager.RefreshList then ConfigManager.RefreshList() end
    end

    if isfile(path) then
        libraryObj:ShowConfirm(
            "Перезапись конфига",
            "Вы точно хотите сохранить изменения в уже существующий конфиг '" .. configName .. "'?",
            DoSave,
            function() print("[Config] Сохранение отменено") end
        )
    else
        DoSave()
    end
end

function ConfigManager.Load(configName, libraryObj)
    configName = ConfigManager.NormalizeConfigName(configName)
    if not configName or configName == "" then return end
    local path = ConfigManager.GetFilePath(configName)
    if isfile(path) then
        local success, data = pcall(function()
            local raw = readfile(path)
            return HttpService:JSONDecode(raw)
        end)
        if success and data then
            for flagKey, storedVal in pairs(data) do
                if Library.Flags[flagKey] and Library.Flags[flagKey].Set then
                    local value = ConfigManager.DeserializeValue(storedVal)
                    Library.Flags[flagKey].Set(value)
                end
            end
            print("[Config] Загружен:", configName)
        else
            warn("[Config] Ошибка загрузки файла:", configName)
        end
    else
        print("[Config] Файл не найден:", path)
    end
end

function ConfigManager.Delete(configName)
    configName = ConfigManager.NormalizeConfigName(configName)
    if not configName or configName == "" then return end
    local path = ConfigManager.GetFilePath(configName)
    if isfile(path) then
        delfile(path)
        print("[Config] Удалён:", configName)
        ConfigManager.ValidConfigs = ConfigManager.ScanFolder()
        if ConfigManager.RefreshList then ConfigManager.RefreshList() end
    else
        print("[Config] Файл не найден для удаления:", path)
    end
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
    saveBtn.LayoutOrder = 1
    saveBtn.Parent = container

    local saveCorner = Instance.new("UICorner")
    saveCorner.CornerRadius = Theme.ElementCorner
    saveCorner.Parent = saveBtn

    local listFrame = Instance.new("Frame")
    listFrame.Name = "ConfigListHolder"
    listFrame.Size = UDim2.new(1, 0, 0, 24)
    listFrame.BackgroundTransparency = 1
    listFrame.LayoutOrder = 2
    listFrame.Parent = container

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 4)
    listLayout.Parent = listFrame

    ConfigManager.RefreshList = function()
        for _, child in ipairs(listFrame:GetChildren()) do
            if not child:IsA("UIListLayout") then
                child:Destroy()
            end
        end

        local validNames = ConfigManager.ValidConfigs
        local fileCount = #validNames

        if fileCount == 0 then
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
            listFrame.Size = UDim2.new(1, 0, 0, fileCount * 34)
            for idx, displayName in ipairs(validNames) do
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
                nameLabel.Text = "📄 " .. displayName
                nameLabel.TextColor3 = Theme.TextColor
                nameLabel.Font = Enum.Font.SourceSans
                nameLabel.TextSize = 11
                nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
                nameLabel.Parent = card

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
                    ConfigManager.Load(displayName, libraryObj)
                end)

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
                    ConfigManager.Delete(displayName)
                end)
            end
        end
    end

    saveBtn.MouseButton1Click:Connect(function()
        if currentConfigName and currentConfigName ~= "" then
            ConfigManager.Save(currentConfigName, libraryObj)
        else
            print("[Config] Имя конфига не может быть пустым")
        end
    end)

    ConfigManager.ValidConfigs = ConfigManager.ScanFolder()
    ConfigManager.RefreshList()
end

return ConfigManager