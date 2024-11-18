-- Load configuration
local Config = Config or {}
local isHolding = false
local hasPlayed = false -- Tracks if the effect has already played
local holdTime = 500 -- 1/2 second
local triangleKey = 23 -- INPUT_JUMP (Triangle on PlayStation controllers)

-- Trigger the fart effect: animation, sound, launch, and ragdoll
function playFartEffect()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    -- Play animation locally (if enabled)
    if Config.EnableAnimation then
        RequestAnimDict("misscarsteal2peeing")
        while not HasAnimDictLoaded("misscarsteal2peeing") do
            Wait(0)
        end
        TaskPlayAnim(playerPed, "misscarsteal2peeing", "peeing_idle", 8.0, -8.0, -1, 1, 0, false, false, false)
    end

    -- Notify server to trigger sound and shake effects for nearby players
    TriggerServerEvent("playFartEffectForRadius", coords)

    -- Apply upward force to the player (if enabled)
    if Config.EnableForceToPlayer then
        local upwardForce = Config.PlayerLaunchForce
        ApplyForceToEntity(playerPed, 1, upwardForce.x, upwardForce.y, upwardForce.z, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
    end

    -- Ragdoll the player (if enabled)
    if Config.EnablePlayerRagdoll then
        Wait(500)
        SetPedToRagdoll(playerPed, Config.RagdollTime, Config.RagdollTime, 0, true, true, false)
    end

    -- Push nearby vehicles and NPCs in separate threads
    if Config.EnableVehiclePushing then
        CreateThread(function()
            pushNearbyVehicles(coords)
        end)
    end

    if Config.EnablePedPushing then
        CreateThread(function()
            pushNearbyNPCs(coords)
        end)
    end
end

-- Push nearby vehicles with explosive force
function pushNearbyVehicles(playerCoords)
    local vehicles = GetGamePool('CVehicle') -- Get all vehicles in the game world

    for _, vehicle in ipairs(vehicles) do
        local vehicleCoords = GetEntityCoords(vehicle)
        local distance = #(vehicleCoords - playerCoords)

        if distance <= Config.EffectRadius then
            -- Apply force to the vehicle
            local direction = (vehicleCoords - playerCoords)
            local normalizedDirection = direction / #direction -- Normalize direction vector
            ApplyForceToEntity(vehicle, 1, 
                normalizedDirection.x * Config.ExplosionForce, 
                normalizedDirection.y * Config.ExplosionForce, 
                normalizedDirection.z * Config.ExplosionForce * 0.5, -- Add some upward force
                0.0, 0.0, 0.0, 0, true, true, true, false, true)

            -- Make the vehicle potentially explode on impact
            SetVehicleOutOfControl(vehicle, false, true) -- Makes the vehicle harder to stop
            SetVehicleEngineHealth(vehicle, -4000.0) -- Forces explosion if it collides
        end
    end
end

-- Push nearby NPCs with explosive force
function pushNearbyNPCs(playerCoords)
    local peds = GetGamePool('CPed') -- Get all NPCs in the game world

    for _, ped in ipairs(peds) do
        if not IsPedAPlayer(ped) then -- Ignore players
            local pedCoords = GetEntityCoords(ped)
            local distance = #(pedCoords - playerCoords)

            if distance <= Config.EffectRadius then
                -- Apply force to the ped
                local direction = (pedCoords - playerCoords)
                local normalizedDirection = direction / #direction -- Normalize direction vector
                ApplyForceToEntity(ped, 1, 
                    normalizedDirection.x * Config.ExplosionForce, 
                    normalizedDirection.y * Config.ExplosionForce, 
                    normalizedDirection.z * Config.ExplosionForce * 0.5, -- Add some upward force
                    0.0, 0.0, 0.0, 0, true, true, true, false, true)

                -- Ragdoll the ped (if enabled)
                if Config.EnablePedRagdoll then
                    SetPedToRagdoll(ped, Config.RagdollTime, Config.RagdollTime, 0, true, true, false)
                end
            end
        end
    end
end

-- Monitor for button hold
CreateThread(function()
    while true do
        local playerPed = PlayerPedId()

        -- Check if triangle is held
        if IsControlPressed(0, triangleKey) then
            if not isHolding and not hasPlayed then
                isHolding = true
                local startTime = GetGameTimer()

                -- Wait for hold duration
                while IsControlPressed(0, triangleKey) do
                    if GetGameTimer() - startTime >= holdTime then
                        playFartEffect() -- Trigger the fart effect
                        hasPlayed = true -- Mark that the effect has been played
                        break
                    end
                    Wait(0)
                end

                isHolding = false
            end
        else
            -- Reset state when the key is released
            isHolding = false
            hasPlayed = false -- Allow playing again on the next press
        end

        Wait(0)
    end
end)

-- Play fart sound and camera shake for the client
RegisterNetEvent("playFartSoundAndShake")
AddEventHandler("playFartSoundAndShake", function(sourceCoords, intensity)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local distance = #(playerCoords - sourceCoords)

    -- Adjust volume and shake intensity based on distance
    local volume = math.max(0.0, 1.0 - (distance / intensity.maxRadius))
    local shakeIntensity = math.max(0.0, intensity.maxShake * volume)

    -- Debugging to ensure the values are correct
    print(string.format("Fart Sound Triggered | Distance: %.2f | Volume: %.2f | Shake: %.2f", distance, volume, shakeIntensity))

    -- Play the sound (custom fart.ogg)
    if volume > 0.0 then -- Only play sound if volume is above zero
        SendNUIMessage({
            transactionType = "playSound",
            soundVolume = volume
        })
    end

    -- Apply camera shake
    if shakeIntensity > 0.0 then
        ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", shakeIntensity)
    end
end)
