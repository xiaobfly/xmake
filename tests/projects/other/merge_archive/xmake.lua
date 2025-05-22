add_rules("mode.debug", "mode.release")

target("add")
    set_kind("static")
    add_files("src/add.c")
    set_policy("build.fence", true)
    set_targetdir("$(builddir)/merge_archive")

target("sub")
    set_kind("static")
    add_files("src/sub.c")
    set_policy("build.fence", true)
    set_targetdir("$(builddir)/merge_archive")

target("mul")
    set_kind("static")
    add_deps("add", "sub")
    add_files("src/mul.c")
    if is_plat("windows") then
        add_files("$(builddir)/merge_archive/*.lib")
    else
        add_files("$(builddir)/merge_archive/*.a")
    end

