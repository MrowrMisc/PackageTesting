package("skyrim-commonlib")
    set_homepage("https://github.com/SkyrimScripting/Packages")
    set_description("CommonLib is a reverse engineered library for Skyrim (AE/SE/VR)")
    set_license("MIT")

    option("ae")
        set_default(false)
        set_description("Include support for Skyrim Anniversary Edition")

    option("se")
        set_default(false)
        set_description("Include support for Skyrim Special Edition")

    option("vr")
        set_default(false)
        set_description("Include support for Skyrim VR")

    option("ng")
        set_default(false)
        set_description("Include CommonLibSSE-NG (Next Generation)")

    option("all")
        set_default(false)
        set_description("Include support for all Skyrim versions (AE/SE/VR) and NG")

    on_load(function (package)
        if package:config("all") then
            package:add("deps", "skyrim-commonlib-ae", "skyrim-commonlib-se", "skyrim-commonlib-vr", "skyrim-commonlib-ng")
        else
            local any = false
            if package:config("ae") then
                package:add("deps", "skyrim-commonlib-ae")
                set_config("depends_on_skyrim_commonlib_ae", true)
                any = true
            end
            if package:config("se") then
                package:add("deps", "skyrim-commonlib-se")
                set_config("depends_on_skyrim_commonlib_se", true)
                any = true
            end
            if package:config("vr") then
                package:add("deps", "skyrim-commonlib-vr")
                set_config("depends_on_skyrim_commonlib_vr", true)
                any = true
            end
            if package:config("ng") then
                package:add("deps", "skyrim-commonlib-ng")
                set_config("depends_on_skyrim_commonlib_ng", true)
                any = true
            end
            if not any then
                -- If none are selected, use NG by default
                package:add("deps", "skyrim-commonlib-ng")
                set_config("depends_on_skyrim_commonlib_ng", true)
            end
        end
    end)
