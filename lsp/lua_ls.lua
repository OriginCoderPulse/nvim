return {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_dir = PackUtils.lsp_root_dir({ ".luarc.json", ".luarc.jsonc" }),
	settings = {
		Lua = {
			diagnostics = {
				globals = { "PackUtils", "Snacks" },
			},
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME,
				},
			},
		},
	},
}
