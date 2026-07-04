--- 启动插件系统：同步加载 immediately 依赖，VimEnter 后异步安装其余插件
local function bootstrap_plugins()
	local load_plugin = require("hooks.load_plugin")
	local sync_and_install = require("hooks.sync_and_install")

	load_plugin.load_eager_deps()

	vim.api.nvim_create_autocmd("VimEnter", {
		once = true,
		callback = function()
			vim.schedule(sync_and_install)
		end,
	})
end

return bootstrap_plugins
