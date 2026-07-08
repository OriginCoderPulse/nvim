local P = {
	spec = "https://github.com/folke/noice.nvim",
	deps = {
		"https://github.com/MunifTanjim/nui.nvim",
	},
	module = "noice",
}

Pack.register(P)

vim.api.nvim_create_autocmd("UIEnter", {
	callback = function()
		vim.schedule(function()
			Pack.load(P, function(plugin)
				plugin.setup({
					cmdline = {
						enabled = true,
						view = "cmdline_popup",
						position = {
							row = 1,
							col = "30%",
						},
						format = {
							cmdline = { icon = " " },
							search_down = { icon = " " },
							search_up = { icon = " " },
							filter = { icon = "󰈲 " },
							help = { icon = "󰮥 " },
							input = { icon = "󰽉 " },
							lua = { icon = "󱨇 " },
						},
					},
					lsp = {
						progress = {
							enabled = false,
						},
					},
					presets = {
						bottom_search = false,
						command_palette = true,
						long_message_to_split = true,
						inc_rename = true,
						lsp_doc_border = true,
					},
				})
			end)
		end)
	end,
})
