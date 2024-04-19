local mod = RegisterMod("He's a Phantom", 1)
local sfx = SFXManager()

local config = include("hap.mcm")
-- SFX --
local sfxPhantom = Isaac.GetSoundIdByName("macha_phantom")

mod.hasGoneGhost = {} -- Whether each player has gone ghost
mod.sfxStartDelay = 10 -- How delayed the sound should be
mod.defaultVolume = 8 -- The default volume for the sound
mod.sfxQueue = {} -- The queue of sfx to be played

---Check if the player has collided with a white fire
---@param npc EntityNPC The entity in question
---@param collider Entity The player
---@param low boolean Unused in this function
function mod:WhiteFireCollision(npc, collider, low)
    -- Get the player
    local player = collider:ToPlayer()
    -- Check if the colliding entity is the white fire, 
    -- and that the other entity is the player, 
    -- and that the player has not already gone ghost
    if npc.Type == EntityType.ENTITY_FIREPLACE and npc.Variant == 4 and player ~= nil and mod.hasGoneGhost[player.Index] == nil then
        -- Get the dead Isaac (For some reason it's a reskinned Devil statue)
        local devils = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.DEVIL)
        -- Loop through any Devils that are found
        for _, e in pairs(devils) do
            -- Check if the Devil is in the 'Death' animation
            if e:GetSprite():GetAnimation() == "Death" then
                -- The player has gone ghost 
                mod.hasGoneGhost[player.Index] = true
                -- Configure the volume
                local volumeMod = (config.settings.volume) / 5

                -- Play the sound
                mod.sfxQueue[1] = { Isaac.GetFrameCount() + mod.sfxStartDelay,
                    function() sfx:Play(sfxPhantom, mod.defaultVolume * volumeMod, 2, false, 0.97, 0) end }
            end
        end
    end
end

---Play queued sounds after a delay
function mod:PlaySFX()
    -- Get the current time, in frames
    local currentFrame = Isaac.GetFrameCount()
    -- Loop through the queue
    for i, s in pairs(mod.sfxQueue) do
        -- If the effect exists and the time to play it is here,
        if s ~= nil and currentFrame >= s[1] then
            -- Call the callback to play the sfx
            s[2]()
            -- Remove sfx from queue
            mod.sfxQueue[i] = nil
        end
    end
end

---Reset detection for going ghost, called every room
function mod:Reset()
    mod.hasGoneGhost = {}
end

mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.PlaySFX)
mod:AddCallback(ModCallbacks.MC_PRE_NEW_ROOM, mod.Reset)
mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, mod.WhiteFireCollision)