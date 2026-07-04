return {
	cmd = { "vue-language-server", "--stdio" },
	filetypes = { "vue" },
	root_dir = PackUtils.lsp_root_dir({
		"package.json",
		"jsconfig.json",
		"tsconfig.json",
		"pnpm-workspace.yaml",
	}),
	on_init = function(client)
		local retries = 0

		local function typescriptHandler(_, result, context)
			local ts_client = vim.lsp.get_clients({ bufnr = context.bufnr, name = "ts_ls" })[1]
				or vim.lsp.get_clients({ bufnr = context.bufnr, name = "vtsls" })[1]

			if not ts_client then
				if retries <= 10 then
					retries = retries + 1
					vim.defer_fn(function()
						typescriptHandler(_, result, context)
					end, 100)
				else
					vim.notify("vue_ls 需要 ts_ls 协作，但未找到 ts_ls client", vim.log.levels.ERROR)
				end
				return
			end

			local param = unpack(result)
			local id, command, payload = unpack(param)
			ts_client:exec_cmd({
				title = "vue_request_forward",
				command = "typescript.tsserverRequest",
				arguments = { command, payload },
			}, { bufnr = context.bufnr }, function(_, r)
				client:notify("tsserver/response", { { id, r and r.body } })
			end)
		end

		client.handlers["tsserver/request"] = typescriptHandler
	end,
}
