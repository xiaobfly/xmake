--!A cross-platform build utility based on Lua
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-- Copyright (C) 2015-present, TBOOX Open Source Group.
--
-- @author      ruki
-- @file        windows.lua
--

-- imports
import("core.base.option")
import("core.project.config")
import("core.tool.toolchain")
import("lib.detect.find_file")
import("lib.detect.find_path")
import("detect.sdks.find_qt")

-- get bin directory, if set_prefixdir changed bindir, we should use bindir
function _get_bindir(target)
    local bindir = assert(target:bindir(), "please use `xmake install -o installdir` or `set_installdir` to set install directory on windows.")
    return bindir
end

-- install application package for windows
function main(target, opt)

    local bindir = _get_bindir(target)
    local targetfile = path.join(bindir, path.filename(target:targetfile()))
    local installfiles = {}
    table.insert(installfiles, targetfile)
    for _, t in ipairs(target:orderdeps()) do
        if t:rules()["qt.shared"] then -- qt.shared deps
            local installfile = path.join(bindir, path.filename(t:targetfile()))
            table.insert(installfiles, installfile)
        end
    end

    -- get qt sdk
    local qt = assert(find_qt(), "Qt SDK not found!")

    -- get windeployqt
    local search_dirs = {}
    if qt.bindir_host then table.insert(search_dirs, qt.bindir_host) end
    if qt.bindir then table.insert(search_dirs, qt.bindir) end
    local windeployqt = find_file("windeployqt" .. (is_host("windows") and ".exe" or ""), search_dirs)
    assert(os.isexec(windeployqt), "windeployqt.exe not found!")

    -- find qml directory
    local qmldir = target:values("qt.deploy.qmldir")
    if not qmldir then
        for _, sourcebatch in pairs(target:sourcebatches()) do
            if sourcebatch.rulename == "qt.qrc" then
                for _, sourcefile in ipairs(sourcebatch.sourcefiles) do
                    qmldir = find_path("*.qml", path.directory(sourcefile))
                    if qmldir then
                        break
                    end
                end
            end
        end
    else
        qmldir = path.join(target:scriptdir(), qmldir)
    end

    -- find msvc to set VCINSTALLDIR env
    local envs = nil
    local msvc = toolchain.load("msvc", {plat = target:plat(), arch = target:arch()})
    if msvc then
        local vcvars = msvc:config("vcvars")
        if vcvars and vcvars.VCInstallDir then
            envs = {VCINSTALLDIR = vcvars.VCInstallDir}
        end
    end
    -- bind qt bin path
    -- https://github.com/xmake-io/xmake/issues/4297
    if qt.bindir_host or qt.bindir then
        envs = envs or {}
        envs.PATH = {}
        if qt.bindir_host then
            table.insert(envs.PATH, qt.bindir_host)
        end
        if qt.bindir then
            table.insert(envs.PATH, qt.bindir)
        end
        local curpath = os.getenv("PATH")
        if curpath then
            table.join2(envs.PATH, path.splitenv(curpath))
        end
    end

    local argv = {"--force"}
    if option.get("diagnosis") then
        table.insert(argv, "--verbose=2")
    elseif option.get("verbose") then
        table.insert(argv, "--verbose=1")
    else
        table.insert(argv, "--verbose=0")
    end

    -- make sure user flags have priority over default
    local user_flags = table.wrap(target:values("qt.deploy.flags"))
    if table.contains(user_flags, "--debug", "--release") then
        if is_mode("debug") then
            table.insert(argv, "--debug")
        else
            table.insert(argv, "--release")
        end
    end

    if qmldir then
        table.insert(argv, "--qmldir=" .. qmldir)
    end

    -- add user flags
    if user_flags then
        argv = table.join(argv, user_flags)
    end

    -- windeployqt for both target and its deps
    table.join2(argv, installfiles)

    os.vrunv(windeployqt, argv, {envs = envs})
end
