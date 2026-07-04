if vim.g.vscode then
	return
end

local ensure_installed = {
	"json",
	"rust",
	"python",
	"lua",
	"markdown",
	"bash",
	"java",
	"javascript",
	"typescript",
	"tsx",
	"jsonc",
	"json5",
	"jsonnet",
	"jsonnet",
	"html",
	"css",
	"scss",
	"yaml",
	"vue",
}

local P = {
	spec = "https://github.com/nvim-treesitter/nvim-treesitter",
	module = "nvim-treesitter",
	build_cmd = ":TSUpdate",
}

PackUtils.register_plugin(P)

vim.api.nvim_create_autocmd("FileType", {
	pattern = ensure_installed,
	group = vim.api.nvim_create_augroup("NativeTreesitter", { clear = true }),
	callback = function(args)
		local buf = args.buf
		local ft = vim.bo[buf].filetype
		if ft == "" or ft == "yazi" or vim.bo[buf].buftype ~= "" then
			return
		end

		local max_filesize = 100 * 1024
		local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
		if ok and stats and stats.size > max_filesize then
			return
		end

		local lang = vim.treesitter.language.get_lang(ft) or ft
		if not vim.tbl_contains(ensure_installed, lang) then
			return
		end

		local no_err, is_added = pcall(vim.treesitter.language.add, lang)
		if not no_err or not is_added then
			PackUtils.load_plugin(P, function(plugin)
				vim.notify("🌱 Installing " .. lang .. " parser...", vim.log.levels.INFO)
				plugin.install({ lang }):wait(60000)
				pcall(vim.treesitter.language.add, lang)

				plugin.setup({
					install_dir = vim.fn.stdpath("data") .. "/site",
				})
			end)
		end

		pcall(vim.treesitter.start, buf, lang)
	end,
})
