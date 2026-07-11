Pack.register({
	"https://github.com/MeanderingProgrammer/render-markdown.nvim",
	module = "render-markdown",
}):load({
	event = "FileType",
	pattern = { "markdown" },
	once = true,
	config = function(plugin)
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
	end,
})
