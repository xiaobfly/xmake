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
-- @file        main.lua
--

-- imports
import(".server")

-- define module
local remote_build_server = remote_build_server or server()

-- init server
function remote_build_server:init()
    self:super():init(self)
end

-- run main loop
function remote_build_server:runloop()
    self:super():runloop(self)
end

function main()
    local instance = remote_build_server()
    instance._super = remote_build_server
    instance:init()
    return instance
end