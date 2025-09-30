-- OnSignal: OnSummon
---@param summon Enemy
return function(summon)
	summon.baseStats.hp = summon.baseStats.hp + math.floor(summon.baseStats.hp * 0.3)
	summon.expReward = summon.expReward + math.ceil(summon.expReward * 0.3)
end;