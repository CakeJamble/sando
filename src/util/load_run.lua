local bitser = require('libs.bitser')

---@return any?
return function()
	local savePath = "save.dat"
	local data = bitser.loadLoveFile(savePath)
	return data
end;