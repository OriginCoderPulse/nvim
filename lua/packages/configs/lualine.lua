local P = {
	spec = "https://github.com/nvim-lualine/lualine.nvim",
	module = "lualine",
	deps = {
		"https://github.com/pnx/lualine-lsp-status",
	},
}

Pack.register(P)

vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function()
		Pack.load(P, function(plugin)
			plugin.setup({
				options = {
					icons_enabled = true,
					theme = function()
						local base = require("lualine.themes.auto")
						for _, mode in pairs(base) do
							if type(mode) == "table" then
								for _, section in pairs(mode) do
									if type(section) == "table" then
										section.bg = "NONE"
									end
								end
							end
						end
						return base
					end,
					component_separators = { left = " ", right = " " },
					section_separators = { left = " ", right = " " },
					always_divide_middle = true,
					globalstatus = true,
					refresh = {
						statusline = 1,
						winbar = 1,
					},
				},
				sections = {
					lualine_a = {},
					lualine_b = {
						"branch",
						{
							"filename",
							path = 0,
							file_status = false,
							newfile_status = false,
							symbols = {
								unnamed = " ",
							},
						},
						{
							"filetype",
							icon_only = true,
						},
						{
							"overseer",
							colored = true,
						},
					},
					lualine_c = {
						{
							"filesize",
							icons_enabled = true,
							icon = { "", align = "right" },
							color = { fg = "#f9e2af" },
						},
					},
					lualine_x = {
						"diff",
						{
							"diagnostics",
							sources = { "nvim_diagnostic" },
							sections = { "error", "warn", "info", "hint" },
							diagnostics_color = {
								error = "DiagnosticError",
								warn = "DiagnosticWarn",
								info = "DiagnosticInfo",
								hint = "DiagnosticHint",
							},
							symbols = { error = "󰬌 ", warn = "󰬞 ", info = "󰬐 ", hint = "󰬏 " },
							colored = true,
							update_in_insert = true,
							always_visible = true,
						},
					},
					lualine_y = {
						{ "datetime", style = "󰄉 %Y˚%m˚%d | %H:%M:%S" },
						{
							"lsp-status",
							show_count = false,
							disabled_filetypes = {
								"mason",
								"NvimTree",
								"TelescopePrompt",
								"toggleterm",
								"codecompanion",
								"markdown",
								"snacks_picker_input",
								"snacks_picker_list",
								"unnamed",
								"snacks_dashboard",
								"toml",
							},
							icons = {
								active = " ",
								inactive = " ",
							},
						},
					},
					lualine_z = {},
				},
			})
		end)
	end,
})
