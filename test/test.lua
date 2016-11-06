local proc = require "environ".process

for k, v in pairs(proc.environ()) do
  print(k, v, proc.getenv(k))
  assert(v == proc.getenv(k))
end