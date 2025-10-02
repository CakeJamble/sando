local socket = require('socket')

return function()
	local utcDate = os.date("!*t")
	local localDate = os.date("%c")
	utcDate.isdst = localDate.isdst

	local seconds = os.time(utcDate)
	local ms = math.floor((socket.gettime() % 1) * 1000)

	return string.format("%s.%dZ", os.date("%Y-%m-%dT%T", seconds), ms)
end