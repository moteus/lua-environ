# lua-environ
[![Licence](http://img.shields.io/badge/Licence-MIT-brightgreen.svg)](LICENSE)
[![Build status](https://ci.appveyor.com/api/projects/status/26vx12gybxkaen24/branch/master?svg=true)](https://ci.appveyor.com/project/moteus/lua-environ/branch/master)
[![Build Status](https://travis-ci.org/moteus/lua-environ.svg?branch=master)](https://travis-ci.org/moteus/lua-environ)

Manipulate with environment variables


```Lua
-- System environment (only Windows supported)
local system  = require "environ.system"

-- Current user system environment (only Windows supported)
local user  = require "environ.user"

-- Current process environment
local process = require "environ.process"

print(system.getenv('TEMP')) -- %SystemRoot%\TEMP

print(user.getenv('TEMP')) -- %USERPROFILE%\AppData\Local\Temp

print(process.getenv('TEMP')) -- C:\Users\moteus\AppData\Local\Temp

-- print all user vars
for key, value in user.enum() do print(key, value) end

-- print all process vars
for key, value in process.enum() do print(key, value) end

-- expand environment supports both `$` and `%` notations
print(process.expand('%TEMP%/myapp'))
print(process.expand('$ProgramFiles/myapp'))
print(process.expand('${ProgramData}/myapp'))

-- Can access to environment using `ENV` proxy table.
process.PATH="%ProgramFiles%/myapp;%PATH%"
```