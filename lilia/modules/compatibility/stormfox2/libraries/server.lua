﻿function MODULE:ModuleLoaded()
    timer.Simple(2, function()
        StormFox2.Setting.Set("time_speed", 1)
        StormFox2.Setting.Set("day_length", 720)
        StormFox2.Setting.Set("night_length", 720)
    end)
end
