Config = {}

-- Toggle features
Config.EnablePedPushing = true       -- Pushes nearby NPCs
Config.EnablePedRagdoll = true      -- Ragdolls NPCs
Config.EnableVehiclePushing = true  -- Pushes nearby vehicles
Config.EnablePlayerRagdoll = true   -- Ragdolls the player after launch
Config.EnableForceToPlayer = true   -- Launches player into the air
Config.EnableAnimation = true       -- Plays the fart animation

-- Effect settings
Config.ExplosionForce = 100.0       -- Force applied to entities
Config.EffectRadius = 15.0          -- Radius for affecting nearby entities
Config.PlayerLaunchForce = vector3(0.0, 0.0, 50.0) -- Force to launch the player
Config.RagdollTime = 5000           -- Time in milliseconds for player/NPC ragdoll
