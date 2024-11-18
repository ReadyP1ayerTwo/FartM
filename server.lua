local maxRadius = 20.0 -- Radius within which players will be affected
local maxShake = 0.4 -- Maximum camera shake intensity

RegisterNetEvent("playFartEffectForRadius")
AddEventHandler("playFartEffectForRadius", function(sourceCoords)
    local sourcePlayer = source
    local players = GetPlayers()

    for _, player in ipairs(players) do
        if player ~= sourcePlayer then
            local ped = GetPlayerPed(player)
            local pedCoords = GetEntityCoords(ped)

            -- Check if the player is within the radius
            local distance = #(sourceCoords - pedCoords)
            if distance <= maxRadius then
                TriggerClientEvent("playFartSoundAndShake", player, sourceCoords, {
                    maxRadius = maxRadius,
                    maxShake = maxShake
                })
            end
        end
    end
end)
