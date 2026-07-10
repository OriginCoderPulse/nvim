--- :PackUpdate / :PackStatus 命令的插件名 Tab 补全（仅用户已登记配置）
--- Tab completion for :PackUpdate / :PackStatus (user-registered configs only)
local function complete(arg_lead)
	arg_lead = arg_lead or ""
	local Pack = _G.Pack
	local names = {}
	for name in pairs(Pack.registry or {}) do
		if name:lower():find(arg_lead:lower(), 1, true) == 1 then
			names[#names + 1] = name
		end
	end
	table.sort(names)
	return names
end

return complete
