--- Pack.boot() 返回的链式句柄
--- Chainable handle returned by Pack.boot()
--- :custom({
---   -- hooks 之前
---   -- before hooks
---   { "core.options", immediately = true },
---   -- 最后加载（无需花括号）
---   -- load last (plain string ok)
---   "core.keymaps",
--- })
local resolve_config = require("hooks.boot.resolve")
local load_configs = require("hooks.boot.load_configs")
local require_mod = require("hooks.boot.require_mod")
local notify_once = require("hooks.util.notify_once")
local install = require("hooks.install")

--- headless 立即 schedule；否则等 UIEnter/VimEnter 一次
--- Headless: schedule now; else wait once for UIEnter/VimEnter
---@param install_fn fun()
local function schedule_install(install_fn)
	if #vim.api.nvim_list_uis() == 0 then
		vim.schedule(install_fn)
	else
		local done = false
		vim.api.nvim_create_autocmd({ "UIEnter", "VimEnter" }, {
			once = true,
			callback = function()
				if done then
					return
				end
				done = true
				vim.schedule(install_fn)
			end,
		})
	end
end

local M = {}
M.__index = M

---@class Pack.BootCustomEntry
---@field [1] string 模块路径，如 "core.options"
--- Module path, e.g. "core.options"
---@field immediately? boolean true：在 hooks（packages 配置）之前加载；缺省/false：最后加载（也可直接写字符串）
--- true: load before hooks (packages configs); default/false: load last (plain string also ok)

---@param config string
---@return Pack.BootHandle
function M.new(config)
	return setmetatable({
		_config = config,
		---@type Pack.BootCustomEntry[]
		_custom = {},
		_ran = false,
	}, M)
end

---@param entries? (string|Pack.BootCustomEntry)[]
---@return Pack.BootCustomEntry[]
local function normalize_custom(entries)
	local out = {}
	for _, item in ipairs(entries or {}) do
		if type(item) == "string" then
			out[#out + 1] = { item, immediately = false }
		elseif type(item) == "table" and type(item[1]) == "string" then
			out[#out + 1] = {
				item[1],
				immediately = item.immediately == true,
			}
		else
			vim.notify("Pack.boot:custom: 无效项 " .. vim.inspect(item), vim.log.levels.ERROR)
		end
	end
	return out
end

---@param entries Pack.BootCustomEntry[]
---@param immediately boolean
local function load_custom(entries, immediately)
	for _, item in ipairs(entries) do
		if (item.immediately == true) == immediately then
			require_mod(item[1])
		end
	end
end

--- 执行：immediately custom → packages 配置 → 非 immediately custom
--- Run: immediately custom → packages configs → remaining custom
---@return Pack
function M:run()
	local Pack = _G.Pack
	if Pack._booted then
		vim.notify("Pack.boot: 已启动，跳过重复 boot", vim.log.levels.WARN)
		return Pack
	end
	if self._ran then
		return Pack
	end
	self._ran = true

	local dir, prefix = resolve_config(self._config)
	if not dir or not prefix then
		self._ran = false
		return Pack
	end

	-- immediately：在 hooks / packages.configs 之前
	-- immediately: before hooks / packages.configs
	load_custom(self._custom, true)

	-- hooks 启动编排
	-- hooks boot orchestration
	notify_once.clear()
	Pack.restart()
	local configs_ok = load_configs(dir, prefix)
	if not configs_ok then
		vim.notify("插件配置加载失败，继续启动...", vim.log.levels.WARN)
	end
	Pack.load_listen()
	Pack._booted = true
	schedule_install(install)

	-- custom 默认最后加载
	-- remaining custom modules load last
	load_custom(self._custom, false)

	return Pack
end

--- 登记额外模块并启动。immediately=true 先于 hooks；其余最后加载。
--- Register extra modules and boot. immediately=true before hooks; others last.
---@param entries? (string|Pack.BootCustomEntry)[]
---@return Pack
function M:custom(entries)
	self._custom = normalize_custom(entries)
	return self:run()
end

return M
