--- 启动编排：返回链式句柄，:custom() 或延后自动 :run()
--- 顺序：custom(immediately=true) → packages 配置 → custom(其余，最后)
local Handle = require("hooks.boot.handle")

---@param config string
---@return Pack.BootHandle
return function(config)
	local handle = Handle.new(config)

	-- 仅 boot() 未接 :custom() 时，在当前脚本后续逻辑跑完后自动启动
	vim.schedule(function()
		if not handle._ran then
			handle:run()
		end
	end)

	return handle
end
