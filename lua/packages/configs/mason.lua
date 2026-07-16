-- Keep mason bins on PATH before the UI package loads (LSP cmds resolve via PATH).
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
if vim.fn.isdirectory(mason_bin) == 1 and not vim.env.PATH:find(mason_bin, 1, true) then
	vim.env.PATH = mason_bin .. ":" .. vim.env.PATH
end

Pack.register({
	"https://github.com/mason-org/mason.nvim",
	module = "mason",
	dependencies = {
		"https://github.com/mason-org/mason-registry",
	},
}):load({
	cmd = "Mason",
	config = function(plugin)
		plugin.setup({
			PATH = "skip",
			ui = {
				width = 0.65,
				height = 0.75,
			},
		})
	end,
})
