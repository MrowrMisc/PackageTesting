package("commonlibsse-po3")
    set_homepage("https://github.com/powerof3/CommonLibSSE")
    set_description("A reverse engineered library for Skyrim Special Edition.")
    set_license("MIT")

    add_urls("https://github.com/powerof3/CommonLibSSE/archive/$(version).zip",
             "https://github.com/powerof3/CommonLibSSE.git")

    add_deps("fmt", "rsm-binary-io", "vcpkg::boost-stl-interfaces")
    add_deps("spdlog", { configs = { header_only = false, fmt_external = true } })

    add_syslinks("version", "user32", "shell32", "ole32", "advapi32")

    on_load("windows|x64", function(package)
        package:add("defines", "SKYRIM_SUPPORT_AE=1")
    end)

    on_install("windows|x64", function(package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, {})

        -- Evil. Let's inject the 'SKSEPluginLoad' macro for compatibility with NG
        local skse_header_path = path.join(package:installdir(), "include/SKSE/SKSE.h")
        local content = io.readfile(skse_header_path)
        content = content .. "\n#define SKSEPluginLoad extern \"C\" __declspec(dllexport) bool"
        io.writefile(skse_header_path, content)
    end)

    on_test("windows|x64", function(package)
        assert(package:check_cxxsnippets({test = [[
         void test_nothing() {}
        ]]}, { configs = { languages = "c++20" } }))
    end)
