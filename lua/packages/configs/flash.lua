if vim.g.vscode then
	return
end

local P = {
	spec = "https://github.com/folke/flash.nvim",
	module = "flash",
}

PackUtils.register_plugin(P)

vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		PackUtils.load_plugin(P, function(plugin)
			plugin.setup({})

			vim.keymap.set({ "n", "x", "o" }, "f", function()
				plugin.jump()
			end, { desc = "Flash" })
		end)
	end,
})
