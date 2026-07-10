require("hooks")

Pack.boot("packages.configs"):custom({
	{ "core.options", immediately = true },
	"core.keymaps",
	"core.commands",
	"core.lsp",
})
