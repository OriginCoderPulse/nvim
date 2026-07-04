if vim.g.vscode then
	return
end

local P = {
	spec = "https://github.com/MeanderingProgrammer/render-markdown.nvim",
	module = "render-markdown",
}

PackUtils.register_plugin(P)

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown" },
	callback = function()
		PackUtils.load_plugin(P, function(plugin)
			plugin.setup({
				file_types = { "markdown" },
				bullet = {
					highlight = "RenderMarkdownH2",
					icons = { "●", "○", "◆", "◇" },
				},
				heading = {
					position = "inline",
					icons = { "󰉫 ", "󰉬 ", "󰉭 ", "󰉮 ", "󰉯 ", "󰉰 " },
					backgrounds = {
						"RenderMarkdownH1",
						"RenderMarkdownH2",
						"RenderMarkdownH3",
						"RenderMarkdownH4",
						"RenderMarkdownH5",
						"RenderMarkdownH6",
					},
					foregrounds = {
						"RenderMarkdownH1",
						"RenderMarkdownH2",
						"RenderMarkdownH3",
						"RenderMarkdownH4",
						"RenderMarkdownH5",
						"RenderMarkdownH6",
					},
				},
				quote = {},
				dash = { icon = "" },
				code = {
					above = "",
					below = "",
					highlight = "",
					highlight_inline = "",
				},
				pipe_table = {
					preset = "round",
					row = "@markup.row",
				},
				win_options = { concealcursor = { rendered = "nvc" } },
				completions = {
					blink = { enabled = true },
					lsp = { enabled = true },
				},
				anti_conceal = {
					disabled_modes = { "n" },
				},
			})
		end)
	end,
})
