return {
	cmd = { "emmet-language-server", "--stdio" },
	filetypes = {
		"css",
		"html",
		"javascriptreact",
		"less",
		"sass",
		"scss",
		"typescriptreact",
		"vue",
	},
	root_dir = PackUtils.lsp_root_dir({}),
}
