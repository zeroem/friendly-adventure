local n = 0

function inc()
  n = n + 1
end

function inc2(n)
  return n + 1
end

function fn()
end

for i=0,1000000 do
  fn()
end

print(n)
