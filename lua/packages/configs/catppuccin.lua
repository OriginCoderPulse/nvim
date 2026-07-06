if vim.g.vscode then
	return
end

local P = {
	spec = {
		src = "https://github.com/catppuccin/nvim",
		name = "catppuccin",
	},
	module = "catppuccin",
}

Pack.register(P)

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		Pack.load(P, function(plugin)
			plugin.setup({
				flavour = "mocha",
				transparent_background = true,
				float = {
					transparent = true,
					solid = false,
				},
				styles = {
					comments = {},
				},
				integrations = {
					blink_cmp = { enabled = true, style = "bordered" },
					overseer = true,
					mason = true,
					snacks = {
						enabled = true,
					},
					noice = true,
					treesitter = true,
					gitsigns = {
						enabled = true,
						transparent = true,
					},
					render_markdown = true,
				},
				custom_highlights = function(C)
					return {
						Comment = { fg = C.overlay0 },
						NormalFloat = { fg = C.text, bg = C.none },
						FloatBorder = { fg = C.surface1, bg = C.none },
						FloatTitle = { fg = C.subtext0, bg = C.none },
						FloatFooter = { fg = C.subtext0, bg = C.none },
						Pmenu = { fg = C.text, bg = C.none },
						PmenuSel = { fg = C.text, bg = C.none, style = { "bold" } },
						PmenuSbar = { bg = C.none },
						PmenuThumb = { bg = C.overlay0 },
						WinSeparator = { fg = C.surface1, bg = C.none },
						BlinkCmpMenu = { fg = C.text, bg = C.none },
						BlinkCmpMenuBorder = { fg = C.surface1, bg = C.none },
						BlinkCmpDoc = { fg = C.text, bg = C.none },
						BlinkCmpDocBorder = { fg = C.surface1, bg = C.none },
						BlinkCmpDocSeparator = { fg = C.surface1, bg = C.none },
						BlinkCmpSignatureHelpBorder = { fg = C.surface1, bg = C.none },
						BlinkCmpMenuSelection = { fg = C.peach, bg = C.none, style = { "bold" } },
						BlinkCmpScrollBarGutter = { bg = C.none },
						BlinkCmpScrollBarThumb = { bg = C.overlay0 },
						OverseerPENDING = { fg = C.overlay0 },
						OverseerRUNNING = { fg = C.yellow },
						OverseerSUCCESS = { fg = C.green },
						OverseerFAILURE = { fg = C.red },
						OverseerCANCELED = { fg = C.overlay1 },
						OverseerTask = { fg = C.text },
						OverseerTaskBorder = { fg = C.surface1 },
						OverseerOutput = { fg = C.subtext0 },
						OverseerComponent = { fg = C.peach },
						OverseerField = { fg = C.blue },
						MasonHeader = { fg = C.peach, bg = C.none, bold = true },
						MasonHeaderSecondary = { fg = C.blue, bg = C.none, bold = true },
						MasonHighlight = { fg = C.blue, bg = C.none },
						MasonHighlightSecondary = { fg = C.peach, bg = C.none },
						MasonHighlightBlock = { fg = C.blue, bg = C.none },
						MasonHighlightBlockBold = { fg = C.blue, bg = C.none, bold = true },
						MasonHighlightBlockSecondary = { fg = C.peach, bg = C.none },
						MasonHighlightBlockBoldSecondary = { fg = C.peach, bg = C.none, bold = true },
						MasonLink = { fg = C.blue, bg = C.none },
						MasonMuted = { fg = C.overlay0, bg = C.none },
						MasonMutedBlock = { fg = C.overlay0, bg = C.none },
						MasonMutedBlockBold = { fg = C.overlay0, bg = C.none, bold = true },
						MasonHeading = { fg = C.text, bg = C.none, bold = true },
						MasonNormal = { fg = C.text, bg = C.none },
						MasonBackdrop = { bg = C.none },
					}
				end,
			})
			vim.cmd.colorscheme("catppuccin")
		end)
	end,
})
