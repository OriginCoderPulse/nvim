Pack.register({
	"https://github.com/Brandon-kk/CSA.nvim",
	module = "csa",
}):load({
	cmd = { "CSAToggle", "CSAsk", "CSAgents" },
	config = function(plugin)
		plugin.setup({
			language = "zh-CN",
			ui = {
				width = 0.30,
				border = "rounded",
				input = {
					height = 3,
					icon = "󰏫 ",
				},
				files = {
					enabled = false,
					max_visible = 3,
					icon = "󰈙",
				},
				output = {
					icon = "󰚩 ",
				},
			},
			identity = {
				icon = " ",
			},
			provider = {
				enabled = true,
				command = "cursor-agent",
				auth = {
					env = "CURSOR_API_KEY",
				},
				force = true,
				stream = true,
				trust = true,
			},
		})
	end,
})
