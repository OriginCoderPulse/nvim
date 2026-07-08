--- :PackUpdate / :PackStatus 命令的插件名 Tab 补全
local function complete(arg_lead)
	arg_lead = arg_lead or ""
	local installed = vim.pack.get(nil, { info = false })
	local names = {}
	for _, p in ipairs(installed) do
		local name = p.spec.name
		if name:lower():find(arg_lead:lower(), 1, true) == 1 then
			table.insert(names, name)
		end
	end
	table.sort(names)
	return names
end

return complete
