-- Usage:
--
-- add_rules("@commonlibvr/plugin", {
--     name = "Plugin name",
--     author = "Author name",
--     description = "Plugin description",
--     email = "user@site.com",
--     options = {
--         address_library = true,
--         signature_scanning = false
--     }
-- })

rule("plugin")
    add_deps("win.sdk.resource")

    on_config(function(target)
        import("core.base.semver")
        import("core.project.depend")
        import("core.project.project")

        target:add("defines", "SKYRIMVR", "BOOST_STL_INTERFACES_DISABLE_CONCEPTS")

        target:set("kind", "shared")
        target:set("arch", "x64")

        target:add("defines", "UNICODE", "_UNICODE")
        target:add("cxxflags", "/permissive-", "/Zc:alignedNew", "/Zc:__cplusplus", "/Zc:forScope", "/Zc:ternary")
        target:add("cxxflags", "cl::/Zc:externConstexpr", "cl::/Zc:hiddenFriend", "cl::/Zc:preprocessor", "cl::/Zc:referenceBinding")

        local version = semver.new(target:version() or "0.0.0")
        local configs = target:extraconf("rules", "@commonlibvr/plugin")
        local config_dir = path.join(target:autogendir(), "rules", "commonlibsse", "plugin")

        local version_file = path.join(config_dir, "version.rc")
        depend.on_changed(function()
            local file = io.open(version_file, "w")
            if file then
                file:print("#include <winres.h>\n")
                file:print("1 VERSIONINFO")
                file:print("FILEVERSION %s, %s, %s, 0", version:major(), version:minor(), version:patch())
                file:print("PRODUCTVERSION %s, %s, %s, 0", version:major(), version:minor(), version:patch())
                file:print("FILEFLAGSMASK 0x17L")
                file:print("#ifdef _DEBUG")
                file:print("    FILEFLAGS 0x1L")
                file:print("#else")
                file:print("    FILEFLAGS 0x0L")
                file:print("#endif")
                file:print("FILEOS 0x4L")
                file:print("FILETYPE 0x1L")
                file:print("FILESUBTYPE 0x0L")
                file:print("BEGIN")
                file:print("    BLOCK \"StringFileInfo\"")
                file:print("    BEGIN")
                file:print("        BLOCK \"040904b0\"")
                file:print("        BEGIN")
                file:print("            VALUE \"FileDescription\", \"%s\"", configs.description or "")
                file:print("            VALUE \"FileVersion\", \"%s.0\"", target:version() or "0.0.0")
                file:print("            VALUE \"InternalName\", \"%s\"", configs.name or target:name())
                file:print("            VALUE \"LegalCopyright\", \"%s, %s\"", configs.author or "", target:license() or "Unknown License")
                file:print("            VALUE \"ProductName\", \"%s\"", project.name() or "")
                file:print("            VALUE \"ProductVersion\", \"%s.0\"", project.version() or "0.0.0")
                file:print("        END")
                file:print("    END")
                file:print("    BLOCK \"VarFileInfo\"")
                file:print("    BEGIN")
                file:print("        VALUE \"Translation\", 0x409, 1200")
                file:print("    END")
                file:print("END")
                file:close()
            end
        end, { dependfile = target:dependfile(version_file), files = project.allfiles()})

        local plugin_file = path.join(config_dir, "plugin.cpp")
        depend.on_changed(function()
            local file = io.open(plugin_file, "w")
            if file then
                local struct_compat = "Independent"
                local runtime_compat = "AddressLibrary"

                if configs.options then
                    local address_library = configs.options.address_library or true
                    local signature_scanning = configs.options.signature_scanning or false
                    if not address_library and signature_scanning then
                        runtime_compat = "SignatureScanning"
                    end
                end

                -- file:print("#include <SKSE/SKSE.h>")
                -- file:print("#include <REL/Relocation.h>\n")
                -- file:print("using namespace std::literals;\n")
                -- file:print("SKSEPluginInfo(")
                -- file:print("    .Version = { %s, %s, %s, 0 },", version:major(), version:minor(), version:patch())
                -- file:print("    .Name = \"%s\"sv,", configs.name or target:name())
                -- file:print("    .Author = \"%s\"sv,", configs.author or "")
                -- file:print("    .SupportEmail = \"%s\"sv,", configs.email or "")
                -- file:print("    .StructCompatibility = SKSE::StructCompatibility::%s,", struct_compat)
                -- file:print("    .RuntimeCompatibility = SKSE::VersionIndependence::%s", runtime_compat)
                -- file:print(")")

                file:print("#pragma once")
                file:print("")
                file:print("#include <SKSE/SKSE.h>")
                file:print("#include <REL/Relocation.h>\n")
                file:print("")
                file:print("#include <string_view>")

                file:print("")

                file:print("namespace Plugin")
                file:print("{")
                file:print("	using namespace std::literals;")
                file:print("")
                file:print("	inline constexpr REL::Version VERSION")
                file:print("	{")
                file:print("		// clang-format off")
                file:print("		" .. version:major() .. "u,")
                file:print("		" .. version:minor() .. "u,")
                file:print("		" .. version:patch() .. "u,")
                file:print("		// clang-format on")
                file:print("	};")
                file:print("")
                file:print("	inline constexpr auto NAME = \"" .. target:name() .. "\"sv;")
                file:print("}")

                file:print("")

                file:print("extern \"C\" __declspec(dllexport) constinit auto SKSEPlugin_Version = []() {")
                file:print("    SKSE::PluginVersionData v;")
                file:print("    v.PluginVersion(Plugin::VERSION);")
                file:print("    v.PluginName(Plugin::NAME);")
                file:print("    v.UsesAddressLibrary();")
                file:print("    v.UsesUpdatedStructs();")
                file:print("    // v.CompatibleVersions({SKSE::RUNTIME_1_6_659});")
                file:print("    // v.HasNoStructUse(true);")
                file:print("    return v;")
                file:print("}();")
                
                file:print("")

                file:print("extern \"C\" __declspec(dllexport) bool SKSEAPI")
                file:print("    SKSEPlugin_Query(const SKSE::QueryInterface* a_skse, SKSE::PluginInfo* a_info) {")
                file:print("    a_info->infoVersion = SKSE::PluginInfo::kVersion;")
                file:print("    a_info->name = Plugin::NAME.data();")
                file:print("    a_info->version = Plugin::VERSION.pack();")
                file:print("    if (a_skse->IsEditor()) return false;")
                file:print("    return true;")
                file:print("}")

                file:print("")

                file:close()
            end
        end, { dependfile = target:dependfile(plugin_file), files = project.allfiles()})

        target:add("files", version_file)
        target:add("files", plugin_file)
    end)
