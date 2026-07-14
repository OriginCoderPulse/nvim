vim.cmd.packadd("OP.nvim")

require("op")

Pack.boot("packages.configs"):custom({
	"core.options",
	"core.keymaps",
	"core.commands",
	"core.lsp",
})
