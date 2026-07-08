local immed = require("hooks.load.immed")
local load_dep = require("hooks.load.load_dep")

--- 加载 immediately=true 的依赖
return function()
	local Pack = _G.Pack
	for _, P in pairs(Pack.registry) do
		if not P.disabled and P.deps then
			for _, dep in ipairs(P.deps) do
				if immed.immed(dep) then
					load_dep(dep, P.name, { [P.name] = true })
				end
			end
		end
	end
end
