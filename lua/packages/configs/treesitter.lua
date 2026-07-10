-- filetype -> treesitter parser
local ft_parsers = {
	json = "json",
	jsonc = "jsonc",
	json5 = "json5",
	jsonnet = "jsonnet",
	rust = "rust",
	python = "python",
	lua = "lua",
	markdown = "markdown",
	bash = "bash",
	sh = "bash",
	java = "java",
	javascript = "javascript",
	javascriptreact = "javascript",
	typescript = "typescript",
	typescriptreact = "tsx",
	html = "html",
	css = "css",
	scss = "scss",
	yaml = "yaml",
	vue = "vue",
	ruby = "ruby",
}

local setup_done = false

Pack.register({
	spec = "https://github.com/nvim-treesitter/nvim-treesitter",
	module = "nvim-treesitter",
}):load({
	event = "FileType",
	pattern = vim.tbl_keys(ft_parsers),
	config = function(plugin)
		local buf = vim.api.nvim_get_current_buf()
		local ft = vim.bo[buf].filetype
		local lang = ft_parsers[ft]
		if not lang or ft == "yazi" or vim.bo[buf].buftype ~= "" then
			return
		end

		local max_filesize = 100 * 1024
		local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
		if ok and stats and stats.size > max_filesize then
			return
		end

		if not setup_done then
			plugin.setup({
				install_dir = vim.fn.stdpath("data") .. "/site",
			})
			setup_done = true
		end

		local no_err, is_added = pcall(vim.treesitter.language.add, lang)
		if not no_err or not is_added then
			vim.notify("🌱 Installing " .. lang .. " parser...", vim.log.levels.INFO)
			plugin.install({ lang }):wait(60000)
			pcall(vim.treesitter.language.add, lang)
		end

		pcall(vim.treesitter.start, buf, lang)
	end,
})
