﻿ITEM.name = "Vehicles Simphys Base"
ITEM.model = ""
ITEM.desc = ""
ITEM.category = "Vehicles"
ITEM.vehicleid = ""
ITEM.functions.Place = {
    onRun = function(itemTable)
        local client = itemTable.player
        local data = {}
        data.start = client:GetShootPos()
        data.endpos = data.start + client:GetAimVector() * 96
        data.filter = client
        simfphys.SpawnVehicleSimple(itemTable.vehicleid, Vector(data.endpos), Angle(1, 1, 1))
    end
}
