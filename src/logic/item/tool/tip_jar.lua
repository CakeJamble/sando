return function(accessory, characterTeam)
	local extraMoney = math.ceil(accessory.sellValue * 0.25)
	characterTeam.money = characterTeam.money + extraMoney
end;