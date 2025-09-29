local Signal = require('libs.hump.signal')

-- Signal: OnEnterShop
return function(_)
	Signal.emit("DetectStolenRug")
end;