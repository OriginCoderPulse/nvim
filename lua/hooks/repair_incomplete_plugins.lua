--- 检测并清理已登记但 git 仓库不完整的插件（clone 中断等）
local is_install_healthy = require("hooks.is_install_healthy")

local function repair_incomplete_plugins()
	local PackUtils = _G.PackUtils

	if vim.tbl_isempty(PackUtils.registry) then
		return
	end

	local to_delete = {}

	for name in pairs(PackUtils.registry) do
		local path = PackUtils.resolve_plugin_path(name)
		if path and not is_install_healthy(path) then
			to_delete[#to_delete + 1] = name
		end
	end

	if #to_delete == 0 then
		return
	end

	vim.notify("🔧 清理不完整插件: " .. table.concat(to_delete, ", "), vim.log.levels.WARN)
	vim.pack.del(to_delete)
end

return repair_incomplete_plugins
