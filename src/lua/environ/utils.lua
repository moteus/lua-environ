local lpeg = require "lpeg"

local IS_WINDOWS = (package.config:sub(1,1) == '\\')

local D_WIN = function(s) return '%' .. s .. '%' end
local D_PSX = function(s) return '$' .. s end
local D     = IS_WINDOWS and D_WIN or D_PSX

local P, C, Cs, Ct, Cp, S = lpeg.P, lpeg.C, lpeg.Cs, lpeg.Ct, lpeg.Cp, lpeg.S

local any = P(1)
local sym = any-S':${}%'
local esc = (P'%%' / '%%') + (P'$$' / '$')
local var = (P'%' * C(sym^1) * '%') + (P'${' * C(sym^1) * '}') + (P'$' * C(sym^1))

local function MakeSubPattern(fn)
  return Cs((esc + (var / D_PSX) + any)^0)
end

local function BuildExpand(getenv)
  local function subst(k)
    local v = getenv(k)
    if v then return v end
  end

  local pattern = MakeSubPattern(subst)

  return function(str)
    return pattern:match(str)
  end
end

local Normalize do

local psx_pattern = MakeSubPattern(D_PSX)
local win_pattern = MakeSubPattern(D_WIN)
local sys_pattern = MakeSubPattern(D)

Normalize = function(str, mode)
  local pattern 
  if mode == nil then pattern = sys_pattern
  elseif (mode == '$') or (mode == false) then pattern = psx_pattern
  elseif (mode == '%') or (mode == true)  then pattern = win_pattern
  else error('unsupportde mode') end
  return pattern:match(str)
end

end

local function split_first(str, sep, plain, pos)
  local e, e2 = string.find(str, sep, pos, plain)
  if e then
    return string.sub(str, 1, e - 1), string.sub(str, e2 + 1)
  end
  return str
end

return {
  IS_WINDOWS   = IS_WINDOWS;
  build_expand = BuildExpand;
  normalize    = Normalize;
  split_first  = split_first;
}