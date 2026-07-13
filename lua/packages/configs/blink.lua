Pack.register({
	"https://github.com/saghen/blink.cmp",
	dependencies = {
		"https://github.com/saghen/blink.lib",
		"https://github.com/rafamadriz/friendly-snippets",
		"https://github.com/onsails/lspkind.nvim",
		"https://github.com/xzbdmw/colorful-menu.nvim",
	},
	module = "blink.cmp",
	build = function()
		require("blink.cmp").build():pwait()
	end,
}):load({
	event = { "InsertEnter", "CmdlineEnter", "LspAttach" },
	once = true,
	utils = {
		menu = "blink.cmp.completion.windows.menu",
		list = "blink.cmp.completion.list",
		colorful_menu = "colorful-menu",
		lspkind = "lspkind",
		devicons = "nvim-web-devicons",
	},
	var = {
		is_menu_item_selected = function(ctx)
			return ctx.idx == menu.selected_item_idx
		end,
		selection_indicator_component = function(icon)
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
		end,
		label_text = function(ctx)
			return colorful_menu.blink_components_text(ctx)
		end,
		label_highlight = function(ctx)
			local text = colorful_menu.blink_components_text(ctx)
			if is_menu_item_selected(ctx) then
				return { { 0, #text, group = "BlinkCmpMenuSelection", priority = 20001 } }
			end
			return colorful_menu.blink_components_highlight(ctx)
		end,
		kind_icon_text = function(ctx)
			local icon = ctx.kind_icon
			if vim.tbl_contains({ "Path" }, ctx.source_name) then
				local dev_icon, _ = devicons.get_icon(ctx.label)
				if dev_icon then
					icon = dev_icon
				end
			else
				icon = lspkind.symbol_map[ctx.kind] or ""
			end
			return icon .. ctx.icon_gap
		end,
		kind_icon_highlight = function(ctx)
			local hl = ctx.kind_hl
			if vim.tbl_contains({ "Path" }, ctx.source_name) then
				local dev_icon, dev_hl = devicons.get_icon(ctx.label)
				if dev_icon then
					hl = dev_hl
				end
			end
			if is_menu_item_selected(ctx) then
				return { { group = hl, priority = 20001 } }
			end
			return { { group = hl, priority = 20000 } }
		end,
		redraw_on_select = {
			use = true,
			callback = function()
				list.select_emitter:on(function()
					if not menu.win:is_open() or not menu.renderer or not menu.context then
						return
					end
					menu.renderer:draw(menu.context, menu.win:get_buf(), menu.items)
				end)
			end,
		},
	},
	config = function(plugin)
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
								text = label_text,
								highlight = label_highlight,
							},
							kind_icon = {
								text = kind_icon_text,
								highlight = kind_icon_highlight,
							},
						},
					},
				},
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
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
	end,
})
