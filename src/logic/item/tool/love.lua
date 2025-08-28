return function(rewards)
	for _,reward in ipairs(rewards) do
		reward.exp = math.floor(0.5 + (reward.exp * 0.3))
	end
end;