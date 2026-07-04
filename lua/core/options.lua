-- === 自定义配置 ===

vim.g.mapleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.termguicolors = true
vim.g.markdown_fenced_languages = { "ts=typescript", "js=javascript" }

vim.opt.mouse = ""
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.numberwidth = 4
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.clipboard = "unnamedplus"
vim.opt.cursorline = true
vim.opt.signcolumn = "auto"
vim.opt.pumheight = 10
vim.opt.pumwidth = 10
vim.opt.autoread = true
vim.opt.showmode = false
vim.opt.winblend = 0
vim.opt.fillchars = "eob: "
vim.opt.wildignore = "node_modules/,*.yaml,*.log,*.lock,package.json"
vim.opt.winborder = "rounded"
vim.opt.confirm = false
vim.opt.splitright = true
vim.opt.laststatus = 0
vim.opt.showtabline = 0

vim.diagnostic.config({
	virtual_text = true,
	severity_sort = true,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "󰗖 ",
			[vim.diagnostic.severity.WARN] = "󰗖 ",
			[vim.diagnostic.severity.INFO] = "󰗖 ",
			[vim.diagnostic.severity.HINT] = "󰗖 ",
		},
	},
})

vim.lsp.enable({ "lua_ls", "jsonls", "ts_ls", "vue_ls", "css_variables", "emmet_language_server" })
