-- [File: register.lua]
local Library = import("init.lua")

local Register = {}

function Register.newmodule(path)
    local module = import("modules/" .. path .. ".lua")
    if not module then
        warn("[Register] Модуль не найден:", path)
        return
    end
    if not module.Page or not module.Name then
        warn("[Register] Модуль должен содержать Page и Name:", path)
        return
    end
    if Library.ActiveUI then
        Library.ActiveUI:AddModule(module)
    else
        warn("[Register] UI не создан")
    end
end

return Register