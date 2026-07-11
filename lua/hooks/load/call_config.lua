--- 调用 config：setfenv 注入 env（主插件为 var，不含 utils）
--- Call config with env injected via setfenv (main plugin: var only, no utils)
---
--- lua_ls：Pack.lsp activate 时挂载 lsp_plugin/pack_utils.lua（不在 hooks 启动时碰 vim.lsp）
--- lua_ls: attach pack_utils.lua on Pack.lsp activate (do not touch vim.lsp at hooks boot)
---@param config_fn function
---@param plugin any
---@param env? table
---@return boolean ok
---@return any err
return function(config_fn, plugin, env)
	if type(env) == "table" and next(env) then
		if not getmetatable(env) then
			setmetatable(env, { __index = _G })
		end
		setfenv(config_fn, env)
	end
	return pcall(config_fn, plugin)
end
