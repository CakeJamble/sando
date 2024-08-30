--! file: turn_queue
require("entity")

function order_fcn(a, b)
  return a["speed"] < b["speed"]
end


function sort_entities()
  table.sort(Entity, order_fcn)
end