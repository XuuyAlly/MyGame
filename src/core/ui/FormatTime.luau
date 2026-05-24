return function(arg1)
	local maximum = math.max(0, arg1)
	local var3 = maximum // 86400
	local var4 = maximum % 86400 // 3600
	local var5 = maximum % 3600 // 60
	local var6 = maximum % 60
	local var7
	if 0 < var3 then
		var7 = var7 .. `{var3}d `
	end
	if 0 < var4 then
		var7 = var7 .. `{var4}h `
	end
	if 0 < var5 then
		var7 = var7 .. `{var5}m `
	end
	if 0 < var6 and var3 == 0 and var4 == 0 then
		var7 = var7 .. `{var6}s`
		return var7
	end
	var7 = var7:sub(1, -2)
	return var7
end
