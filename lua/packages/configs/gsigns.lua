if vim.g.vscode then
	return
end

local P = {
	spec = "https://github.com/lewis6991/gitsigns.nvim",
	module = "gitsigns",
}

PackUtils.register_plugin(P)

vim.api.nvim_create_autocmd("UIEnter", {
	callback = function()
		vim.schedule(function()
			PackUtils.load_plugin(P, function(plugin)
				plugin.setup({
					signs_staged_enable = false,
					signcolumn = false,
					numhl = true,
					current_line_blame = true,
					current_line_blame_opts = {
						virt_text = true,
						virt_text_pos = "eol",
						delay = 0,
						ignore_whitespace = true,
						virt_text_priority = 100,
						use_focus = false,
					},
					current_line_blame_formatter = "<abbrev_sha> <author> <author_time:%R> - Commit: <summary>",
					attach_to_untracked = true,
				})
			end)
		end)
	end,
})
