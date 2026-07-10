local immed = require("hooks.load.immed")
local load_dep = require("hooks.load.load_dep")

--- 加载 immediately=true 的依赖
--- Load dependencies with immediately=true
return function()
	local Pack = _G.Pack
	local entries = {}
	for _, P in pairs(Pack.registry) do
		if not P.disabled and P.deps then
			entries[#entries + 1] = P
		end
	end
	table.sort(entries, function(a, b)
		return a.name < b.name
	end)
	for _, P in ipairs(entries) do
		for _, dep in ipairs(P.deps) do
			if immed.immed(dep) then
				load_dep(dep, P.name, { [P.name] = true })
			end
		end
	end
end
