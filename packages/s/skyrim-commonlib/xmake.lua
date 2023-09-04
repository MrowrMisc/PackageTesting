package("skyrim-commonlib")
    set_homepage("https://github.com/SkyrimScripting/Packages")
    set_description("CommonLib is a reverse engineered library for Skyrim (AE/SE/VR)")
    set_license("MIT")

    add_configs("ae", {description = "Include support for Skyrim Anniversary Edition", default = false, type = "boolean"})
    add_configs("se", {description = "Include support for Skyrim Special Edition", default = false, type = "boolean"})
    add_configs("vr", {description = "Include support for Skyrim VR", default = false, type = "boolean"})
    add_configs("ng", {description = "Include CommonLibSSE-NG (Next Generation)", default = false, type = "boolean"})
    add_configs("all", {description = "Include support for all Skyrim versions (AE/SE/VR) and NG", default = false, type = "boolean"})

    on_load(function (package)
        if package:config("all") then
            package:add("deps", "skyrim-commonlib-ae", "skyrim-commonlib-se", "skyrim-commonlib-vr", "skyrim-commonlib-ng")
        else
            local any = false
            if package:config("ae") then
                package:add("deps", "skyrim-commonlib-ae")
                os.setenv("DEPENDS_ON_SKYRIM_COMMONLIB_AE", "true")
                any = true
            end
            if package:config("se") then
                package:add("deps", "skyrim-commonlib-se")
                os.setenv("DEPENDS_ON_SKYRIM_COMMONLIB_SE", "true")
                any = true
            end
            if package:config("vr") then
                package:add("deps", "skyrim-commonlib-vr")
                os.setenv("DEPENDS_ON_SKYRIM_COMMONLIB_VR", "true")
                any = true
            end
            if package:config("ng") then
                package:add("deps", "skyrim-commonlib-ng")
                os.setenv("DEPENDS_ON_SKYRIM_COMMONLIB_NG", "true")
                any = true
            end
            if not any then
                -- If none are selected, use NG by default
                package:add("deps", "skyrim-commonlib-ng")
                os.setenv("DEPENDS_ON_SKYRIM_COMMONLIB_NG", "true")
            end
        end
    end)
