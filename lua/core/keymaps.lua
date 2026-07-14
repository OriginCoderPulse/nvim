vim.keymap.set("i", "jk", "<ESC>")

vim.keymap.set("n", "<leader>q", "<CMD>q<CR>")

vim.keymap.set("n", "<leader>b", "<C-o>")

vim.keymap.set("n", "<leader>ww", "<C-w><C-w>")

vim.keymap.set("n", "<leader>r", "<CMD>restart<CR>")

vim.keymap.set({ "n", "x", "o" }, "<CR>", function()
	vim.treesitter.select("parent")
end, { desc = "Treesitter: init/expand selection" })

vim.keymap.set({ "n", "x", "o" }, "<BS>", function()
	vim.treesitter.select("child")
end, { desc = "Treesitter: shrink selection" })

vim.keymap.set({ "n", "x", "o" }, "<Tab>", function()
	vim.treesitter.select("parent")
end, { desc = "Treesitter: expand scope" })

vim.keymap.set("n", "<leader>lg", function()
	Snacks.lazygit.open({
		win = { width = 0, height = 0, border = false, backdrop = false },
	})
end, { desc = "Open LazyGit" })

vim.keymap.set("n", "<leader>fh", function()
	Snacks.picker.help()
end, { desc = "Open snacks help" })

vim.keymap.set("n", "<leader>fp", function()
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
end, { desc = "Open snacks project" })

vim.keymap.set("n", "<leader>fd", function()
	Snacks.picker.diagnostics()
end, { desc = "Open snacks diagnostics" })

vim.keymap.set("n", "<leader>fc", function()
	Snacks.picker.lsp_config({
		layout = "select",
	})
end, { desc = "Open snacks help" })

vim.keymap.set("n", "<leader>e", function()
	Snacks.explorer()
end, { desc = "Open snacks explorer" })

vim.keymap.set("n", "<leader>ff", function()
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
end, { desc = "Find files" })

vim.keymap.set("n", "<leader>fo", function()
	Snacks.picker.recent({ layout = "select" })
end, { desc = "Find old files" })

vim.keymap.set("n", "<leader>fg", function()
	Snacks.picker.git_branches({ layout = "dropdown" })
end, { desc = "Search for differences across multiple commits on the same branch" })

vim.keymap.set("n", "<leader>fb", function()
	Snacks.picker.buffers({ layout = "select" })
end, { desc = "Search for differences across multiple commits on the same branch" })

vim.keymap.set("n", "<leader>fl", function()
	Snacks.picker.grep()
end, { desc = "Live grep" })

vim.keymap.set("n", "<leader>fr", function()
	vim.cmd.OverseerRun()
end, { desc = "Run overseer task" })

vim.keymap.set("n", "<leader>ft", function()
	vim.cmd.OverseerToggle()
end, { desc = "Toggle overseer task list" })
