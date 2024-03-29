# Structure - Module

```lua
--------------------------------------------------------------------------------------------------------------------------
MODULE.name = "Core - Permissions"
--------------------------------------------------------------------------------------------------------------------------
MODULE.author = "76561198312513285"
--------------------------------------------------------------------------------------------------------------------------
MODULE.discord = "@liliaplayer"
--------------------------------------------------------------------------------------------------------------------------
MODULE.desc = "Implements CAMI Based Permissions."
--------------------------------------------------------------------------------------------------------------------------
MODULE.identifier = "RestrictionCore"
--------------------------------------------------------------------------------------------------------------------------
MODULE.WorkshopContent = {"2959728255"}
-------------------------------------------f-------------------------------------------------------------------------------
MODULE.enabled = true
--------------------------------------------------------------------------------------------------------------------------
MODULE.CAMIPrivileges = {
    {
        Name = "Staff Permissions - One Punch Man",
        MinAccess = "superadmin",
        Description = "Allows access to OPM to Ragdoll Minges.",
    },
}
--------------------------------------------------------------------------------------------------------------------------
MODULE.Dependencies = {

    {
        File = MODULE.path .. "/permissinons.lua",
        Realm = "server",
    },
    {
        File = MODULE.path .. "/logs.lua",
        Realm = "server",
    },
}

--------------------------------------------------------------------------------------------------------------------------
```

---

## [View source »](https://github.com/LiliaFramework/Lilia/blob/main/lilia/modules/core/permissions/module.lua)

## Module Configuration

-   **`MODULE.name`:** Specifies the name of the module, which is "Core - Permissions" in this case. This variable identifies the module.

-   **`MODULE.author`:** Indicates the author of the module. It can be a STEAMID64 or Name. Replace "76561198312513285" with the actual author information.

-   **`MODULE.discord`:** Indicates the discord of the module creator, in this case, as shown, is liliaplayer.

-   **`MODULE.desc`:** Provides a brief description of the module's purpose. In this case, it states that the module adds skills functionality to the framework.

-   **`MODULE.CAMIPrivileges`:** An example CAMI permission that is loaded alongside the module.

-   **`MODULE.WorkshopContent`:** Workshop Content to be added.

-   **`MODULE.enabled`:** Indicates if the module is active or not. If False, then it won't be.

-   **`MODULE.Dependencies`:** Files and corresponding realms to be included.

### Automatically Included Files and Folders in the Module:

**Files:**

-   client.lua

-   cl_module.lua

-   sv_module.lua

-   server.lua

-   config.lua

-   sconfig.lua

**Folders:**

-   dependencies

-   config
-   permissions

-   libs

-   hooks

-   libraries

-   commands

-   netcalls

-   meta

-   derma

-   pim

-   concommands

