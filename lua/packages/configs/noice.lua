Pack.register({
	"https://github.com/folke/noice.nvim",
	dependencies = {
		"https://github.com/MunifTanjim/nui.nvim",
	},
	module = "noice",
}):load({
	event = "UIEnter",
	once = true,
	defer = true,
	config = function(plugin)
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
	end,
})
