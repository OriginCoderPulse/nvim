--- 启动插件系统：加载配置、注册重启监听、同步 eager 依赖、UIEnter 后安装
local load = require("hooks.load")
local install = require("hooks.install")

---@param config string Lua 模块前缀（如 packages.configs）或配置文件目录绝对路径
local function resolve_config(config)
	if config:find("[/\\]") then
		local dir = config
		if vim.fn.isdirectory(dir) ~= 1 then
			return nil, nil
		end
		local lua_root = vim.fn.stdpath("config") .. "/lua/"
		if dir:sub(1, #lua_root) == lua_root then
			return dir, dir:sub(#lua_root + 1):gsub("/", ".")
		end
		vim.notify("Pack.boot: 目录不在 config/lua 下，无法解析模块名: " .. dir, vim.log.levels.ERROR)
		return nil, nil
	end

	local prefix = config
	local dir = vim.fn.stdpath("config") .. "/lua/" .. prefix:gsub("%.", "/")
	if vim.fn.isdirectory(dir) ~= 1 then
		vim.notify("Pack.boot: 配置目录不存在: " .. dir, vim.log.levels.ERROR)
		return nil, nil
	end
	return dir, prefix
end

local function load_configs(dir, prefix)
	for name, ftype in vim.fs.dir(dir) do
		if ftype == "file" and name:match("%.lua$") then
			local mod = prefix .. "." .. name:gsub("%.lua$", "")
			local ok, err = pcall(require, mod)
			if not ok then
				vim.notify("插件配置加载失败: " .. mod .. "\n" .. tostring(err), vim.log.levels.ERROR)
			end
		end
	end
end

---@param config string
local function boot(config)
	local Pack = _G.Pack
	if Pack._booted then
		return Pack
	end
	Pack._booted = true

	local dir, prefix = resolve_config(config)
	if not dir or not prefix then
		return Pack
	end

	Pack.restart()
	load_configs(dir, prefix)
	load.eager()

	-- UIEnter 且晚于 noice.lua 注册，确保 Noice cmdline 已接管再执行 vim.pack.add
	vim.api.nvim_create_autocmd("UIEnter", {
		once = true,
		callback = function()
			vim.schedule(install)
		end,
	})

	return Pack
end

return boot
