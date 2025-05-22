add_rules("mode.debug", "mode.release")
add_requires("kotlin-native")
target("foo")
    set_kind("static")
    add_files("src/foo.kt")
    set_toolchains("@kotlin-native")

target("test")
    set_kind("binary")
    add_files("src/main.c")
    add_deps("foo")

