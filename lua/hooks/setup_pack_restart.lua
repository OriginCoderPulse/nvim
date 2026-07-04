--- 安装新插件后自动 :restart（Neovim 0.12+ 内置命令）
local installed = {}
local listener_ready = false

local function should_auto_restart()
	if vim.g.vscode then
		return false
	end
	for _, arg in ipairs(vim.v.argv) do
		if arg == "--headless" or arg == "-es" then
			return false
		end
	end
	return true
end

local function setup_pack_restart()
	if listener_ready then
		return
	end
	listener_ready = true

	vim.api.nvim_create_autocmd("PackChanged", {
		group = vim.api.nvim_create_augroup("PackUtilsAutoRestart", { clear = true }),
		callback = function(ev)
			if ev.data.kind == "install" then
				installed[#installed + 1] = ev.data.spec.name
			end
		end,
	})
end

local function maybe_restart_after_install()
	if #installed == 0 or not should_auto_restart() then
		return
	end

	local names = table.concat(installed, ", ")
	vim.notify("插件已安装: " .. names .. "，正在重启 Neovim...", vim.log.levels.INFO)

	vim.schedule(function()
		vim.cmd.restart()
	end)
end

return {
	setup_pack_restart = setup_pack_restart,
	maybe_restart_after_install = maybe_restart_after_install,
}
