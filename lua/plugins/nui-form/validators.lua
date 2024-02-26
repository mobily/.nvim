local M = {}

M.required = function(value)
  return not (value ~= nil)
end

M.min_length = function(min)
  return function(value)
    return #value > min
  end
end

M.is_not_empty = M.min_length(1)

M.max_length = function(max)
  return function(value)
    return #value < max
  end
end

M.contains = function(pattern)
  return function(value)
    return string.find(value, pattern)
  end
end

M.compose = function(...)
  local tbl = {...}

  return function(value)
    for index, fn in ipairs(tbl) do
      if not fn(value) then
        return false
      end
    end

    return true
  end
end

return M
