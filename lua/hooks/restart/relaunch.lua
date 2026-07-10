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
	local choice = vim.fn.confirm(
		"插件已安装: " .. names .. "，是否重启 Neovim？",
		"&Yes\n&No",
		2
	)
	if choice ~= 1 then
		state.installed = {}
		return
	end

	vim.notify("正在重启 Neovim...", vim.log.levels.INFO)

	state.installed = {}
	vim.schedule(function()
		vim.cmd.restart()
	end)
end
