-- [File: modules/Combat/Killaura.lua]
local AddSlider = import("src/Elements/Slider.lua")
local AddColorPicker = import("src/Elements/ColorPicker.lua")

return {
    Page = "Combat",
    Section = "Misc",
    Name = "Killaura",
    Default = false,

    OnToggle = function(state)
        print("[Killaura] Состояние:", state)
    end,

    Settings = function(container)
        AddSlider(
            container,
            "Радиус атаки",
            5,
            50,
            15,
            function(v)
                print("[Killaura] Радиус:", v)
            end,
            "Killaura_Radius"
        )

        AddColorPicker(
            container,
            "Цвет таргета",
            Color3.fromRGB(255, 0, 0),
            function(color)
                print("[Killaura] Цвет установлен:", color)
            end,
            "Killaura_TargetColor"
        )

        AddColorPicker(
            container,
            "Цвет круга атаки",
            Color3.fromRGB(0, 150, 255),
            function(color)
                print("[Killaura] Цвет круга:", color)
            end,
            "Killaura_CircleColor"
        )
    end
}