if vim.g.vscode then
	return
end

local P = {
	spec = "https://github.com/xiyaowong/transparent.nvim",
	module = "transparent",
}

PackUtils.register_plugin(P)

local function clear_lualine_highlights()
	pcall(function()
		require("transparent").clear_prefix("lualine")
	end)
end

PackUtils.load_plugin(P, function(plugin)
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
		on_clear = clear_lualine_highlights,
	})
end)

vim.api.nvim_create_autocmd({ "ColorScheme", "User" }, {
	pattern = { "*", "TransparentClear" },
	callback = clear_lualine_highlights,
})
