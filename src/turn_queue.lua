--! file: turn_queue
require("entity")

function order_fcn(a, b)
  return a:getSpeed() < b:getSpeed()
end

function sort_entities()
  table.sort(Entities, order_fcn)
end