if vim.g.vscode then
	return
end

local P = {
	spec = "https://github.com/xiyaowong/transparent.nvim",
	module = "transparent",
}

Pack.register(P)

vim.api.nvim_create_autocmd({ "ColorScheme", "User" }, {
	pattern = { "*", "TransparentClear" },
	callback = function()
		Pack.load(P, function(plugin)
			plugin.setup({
				groups = {
					"Normal",
					"NormalNC",
					"Comment",
					"Constant",
					"Special",
					"Identifier",
					"Statement",
					"PreProc",
					"Type",
					"Underlined",
					"Todo",
					"String",
					"Function",
					"Conditional",
					"Repeat",
					"Operator",
					"Structure",
					"LineNr",
					"NonText",
					"SignColumn",
					"CursorLine",
					"CursorLineNr",
					"StatusLine",
					"StatusLineNC",
					"EndOfBuffer",
				},
				extra_groups = {
					"NormalFloat",
					"FloatBorder",
					"FloatTitle",
					"FloatFooter",
					"WinSeparator",
					"NvimTreeNormal",
				},
				exclude_groups = {},
			})
		end)
	end,
})
