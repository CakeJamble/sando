-- Signal: OnFaint
---@param koCharacters Character[]
return function(_, koCharacters)
	for _,character in ipairs(koCharacters) do
		character:revive()
	end
end;