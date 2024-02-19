local M = {}

-- https://github.com/lunarmodules/Penlight/blob/master/lua/pl/utils.lua
-- An iterator over all non-integer keys (inverse of `ipairs`).
-- This uses `pairs` under the hood, so any value that is iterable using `pairs`
-- will work with this function.
M.kpairs = function(t)
  local index
  return function()
    local value
    while true do
      index, value = next(t, index)
      if type(index) ~= "number" or math.floor(index) ~= index then
        break
      end
    end
    return index, value
  end
end

-- Executes a user-supplied "reducer" callback function on each element of the table indexed with a numeric key, in order, passing in the return value from the calculation on the preceding element
M.ireduce = function(tbl, func, acc)
  for i, v in ipairs(tbl) do
    acc = func(acc, v, i)
  end
  return acc
end

-- Executes a user-supplied "reducer" callback function on each key element of the table indexed with a string key, in order, passing in the return value from the calculation on the preceding element
M.kreduce = function(tbl, func, acc)
  for i, v in pairs(tbl) do
    if type(i) == "string" then
      acc = func(acc, v, i)
    end
  end
  return acc
end

-- Executes a user-supplied "reducer" callback function on each element of the table, in order, passing in the return value from the calculation on the preceding element
M.reduce = function(tbl, func, acc)
  for i, v in pairs(tbl) do
    acc = func(acc, v, i)
  end
  return acc
end

-- Returns the index of the first element in the array that satisfies the provided testing function
M.find_index = function(tbl, func)
  for index, item in ipairs(tbl) do
    if func(item, index) then
      return index
    end
  end

  return nil
end

M.isome = function(tbl, func)
  for index, item in ipairs(tbl) do
    if func(item, index) then
      return true
    end
  end

  return false
end

-- Returns the first element in the array that satisfies the provided testing function
M.ifind = function(tbl, func)
  for index, item in ipairs(tbl) do
    if func(item, index) then
      return item
    end
  end

  return nil
end

M.find_last_index = function(tbl, func)
  for index = #tbl, 1, -1 do
    if func(tbl[index], index) then
      return index
    end
  end
end

M.slice = function(tbl, startIndex, endIndex)
  local sliced = {}
  endIndex = endIndex or #tbl

  for index = startIndex, endIndex do
    table.insert(sliced, tbl[index])
  end

  return sliced
end

M.concat = function(...)
  local concatenated = {}

  for _, tbl in ipairs({...}) do
    for _, value in ipairs(tbl) do
      table.insert(concatenated, value)
    end
  end

  return concatenated
end

-- Creates a new table populated with the results of calling a provided functions on every numeric indexed element in the calling table
M.imap = function(tbl, func)
  return M.ireduce(
    tbl,
    function(new_tbl, value, index)
      table.insert(new_tbl, func(value, index))
      return new_tbl
    end,
    {}
  )
end

-- Returns an array of a given table's string-keyed property names.
M.keys = function(tbl)
  local keys = {}
  for key, _ in M.kpairs(tbl) do
    table.insert(keys, key)
  end
  return keys
end

-- Returns an array of a given table's numbered-keyed property names.
M.indexes = function(tbl)
  local indexes = {}
  for key, _ in ipairs(tbl) do
    table.insert(indexes, key)
  end
  return indexes
end

-- Creates a new function that, when called, has its arguments preceded by any provided ones
M.bind = function(func, ...)
  local boundArgs = {...}

  return function(...)
    return func(unpack(boundArgs), ...)
  end
end

M.ifilter = function(tbl, func)
  return vim.tbl_filter(func, tbl)
end

M.switch = function(param, t)
  local case = t[param]
  if case then
    return case()
  end
  local defaultFn = t["default"]
  return defaultFn and defaultFn() or nil
end

M.trim = function(str)
  return (str:gsub("^%s*(.-)%s*$", "%1"))
end

return M
