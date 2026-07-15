vim.cmd.packadd("Automic.pkg")

Pack.boot("packages.configs")
	:options("core.options")
	:keys("core.keymaps")
	:commands("core.commands")
	:lsp("core.lsp")
	:run()