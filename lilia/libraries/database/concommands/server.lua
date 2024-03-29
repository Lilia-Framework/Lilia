﻿local resetCalled = 0
concommand.Add("lia_recreatedb", function(client)
    if not IsValid(client) then
        if resetCalled < RealTime() then
            resetCalled = RealTime() + 3
            MsgC(Color(255, 0, 0), "[Lilia] TO CONFIRM DATABASE RESET, RUN 'lia_recreatedb' AGAIN in 3 SECONDS.\n")
        else
            resetCalled = 0
            MsgC(Color(255, 0, 0), "[Lilia] DATABASE WIPE IN PROGRESS.\n")
            hook.Run("OnWipeTables")
            lia.db.wipeTables(lia.db.loadTables)
        end
    end
end)
