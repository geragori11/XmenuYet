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

function ConfigManager.Save(configName, data)
    ConfigManager.EnsureFolder()
    local json = HttpService:JSONEncode(data)
    writefile(ConfigManager.FolderPath .. "/" .. configName .. ".json", json)
end

function ConfigManager.Load(configName)
    local path = ConfigManager.FolderPath .. "/" .. configName .. ".json"
    if isfile(path) then
        local raw = readfile(path)
        return HttpService:JSONDecode(raw)
    end
    return nil
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

function ConfigManager.RenderUI(container, getSaveDataCallback, onLoadDataCallback)
    local AddToggle = import("src/Elements/Toggle.lua")
    local AddTextInput = import("src/Elements/TextInput.lua")

    local currentConfigName = "default"

    -- 1. Поле ввода имени конфига
    AddTextInput(container, "Имя конфига...", function(txt)
        currentConfigName = txt
    end)

    -- 2. Кнопка "Сохранить конфиг"
    AddToggle(container, "Сохранить конфиг", false, function()
        if currentConfigName and currentConfigName ~= "" then
            local dataToSave = getSaveDataCallback and getSaveDataCallback() or {}
            ConfigManager.Save(currentConfigName, dataToSave)
            if ConfigManager.RefreshList then
                ConfigManager.RefreshList()
            end
        end
    end)

    -- 3. Контейнер списка конфигов с авто-высотой
    local listFrame = Instance.new("Frame")
    listFrame.Name = "ConfigListHolder"
    listFrame.Size = UDim2.new(1, 0, 0, 0)
    listFrame.AutomaticSize = Enum.AutomaticSize.Y
    listFrame.BackgroundTransparency = 1
    listFrame.LayoutOrder = #container:GetChildren()
    listFrame.Parent = container

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 4)
    listLayout.Parent = listFrame

    -- Функция обновления карточек конфигов
    ConfigManager.RefreshList = function()
        for _, child in ipairs(listFrame:GetChildren()) do
            if not child:IsA("UIListLayout") then
                child:Destroy()
            end
        end

        local files = ConfigManager.ListConfigs()
        for idx, filePath in ipairs(files) do
            local fileName = string.match(filePath, "([^/]+)%.json$") or filePath

            -- Карточка конфига
            local card = Instance.new("Frame")
            card.Name = "Card_" .. fileName
            card.Size = UDim2.new(1, 0, 0, 28)
            card.BackgroundColor3 = Theme.ElementBackground
            card.LayoutOrder = idx
            card.Parent = listFrame

            local cardCorner = Instance.new("UICorner")
            cardCorner.CornerRadius = Theme.ElementCorner
            cardCorner.Parent = card

            -- Кнопка "Загрузить" (нажатие на имя файла)
            local loadBtn = Instance.new("TextButton")
            loadBtn.Size = UDim2.new(0.68, -4, 1, 0)
            loadBtn.Position = UDim2.new(0, 4, 0, 0)
            loadBtn.BackgroundTransparency = 1
            loadBtn.Text = "📄 " .. fileName
            loadBtn.TextColor3 = Theme.TextColor
            loadBtn.Font = Enum.Font.SourceSans
            loadBtn.TextSize = 12
            loadBtn.TextXAlignment = Enum.TextXAlignment.Left
            loadBtn.Parent = card

            loadBtn.MouseButton1Click:Connect(function()
                local data = ConfigManager.Load(fileName)
                if data and onLoadDataCallback then
                    onLoadDataCallback(fileName, data)
                end
            end)

            -- Кнопка "Удалить"
            local delBtn = Instance.new("TextButton")
            delBtn.Size = UDim2.new(0.28, -4, 0.8, 0)
            delBtn.Position = UDim2.new(0.7, 0, 0.1, 0)
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

    ConfigManager.RefreshList()
end

return ConfigManager