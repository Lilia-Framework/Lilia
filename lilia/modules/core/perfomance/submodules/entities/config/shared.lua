﻿---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
--[[ Draw shadows for entities  ]]
EntityPerfomance.DrawEntityShadows = true
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
--[[ Time between Garbage Cleaning ]]
EntityPerfomance.GarbageCleaningTimer = 60
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
--[[ Time between Ragdolling Cleaning ]]
EntityPerfomance.RagdollCleaningTimer = 300
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
--[[ Entities that heavily impact performance ]]
EntityPerfomance.Perfomancekillers = {"class C_PhysPropClientside", "class C_ClientRagdoll"}
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
EntityPerfomance.SoundsToMute = {
    "weapons/airboat/airboat_gun_lastshot1.wav", -- ToolGun Sound
    "weapons/airboat/airboat_gun_lastshot2.wav",
}

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
EntityPerfomance.UnOptimizableModels = {"models/props_office/computer_monitor01.mdl", "models/props_office/computer_monitor02.mdl", "models/props_office/computer_monitor03.mdl", "models/props_office/computer_monitor04.mdl"}
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------