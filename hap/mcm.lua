local json = require("json")

local mod = RegisterMod("He's a Phantom MCM", 1)

mod.name = "He's a Phantom"
mod.settings = {
    volume = 5
}

---Load saved config data
function mod:Load()
    if not mod:HasData() then
        return
    end

    local jsonString = mod:LoadData()
    mod.settings = json.decode(jsonString)
end

---Save config data
function mod:Save()
    local jsonString = json.encode(mod.settings)
    mod:SaveData(jsonString)
end

---Configure the mod menu
function mod:ConfigMenuInit()
    if ModConfigMenu == nil then
        return
    end

    -- Reset if reloading
    ModConfigMenu.RemoveCategory(mod.name)

    -- Load data
    mod:Load()

    -- Main Category
    ModConfigMenu.UpdateCategory(
        mod.name,
        {
            Info = {
                "Settings for the mod that he is, in fact, a phantom",
                "This is truly a Mattman moment"
            }
        }
    )

    -- Setting for sfx volume
    ModConfigMenu.AddSetting(
        mod.name,
        nil,
        {
            Type = ModConfigMenu.OptionType.SCROLL,
            CurrentSetting = function()
                return mod.settings.volume
            end,
            Display = function()
                return "Volume: $scroll" .. mod.settings.volume
            end,
            OnChange = function (n)
                mod.settings.volume = n
                mod:Save()
            end,
            Info = {
                "Volume the sound will play at"
            }
        }
    )
end

-- Init the config menu
mod:ConfigMenuInit()

return mod