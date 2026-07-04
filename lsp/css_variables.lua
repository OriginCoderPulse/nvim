return {
	cmd = { "css-variables-language-server", "--stdio" },
	filetypes = { "css", "scss", "less", "vue" },
	root_dir = PackUtils.lsp_root_dir({
		"package-lock.json",
		"yarn.lock",
		"pnpm-lock.yaml",
		"bun.lockb",
		"bun.lock",
	}),
	settings = {
		cssVariables = {
			blacklistFolders = {
				"**/.cache",
				"**/.DS_Store",
				"**/.git",
				"**/.hg",
				"**/.next",
				"**/.svn",
				"**/bower_components",
				"**/CVS",
				"**/dist",
				"**/node_modules",
				"**/tests",
				"**/tmp",
			},
			lookupFiles = { "**/*.less", "**/*.scss", "**/*.sass", "**/*.css", "**/*.vue" },
		},
	},
}
