return function(character)
	local targets = character.targets
	local target = character.target
	for i, entity in ipairs(targets) do
		if entity == target then
			if i - 1 > 0 then
				local e = targets[i-1]
				for _,status in ipairs(target.statuses) do
					e:applyStatus(status)
				end
			elseif i + 1 <= #targets then
				local e = targets[i+1]
				for _,status in ipairs(target.statuses) do
					e:applyStatus(status)
				end
			end
		end
	end
end;