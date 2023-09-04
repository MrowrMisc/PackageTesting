rule("plugin")

    add_deps("win.sdk.resource")

    on_config(function(target)
        import("core.base.semver")
        import("core.project.depend")
        import("core.project.project")

        target:add("defines",
            "BOOST_STL_INTERFACES_DISABLE_CONCEPTS",
            "UNICODE", "_UNICODE"
        )

        target:set("kind", "shared")
        target:set("arch", "x64")

        local configs = target:extraconf("rules", "@skyrim-commonlib-se/plugin")

        local version = semver.new(configs.version or target:version() or "0.0.0")
        local version_string = string.format("%s.%s.%s", version:major(), version:minor(), version:patch())

        local product_version = semver.new(configs.product_version or project.version() or configs.version or target:version() or "0.0.0")
        local product_version_string = string.format("%s.%s.%s", product_version:major(), product_version:minor(), product_version:patch())

        local output_files_folder = path.join(target:autogendir(), "rules", "skyrim-commonlib-se", "plugin")

        local version_file = path.join(output_files_folder, "version.rc")
        depend.on_changed(function()
            local file = io.open(version_file, "w")
            if file then
                file:print("#include <winres.h>\n")
                file:print("1 VERSIONINFO")
                file:print("FILEVERSION %s, %s, %s, 0", version:major(), version:minor(), version:patch())
                file:print("PRODUCTVERSION %s, %s, %s, 0", product_version:major(), product_version:minor(), product_version:patch())
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
                file:print("            VALUE \"FileVersion\", \"%s.0\"", version_string)
                file:print("            VALUE \"InternalName\", \"%s\"", configs.name or target:name())
                file:print("            VALUE \"LegalCopyright\", \"%s, %s\"", configs.author or "", configs.license or target:license() or "Unknown License")
                file:print("            VALUE \"ProductName\", \"%s\"", configs.product_name or project.name() or configs.name or target:name())
                file:print("            VALUE \"ProductVersion\", \"%s.0\"", product_version_string)
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

        local plugin_file = path.join(output_files_folder, "plugin.cpp")
        depend.on_changed(function()
            local file = io.open(plugin_file, "w")
            if file then
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

        target:add("cxxflags", "/permissive-", "/Zc:alignedNew", "/Zc:__cplusplus", "/Zc:forScope", "/Zc:ternary")
        target:add("cxxflags", "cl::/Zc:externConstexpr", "cl::/Zc:hiddenFriend", "cl::/Zc:preprocessor", "cl::/Zc:referenceBinding")
    end)

    after_build(function(target)
        local configs = target:extraconf("rules", "@skyrim-commonlib-se/plugin")

        local output_folders = config.output_folders or {}

        if config.output_folder then
            table.insert(output_folders, config.output_folder)
        end

        if not next(output_folders) then return end

        local dll = target:targetfile()
        local pdb = dll:gsub("%.dll$", ".pdb")

        if #output_folders > 0 then
            for _, output_folder in ipairs(output_folders) do
                local dll_target = path.join(output_folder, path.filename(dll))
                local pdb_target = path.join(output_folder, path.filename(pdb))

                -- Clean up previous files in the output folder
                if os.isfile(dll_target) then
                    os.rm(dll_target)
                end
                if os.isfile(pdb_target) then
                    os.rm(pdb_target)
                end

                -- Copy new files to output fulder
                os.cp(dll, output_folder)
                if os.isfile(pdb) then
                    os.cp(pdb, output_folder)
                end
            end
        end
    end)