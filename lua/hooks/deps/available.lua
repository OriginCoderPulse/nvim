--- 判断插件是否已完整安装（git 仓库健康即可，不依赖具体目录结构）
local healthy = require("hooks.deps.healthy")

local function available(name)
	local Pack = _G.Pack
	local dir = Pack.path(name)
	if not dir then
		return false
	end
	return healthy(dir)
end

return available
