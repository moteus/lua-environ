package.path = "..\\src\\lua\\?.lua;" .. package.path

pcall(require, "luacov")

local utils       = require "utils"
local TEST_CASE   = require "lunit".TEST_CASE
local RUN, IT = utils.RUN, utils.IT

local print, require, pairs = print, require, pairs

local environ = require "environ"
local eutils  = require "environ.utils"

local IS_LUA_51 = not not string.find(_VERSION, '5.1', nil, true)

print("------------------------------------")
print("Module    name: " .. environ._NAME);
print("Module version: " .. environ._VERSION);
print("Lua    version: " .. (jit and jit.version or _VERSION))
print("------------------------------------")
print("")

local ENABLE = true

local _ENV = TEST_CASE'environ.process.test' if ENABLE then
local it = IT(_ENV)

local env = environ.process

function teardown()
  env.setenv('X')
  env.setenv('x')
  env.setenv('Y')
  env.setenv('Z')
end

function setup()
  env.setenv('X')
  env.setenv('x')
  env.setenv('Y')
  env.setenv('Z')
end

it('set variable', function()
  assert_nil(env.getenv('X'))
  assert_true(env.setenv('X', 'hello'))
  assert_equal('hello', env.getenv('X'))
end)

if eutils.IS_WINDOWS then

it('get variable is not case sensivity', function()
  assert_true(env.setenv('X', 'hello'))
  assert_equal('hello', env.getenv('x'))
end)

else

it('get variable is not case sensivity', function()
  assert_true(env.setenv('X', 'hello'))
  assert_true(env.setenv('x', 'world'))
  assert_equal('hello', env.getenv('X'))
  assert_equal('world', env.getenv('x'))
end)

end

it('expand variable', function()
  assert_true(env.setenv('X', 'hello'))
  assert_true(env.setenv('Y', 'world'))
  assert_equal('hello world', env.expand('$X %Y%'))
end)

it('set unexpanded variable', function()
  assert_true(env.setenv('X', 'hello'))
  assert_true(env.setenv('Y', '$X %X%'))
  assert_equal('$X %X%', env.getenv('Y'))
end)

it('set expanded variable', function()
  assert_true(env.setenv('X', 'hello'))
  assert_true(env.setenv('Y', '$X %X%', true))
  assert_equal('hello hello', env.getenv('Y'))
end)

it('ENV map set expanded variable', function()
  local ENV = assert_table(env.ENV)

  ENV.X = 'hello'
  ENV.Y = '$X %X%'
  assert_equal('hello hello', ENV.Y)
  assert_equal('hello hello', env.getenv('Y'))
end)

it('environ get map', function()
  assert_true(env.setenv('X', 'hello'))
  local t = assert_table(env.environ())
  assert_equal('hello', t['X'])
end)

it('var with spaces', function()
  assert_true(env.setenv('HELLO WORLD', 'hello, world!!!'))
  assert_equal('hello, world!!!', env.getenv('HELLO WORLD'))
  assert_equal('hello, world!!!', env.expand('%HELLO WORLD%'))
  assert_equal('hello, world!!!', env.expand('${HELLO WORLD}'))
  assert_equal('$(HELLO WORLD)',  env.expand('$(HELLO WORLD)'))
  assert_equal('$HELLO WORLD',    env.expand('$HELLO WORLD'))
end)

if not IS_LUA_51 then

it('iterate over vars', function()
  assert_true(env.setenv('X', 'hello'))
  local found
  for k, v in pairs(env.ENV) do
    found = (k == 'X') and (v == 'hello')
    if found then break end
  end
  assert_true(found)
end)

end

it('should actually set envionment', function()
  assert(env.setenv('X', 'HELLO'))
  assert_equal('HELLO', eutils.os_getenv('X'))
end)

end

if eutils.IS_WINDOWS then

local _ENV = TEST_CASE'environ.user.test' if ENABLE then
local it = IT(_ENV)

local env  = environ.user

function setup()
  env.setenv('X')
  env.setenv('Y')
  env.setenv('Z')
end

function teardown()
  env.setenv('X')
  env.setenv('Y')
  env.setenv('Z')
end

it('set variable', function()
  assert_nil(env.getenv('X'))
  assert_true(env.setenv('X', 'hello'))
end)

it('get variable is not case sensivity', function()
  assert_true(env.setenv('X', 'hello'))
  assert_equal('hello', env.getenv('x'))
end)

it('normalize variable', function()
  assert_true(env.setenv('X', '$Y %Y%', true))
  assert_equal('%Y% %Y%', env.getenv('X'))
end)

it('ENV map set normalized variable', function()
  local ENV = assert_table(env.ENV)

  ENV.X = '$Y %Y%'
  assert_equal('%Y% %Y%', ENV.X)
  assert_equal('%Y% %Y%', env.getenv('X'))
end)

it('environ get map', function()
  assert_true(env.setenv('X', 'hello'))
  local t = assert_table(env.environ())
  assert_equal('hello', t['X'])
end)

end

end

RUN()