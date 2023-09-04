rule("plugin")

    add_deps("win.sdk.resource")

    on_config(function(target)
        import("core.base.semver")
        import("core.project.depend")
        import("core.project.project")

        target:add("defines", "UNICODE", "_UNICODE")

        target:set("kind", "shared")
        target:set("arch", "x64")

        local config = target:extraconf("rules", "@skyrim-commonlib-ng/plugin")

        if config.add_package ~= false then
            target:add("packages", "skyrim-commonlib-ng")
        end

        local version = semver.new(config.version or target:version() or "0.0.0")
        local version_string = string.format("%s.%s.%s", version:major(), version:minor(), version:patch())

        local product_version = semver.new(config.product_version or project.version() or config.version or target:version() or "0.0.0")
        local product_version_string = string.format("%s.%s.%s", product_version:major(), product_version:minor(), product_version:patch())

        local output_files_folder = path.join(target:autogendir(), "rules", "skyrim-commonlib-ng", "plugin")

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
                file:print("            VALUE \"FileDescription\", \"%s\"", config.description or "")
                file:print("            VALUE \"FileVersion\", \"%s.0\"", version_string)
                file:print("            VALUE \"InternalName\", \"%s\"", config.name or target:name())
                file:print("            VALUE \"LegalCopyright\", \"%s, %s\"", config.author or "", config.license or target:license() or "Unknown License")
                file:print("            VALUE \"ProductName\", \"%s\"", config.product_name or project.name() or config.name or target:name())
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
                local struct_compat = "Independent"
                local runtime_compat = "AddressLibrary"

                if config.options then
                    local address_library = config.options.address_library or true
                    local signature_scanning = config.options.signature_scanning or false
                    if not address_library and signature_scanning then
                        runtime_compat = "SignatureScanning"
                    end
                end

                file:print("#include <SKSE/SKSE.h>")
                file:print("#include <REL/Relocation.h>\n")
                file:print("using namespace std::literals;\n")
                file:print("SKSEPluginInfo(")
                file:print("    .Version = { %s, %s, %s, 0 },", version:major(), version:minor(), version:patch())
                file:print("    .Name = \"%s\"sv,", config.name or target:name())
                file:print("    .Author = \"%s\"sv,", config.author or "")
                file:print("    .SupportEmail = \"%s\"sv,", config.email or "")
                file:print("    .StructCompatibility = SKSE::StructCompatibility::%s,", struct_compat)
                file:print("    .RuntimeCompatibility = SKSE::VersionIndependence::%s", runtime_compat)
                file:print(")")
                file:close()
            end
        end, { dependfile = target:dependfile(plugin_file), files = project.allfiles()})

        target:add("files", version_file)
        target:add("files", plugin_file)

        target:add("cxxflags", "/permissive-", "/Zc:alignedNew", "/Zc:__cplusplus", "/Zc:forScope", "/Zc:ternary")
        target:add("cxxflags", "cl::/Zc:externConstexpr", "cl::/Zc:hiddenFriend", "cl::/Zc:preprocessor", "cl::/Zc:referenceBinding")
    end)
