rule("plugin")

    add_deps("win.sdk.resource")

    on_config(function (target)
        local configs = target:extraconf("rules", "@skyrim-commonlib-ng/plugin")

        target:add("rules", "@commonlibsse-ng/plugin", {
            name = configs.name or target:name(),
            description = configs.description or "",
            author = configs.author or "",
            email = configs.email or "",
            options = {
                address_library = true,
                signature_scanning = false
            }
        })
    end)

    after_build(function(target)
        local configs = target:extraconf("rules", "@skyrim-commonlib-ng/plugin")

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