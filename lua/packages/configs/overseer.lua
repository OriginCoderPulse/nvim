if vim.g.vscode then
	return
end

local P = {
	spec = "https://github.com/stevearc/overseer.nvim",
	module = "overseer",
    lock = true,
}

Pack.register(P)

vim.api.nvim_create_autocmd("UIEnter", {
	callback = function()
		vim.schedule(function()
			Pack.load(P, function(plugin)
				plugin.setup({
					dap = false,
					task_list = {
						direction = "left",
					},
				})
			end)
		end)
	end,
})
