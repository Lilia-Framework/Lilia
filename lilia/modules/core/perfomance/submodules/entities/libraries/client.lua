﻿---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function EntityPerfomance:PostGamemodeLoaded()
    scripted_ents.GetStored("base_gmodentity").t.Think = nil
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function EntityPerfomance:GrabEarAnimation()
    return nil
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function EntityPerfomance:MouthMoveAnimation()
    return nil
end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------