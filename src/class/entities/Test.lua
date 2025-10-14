local Class = require('libs.hump.class')
local Test = Class{}

function Test:init()
	self.message = "Hello, World!"
end;

return Test