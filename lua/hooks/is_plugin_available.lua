--- 判断插件是否已完整安装（git 仓库健康即可，不依赖具体目录结构）
local is_install_healthy = require("hooks.is_install_healthy")

local function is_plugin_available(name)
	local PackUtils = _G.PackUtils
	local path = PackUtils.resolve_plugin_path(name)
	if not path then
		return false
	end
	return is_install_healthy(path)
end

return is_plugin_available
