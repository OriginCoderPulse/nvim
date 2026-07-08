--- 检测并清理已登记但 git 仓库不完整的插件（clone 中断等）
local healthy = require("hooks.deps.healthy")

local function repair()
	local Pack = _G.Pack

	if vim.tbl_isempty(Pack.registry) and vim.tbl_isempty(Pack.active) then
		return
	end

	local names = {}
	for name in pairs(Pack.registry) do
		names[name] = true
	end
	for _, spec in ipairs(Pack.active) do
		names[Pack.parse(spec)] = true
	end
	for _, spec in ipairs(Pack.idle) do
		names[Pack.parse(spec)] = true
	end

	local to_delete = {}

	for name in pairs(names) do
		local dir = Pack.path(name)
		if dir and not healthy.healthy(dir) then
			to_delete[#to_delete + 1] = name
			healthy.invalidate(dir)
		end
	end

	if #to_delete == 0 then
		return
	end

	vim.notify("🔧 清理不完整插件: " .. table.concat(to_delete, ", "), vim.log.levels.WARN)
	vim.pack.del(to_delete)
end

return repair
