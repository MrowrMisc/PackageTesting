rule("plugin")

    on_config(function (target)
        local config = target:extraconf("rules", "plugin")

        local plugin_name = config.name or target:name()
        local plugin_version = config.version or "0.0.0"
        local plugin_description = config.description or ""
        local plugin_author = config.author or ""
        local plugin_email = config.email or ""
        local plugin_output_folder = config.output_folder
        local plugin_output_folders = config.output_folders

        if os.getenv("DEPENDS_ON_SKYRIM_COMMONLIB_AE") == "true" then
            target:add("packages", "skyrim-commonlib-ae")
            target:add("rules", "@skyrim-commonlib-ae/plugin", {
                name = plugin_name,
                version = plugin_version,
                description = plugin_description,
                author = plugin_author,
                email = plugin_email,
                output_folder = plugin_output_folder,
                output_folders = plugin_output_folders
            })
        end

        if os.getenv("DEPENDS_ON_SKYRIM_COMMONLIB_SE") == "true" then
            target:add("packages", "skyrim-commonlib-se")
            target:add("rules", "@skyrim-commonlib-se/plugin", {
                name = plugin_name,
                version = plugin_version,
                description = plugin_description,
                author = plugin_author,
                email = plugin_email,
                output_folder = plugin_output_folder,
                output_folders = plugin_output_folders
            })
        end

        if os.getenv("DEPENDS_ON_SKYRIM_COMMONLIB_VR") == "true" then
            target:add("packages", "skyrim-commonlib-vr")
            target:add("rules", "@skyrim-commonlib-vr/plugin", {
                name = plugin_name,
                version = plugin_version,
                description = plugin_description,
                author = plugin_author,
                email = plugin_email,
                output_folder = plugin_output_folder,
                output_folders = plugin_output_folders
            })
        end

        if os.getenv("DEPENDS_ON_SKYRIM_COMMONLIB_NG") == "true" then
            target:add("packages", "skyrim-commonlib-ng")
            target:add("rules", "@skyrim-commonlib-ng/plugin", {
                name = plugin_name,
                version = plugin_version,
                description = plugin_description,
                author = plugin_author,
                email = plugin_email,
                output_folder = plugin_output_folder,
                output_folders = plugin_output_folders
            })
        end
    end)
