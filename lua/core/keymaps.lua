return {
	{ "i", "jk", "<ESC>" },
	{ "n", "<leader>q", "<CMD>q<CR>" },
	{ "n", "<leader>b", "<C-o>" },
	{ "n", "<leader>ww", "<C-w><C-w>" },
	{ "n", "<leader>r", "<CMD>restart<CR>" },
	{
		"n",
		"gd",
		vim.lsp.buf.definition,
		{ desc = "LSP: Go To Definition", event = "LspAttach" },
	},
	{
		"n",
		"gD",
		vim.lsp.buf.declaration,
		{ desc = "LSP: Go To Declaration", event = "LspAttach" },
	},
	{
		"n",
		"<leader>ld",
		function()
			vim.diagnostic.open_float({ source = true })
		end,
		{ desc = "LSP: Line Diagnostics", event = "LspAttach" },
	},
	{
		{ "n", "x", "o" },
		"<CR>",
		function()
			vim.treesitter.select("parent")
		end,
		{ desc = "Treesitter: init/expand selection", event = "FileType" },
	},
	{
		{ "n", "x", "o" },
		"<BS>",
		function()
			vim.treesitter.select("child")
		end,
		{ desc = "Treesitter: shrink selection", event = "FileType" },
	},
	{
		{ "n", "x", "o" },
		"<Tab>",
		function()
			vim.treesitter.select("parent")
		end,
		{ desc = "Treesitter: expand scope", event = "FileType" },
	},
	{
		"n",
		"<leader>lg",
		function()
			Snacks.lazygit.open({
				win = { width = 0, height = 0, border = false, backdrop = false },
			})
		end,
		{ desc = "Open LazyGit" },
	},
	{
		"n",
		"<leader>fh",
		function()
			Snacks.picker.help()
		end,
		{ desc = "Open snacks help" },
	},
	{
		"n",
		"<leader>fp",
		function()
			Snacks.picker.projects({
				layout = {
					preset = "vscode",
					layout = {
						width = 0.4,
						height = 0.3,
						min_width = 40,
						border = nil,
					},
				},
			})
		end,
		{ desc = "Open snacks project" },
	},
	{
		"n",
		"<leader>fd",
		function()
			Snacks.picker.diagnostics()
		end,
		{ desc = "Open snacks diagnostics" },
	},
	{
		"n",
		"<leader>fc",
		function()
			Snacks.picker.lsp_config({
				layout = "select",
			})
		end,
		{ desc = "Open snacks LSP config" },
	},
	{
		"n",
		"<leader>e",
		function()
			Snacks.explorer()
		end,
		{ desc = "Open snacks explorer" },
	},
	{
		"n",
		"<leader>ff",
		function()
			Snacks.picker.files({
				layout = {
					preset = "select",
					layout = {
						width = 0.5,
						height = 0.6,
						min_width = 80,
					},
				},
			})
		end,
		{ desc = "Find files" },
	},
	{
		"n",
		"<leader>fo",
		function()
			Snacks.picker.recent({ layout = "select" })
		end,
		{ desc = "Find old files" },
	},
	{
		"n",
		"<leader>fg",
		function()
			Snacks.picker.git_branches({ layout = "dropdown" })
		end,
		{ desc = "Git branches" },
	},
	{
		"n",
		"<leader>fb",
		function()
			Snacks.picker.buffers({ layout = "select" })
		end,
		{ desc = "Find buffers" },
	},
	{
		"n",
		"<leader>fl",
		function()
			Snacks.picker.grep()
		end,
		{ desc = "Live grep" },
	},
}
