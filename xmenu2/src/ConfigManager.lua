-- [File 4/10] src/ConfigManager.lua
local HttpService = game:GetService("HttpService")

local ConfigManager = {}
ConfigManager.FolderPath = "DropdownMenuConfigs"

function ConfigManager.Save(configName, data)
    if not isfolder(ConfigManager.FolderPath) then
        makefolder(ConfigManager.FolderPath)
    end
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

function ConfigManager.ListConfigs()
    if not isfolder(ConfigManager.FolderPath) then
        return {}
    end
    return listfiles(ConfigManager.FolderPath)
end

return ConfigManager