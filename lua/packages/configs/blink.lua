local P = {
	spec = "https://github.com/saghen/blink.cmp",
	deps = {
		"https://github.com/saghen/blink.lib",
		"https://github.com/rafamadriz/friendly-snippets",
		"https://github.com/onsails/lspkind.nvim",
		"https://github.com/xzbdmw/colorful-menu.nvim",
	},
	module = "blink.cmp",
}

Pack.register(P)

vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter", "LspAttach" }, {
	once = true,
	callback = function()
		local function is_menu_item_selected(ctx)
			return ctx.idx == require("blink.cmp.completion.windows.menu").selected_item_idx
		end

		local function selection_indicator_component(icon)
			return {
				ellipsis = false,
				width = { fixed = 2 },
				text = function(ctx)
					return is_menu_item_selected(ctx) and icon or "  "
				end,
				highlight = function(ctx, text)
					if is_menu_item_selected(ctx) then
						return { { 0, #text, group = "BlinkCmpMenuSelection", priority = 20001 } }
					end
					return "BlinkCmpMenu"
				end,
			}
		end

		Pack.load(P, function(plugin)
			plugin.build():pwait()
			plugin.setup({
				keymap = {
					preset = "none",
					["<CR>"] = { "accept", "fallback" },
					["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
					["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
				},
				completion = {
					list = {
						selection = {
							preselect = true,
						},
					},
					documentation = {
						auto_show = true,
						auto_show_delay_ms = 0,
						window = {
							scrollbar = false,
							direction_priority = {
								menu_south = { "n", "s" },
								menu_north = { "s", "n" },
							},
						},
					},
					ghost_text = {
						enabled = true,
					},
					menu = {
						border = "rounded",
						scrollbar = false,
						draw = {
							columns = {
								{ "selection_indicator", "kind_icon", "label", "label_description", gap = 1 },
								{ "kind", "selection_indicator_end", gap = 1 },
							},
							components = {
								selection_indicator = selection_indicator_component(" "),
								selection_indicator_end = selection_indicator_component(" "),
								label = {
									text = function(ctx)
										return require("colorful-menu").blink_components_text(ctx)
									end,
									highlight = function(ctx)
										local text = require("colorful-menu").blink_components_text(ctx)
										if is_menu_item_selected(ctx) then
											return { { 0, #text, group = "BlinkCmpMenuSelection", priority = 20001 } }
										end
										return require("colorful-menu").blink_components_highlight(ctx)
									end,
								},
								kind_icon = {
									text = function(ctx)
										local icon = ctx.kind_icon
										if vim.tbl_contains({ "Path" }, ctx.source_name) then
											local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
											if dev_icon then
												icon = dev_icon
											end
										else
											icon = require("lspkind").symbol_map[ctx.kind] or ""
										end

										return icon .. ctx.icon_gap
									end,

									highlight = function(ctx)
										local hl = ctx.kind_hl
										if vim.tbl_contains({ "Path" }, ctx.source_name) then
											local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
											if dev_icon then
												hl = dev_hl
											end
										end
										if is_menu_item_selected(ctx) then
											return { { group = hl, priority = 20001 } }
										end
										return { { group = hl, priority = 20000 } }
									end,
								},
							},
						},
					},
				},
				sources = { default = { "lsp", "path", "snippets", "buffer" } },
				appearance = {
					use_nvim_cmp_as_default = true,
					nerd_font_variant = "mono",
				},
				fuzzy = { implementation = "rust" },
				cmdline = {
					completion = {
						list = {
							selection = {
								preselect = false,
							},
						},
						menu = {
							auto_show = true,
						},
						ghost_text = {
							enabled = true,
						},
					},
				},
			})

			-- blink 菜单只在打开时绘制一次，选中变化需手动重绘才能更新指示器/颜色
			require("blink.cmp.completion.list").select_emitter:on(function()
				local menu = require("blink.cmp.completion.windows.menu")
				if not menu.win:is_open() or not menu.renderer or not menu.context then
					return
				end
				menu.renderer:draw(menu.context, menu.win:get_buf(), menu.items)
			end)
		end)
	end,
})
