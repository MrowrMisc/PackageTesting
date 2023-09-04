package("skyrim-commonlib-ng")
    set_homepage("https://github.com/CharmedBaryon/CommonLibSSE-NG")
    set_description("A reverse engineered library for Skyrim Special Edition.")
    set_license("MIT")

    -- From the official xmake-repo
    add_deps("commonlibsse-ng")

    on_install("windows|x64", function(package)
    end)
