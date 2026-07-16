return {
	{ "i", "jk", "<ESC>" },
	{ "n", "<leader>q", "<CMD>q<CR>" },
	{ "n", "<leader>b", "<C-o>" },
	{ "n", "<leader>ww", "<C-w><C-w>" },
	{ "n", "<leader>r", "<CMD>restart<CR>" },
	{
		{ "n", "x", "o" },
		"<CR>",
		function()
			vim.treesitter.select("parent")
		end,
		{ desc = "Treesitter: init/expand selection" },
	},
	{
		{ "n", "x", "o" },
		"<BS>",
		function()
			vim.treesitter.select("child")
		end,
		{ desc = "Treesitter: shrink selection" },
	},
	{
		{ "n", "x", "o" },
		"<Tab>",
		function()
			vim.treesitter.select("parent")
		end,
		{ desc = "Treesitter: expand scope" },
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
		{ desc = "Open snacks help" },
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
		{ desc = "Search for differences across multiple commits on the same branch" },
	},
	{
		"n",
		"<leader>fb",
		function()
			Snacks.picker.buffers({ layout = "select" })
		end,
		{ desc = "Search for differences across multiple commits on the same branch" },
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
