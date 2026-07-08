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
vim.opt.showtabline = 0
vim.opt.ruler = false
vim.opt.winblend = 0
vim.opt.fillchars = "eob: "
vim.opt.wildignore = "node_modules/,*.yaml,*.log,*.lock,package.json"
vim.opt.winborder = "rounded"
vim.opt.confirm = false
vim.opt.splitright = true
vim.opt.laststatus = 0

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

Pack.lsp.enable({
	lua = { "lua_ls" },
	rust = { "rust_ls" },
	json = { "jsonls" },
	jsonc = { "jsonls" },
	javascript = { "ts_ls" },
	javascriptreact = { "ts_ls", "emmet_ls" },
	typescript = { "ts_ls" },
	typescriptreact = { "ts_ls", "emmet_ls" },
	vue = { "ts_ls", "vue_ls", "emmet_ls", "css_variables" },
	css = { "emmet_ls", "css_variables" },
	scss = { "emmet_ls", "css_variables" },
	less = { "emmet_ls", "css_variables" },
	sass = { "emmet_ls", "css_variables" },
	html = { "emmet_ls" },
})
