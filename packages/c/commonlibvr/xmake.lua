package("commonlibvr")
    set_homepage("https://github.com/alandtse/CommonLibVR")
    set_description("A reverse engineered library for Skyrim Special Edition.")
    set_license("MIT")

    -- The silly thing uses git@github.com SSH path for openvr, why...
    -- add_urls("https://github.com/alandtse/CommonLibVR.git")

    -- openvr 1.0.10
    -- https://github.com/ValveSoftware/openvr/releases/tag/v1.0.10

    add_deps("fmt", "rsm-binary-io", "vcpkg::boost-stl-interfaces")
    add_deps("spdlog", { configs = { header_only = false, fmt_external = true } })

    add_syslinks("version", "user32", "shell32", "ole32", "advapi32")

    on_load("windows|x64", function(package)
        package:add("defines", "SKYRIMVR", "_CRT_SECURE_NO_WARNINGS")
    end)

    on_install("windows|x64", function(package)
        -- local current_dir = os.curdir()
        --

        -- local workdir = path.join(os.tmpdir(), "commonlibvr_clone")

        -- Clone main repo manually.
        os.vrun("git clone https://github.com/alandtse/CommonLibVR.git")
        os.cd("CommonLibVR")
        -- os.vrun("git clone https://github.com/alandtse/CommonLibVR.git " .. workdir)

        -- Change directory to the workdir.
        -- os.cd(workdir)

        -- Replace SSH paths with HTTPS in .gitmodules if they exist.
        local gitmodules_path = ".gitmodules"
        if os.isfile(gitmodules_path) then
            local content = io.readfile(gitmodules_path)
            content = content:gsub("git@github.com:", "https://github.com/")
            io.writefile(gitmodules_path, content)
        end

        -- Update submodules with modified paths.
        -- Nahhhh... we'll use openvr from xmake instead
        -- os.vrun("git submodule sync")
        -- os.vrun("git submodule update --init --recursive")

        --
        -- os.cd(current_dir)
        os.cd("..")
        os.cp("CommonLibVR/*", ".")

        -- Evil. Let's make sure that SFTypes is included super early, so replace the #pragma one with the include
        local pch_path = "include/SKSE/Impl/PCH.h"
        local content = io.readfile(pch_path)
        content = content:gsub("#pragma once", "#pragma once\n\n// SFTypes first (cstddef for size_t/ptrdiff_t, limits for numeric_limits):\n#include <cstddef>\n#include <limits>\n#include \"RE/S/SFTypes.h\"\n")
        io.writefile(pch_path, content)

        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, {})

        -- Evil. Let's inject the 'SKSEPluginLoad' macro for compatibility with NG
        local skse_header_path = path.join(package:installdir(), "include/SKSE/SKSE.h")
        local content = io.readfile(skse_header_path)
        content = content .. "\n#define SKSEPluginLoad extern \"C\" __declspec(dllexport) bool SKSEPlugin_Load"
        io.writefile(skse_header_path, content)
    end)

    on_test("windows|x64", function(package)
        assert(package:check_cxxsnippets({test = [[
         void test_nothing() {}
        ]]}, { configs = { languages = "c++20" } }))
    end)
