local P = {
	spec = "https://github.com/folke/snacks.nvim",
	module = "snacks",
}

Pack.register(P)

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		Pack.load(P, function(plugin)
			plugin.setup({
				dashboard = {
					enabled = true,
					sections = {
						{ section = "header" },
					},
				},
				lazygit = {
					enabled = true,
					configure = false,
				},
				scroll = {
					enabled = true,
					animate = {
						duration = { step = 10, total = 200 },
						easing = "linear",
					},
					animate_repeat = {
						delay = 100,
						duration = { step = 5, total = 50 },
						easing = "linear",
					},
				},
				image = {
					enabled = true,
					doc = { enabled = true, inline = false, float = true, max_width = 50, max_height = 50 },
				},
				input = {
					enabled = true,
				},
				explorer = {
					animate = {
						enabled = true,
					},
					win = {
						border = {
							style = "rounded",
							color = { fg = "#1e222a", bg = "#1e222a" },
							text = { fg = "#1e222a", bg = "#1e222a" },
						},
					},
				},
				indent = {
					enabled = true,
					indent = {
						only_scope = true,
					},
					scope = {
						enabled = true,
					},
					animate = {
						enabled = true,
					},
				},
				picker = {
					enabled = true,
					prompt = "  ",
					actions = {
						picker_select = function(picker)
							local item = picker.list:current()
							if item and not picker.list:is_selected(item) then
								picker.list:select(item)
							else
								picker.list:unselect(item)
							end
						end,
					},
					sources = {
						explorer = {
							jump = { close = true },
						},
						projects = {
							projects = {
								"~/.config/kitty/",
								"~/.config/lazygit/",
							},
							dev = { "~/.config", "~/Documents/Work/", "~/Documents/Private/" },
							max_depth = 2,
							recent = false,
							patterns = {
								".git",
								"Cargo.toml",
								"package.json",
								"Makefile",
								"go.mod",
							},
						},
						select = {
							kinds = {
								overseer_template = {
									layout = {
										preset = "vscode",
										layout = {
											width = 0.4,
											height = 0.3,
											min_width = 40,
											border = "rounded",
										},
									},
								},
								["mason.ui.language-filter"] = {
									layout = {
										layout = {
											width = 0.4,
											height = 0.3,
											min_width = 40,
											border = "rounded",
										},
									},
								},
							},
						},
						lsp_config = {
							format = function(item, picker)
								if not item.attached_buf then
									item = vim.tbl_extend("force", {}, item, {
										attached = false,
										enabled = false,
									})
								end
								return require("snacks.picker.source.lsp.config").format(item, picker)
							end,
						},
					},
					formatters = {
						file = {
							filename_only = true,
						},
					},
					win = {
						input = {
							keys = {
								["jk"] = { "close", mode = { "n", "i" } },
								["<S-Tab>"] = { "list_up", mode = { "n", "x", "i" } },
								["<Tab>"] = { "list_down", mode = { "n", "x", "i" } },
								["s"] = { "picker_select", mode = { "n", "x" } },
							},
						},
						list = {
							keys = {
								["<S-Tab>"] = { "list_up", mode = { "n", "x", "i" } },
								["<Tab>"] = { "list_down", mode = { "n", "x", "i" } },
								["s"] = { "picker_select", mode = { "n", "x", "i" } },
							},
						},
					},
					icons = {
						ui = {
							live = "󰐰 ",
							hidden = "󱞞 ",
							ignored = " ",
							follow = "󰬍 ",
							selected = " ",
							unselected = " ",
						},
						lsp = {
							unavailable = "󰳥 ",
							enabled = "󰇺 ",
							disabled = "󰩆 ",
							attached = " ",
						},
						git = {
							enabled = true,
							commit = " ",
							staged = " ",
							added = " ",
							deleted = " ",
							ignored = " ",
							modified = " ",
							renamed = " ",
							unmerged = " ",
							untracked = " ",
						},
						diagnostics = {
							Error = "󰬌 ",
							Warn = "󰬞 ",
							Hint = "󰬏 ",
							Info = "󰬐 ",
						},
					},
				},
				notifier = {
					enabled = true,
					auto_close = {
						enabled = true,
					},
					history = {
						minimal = true,
					},
					icons = {
						error = "󰬌 ",
						warn = "󰬞 ",
						info = "󰬐 ",
						debug = "󰬋 ",
						trace = "󰬛 ",
					},
					styles = {
						ft = "markdown",
					},
				},
			})
		end)
	end,
})
