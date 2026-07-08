--- 启动编排：resolve → restart 监听 → 加载配置 → load 监听 → UIEnter install
local resolve_config = require("hooks.boot.resolve")
local load_configs = require("hooks.boot.load_configs")
local install = require("hooks.install")

---@param config string
return function(config)
	local Pack = _G.Pack
	if Pack._booted then
		return Pack
	end

	local dir, prefix = resolve_config(config)
	if not dir or not prefix then
		return Pack
	end

	Pack.restart()
	if not load_configs(dir, prefix) then
		return Pack
	end
	Pack.load_listen()
	Pack._booted = true

	vim.api.nvim_create_autocmd("UIEnter", {
		once = true,
		callback = function()
			vim.schedule(install)
		end,
	})

	return Pack
end
