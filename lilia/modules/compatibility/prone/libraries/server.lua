﻿---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function ProneModCompatibility:DoPlayerDeath(client)
    if client:IsProne() then prone.Exit(client) end
end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function ProneModCompatibility:PlayerLoadedChar(client)
    if client:IsProne() then prone.Exit(client) end
end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------