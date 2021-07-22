-- --------------------------------------
function length(T)
    local count = 0
    if T ~= nil then
        for _ in pairs(T) do count = count + 1 end
    end
    return count
  end

function gaussian (mean, sigma)
    return  math.sqrt(-2 * sigma * math.log(math.random())) *
            math.cos(2 * math.pi * math.random()) + mean
end

function map(x,in_min,in_max,out_min,out_max)
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

function setContains(set, key)
  return set[key] ~= nil
end

function stdev()
  local sum, sumsq, k = 0,0,0
  return function(n)
    sum, sumsq, k = sum + n, sumsq + n^2, k+1
    return math.sqrt((sumsq / k) - (sum/k)^2)
  end
end
