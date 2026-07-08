local state = require("hooks.restart.state")
local should_auto_restart = require("hooks.restart.should_restart")

return function()
	if #state.installed == 0 then
		return
	end

	if not should_auto_restart() then
		state.installed = {}
		return
	end

	local names = table.concat(state.installed, ", ")
	vim.notify("插件已安装: " .. names .. "，正在重启 Neovim...", vim.log.levels.INFO)

	state.installed = {}
	vim.schedule(function()
		vim.cmd.restart()
	end)
end
