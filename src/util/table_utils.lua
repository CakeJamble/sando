local TableUtils = {}

---@param original table
---@return table
TableUtils.deepCopy = function(original)
  local copy
  if type(original) == 'table' then
    copy = {}
    for k,v in pairs(original) do
      copy[k] = TableUtils.deepCopy(v)
    end
  else
    copy = original
  end
  return copy
end;

---@param T table
TableUtils.sortLayers = function(T)
	table.sort(T,
		function(first, second)
			return first.layer > second.layer
		end
	)
end;

-- Sort a copy of the table by values and iterate over it
---@param t table
---@param f? function()
TableUtils.pairsByValues = function(t, f)
  local a = {}
  for k,v in pairs(t) do table.insert(a, {k,v}) end
  table.sort(a,function(x, y)
    if f then
      return f(x[2], y[2])
    else
      return x[2] < y[2]
    end
  end)

  local i = 0
  local iter = function()
    i = i + 1
    if a[i] == nil then return nil
    else return a[i][1], a[i][2]
    end
  end
  return iter
end;

return TableUtils