--- Pack.boot() 返回的链式句柄
--- :custom({
---   { "core.options", immediately = true }, -- hooks 之前
---   "core.keymaps",                        -- 最后加载（无需花括号）
--- })
local resolve_config = require("hooks.boot.resolve")
local load_configs = require("hooks.boot.load_configs")
local require_mod = require("hooks.boot.require_mod")
local install = require("hooks.install")

local M = {}
M.__index = M

---@class Pack.BootCustomEntry
---@field [1] string 模块路径，如 "core.options"
---@field immediately? boolean true：在 hooks（packages 配置）之前加载；缺省/false：最后加载（也可直接写字符串）

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
---@return Pack
function M:run()
	local Pack = _G.Pack
	if self._ran or Pack._booted then
		return Pack
	end
	self._ran = true

	local dir, prefix = resolve_config(self._config)
	if not dir or not prefix then
		return Pack
	end

	-- 1) immediately：在 hooks / packages.configs 之前
	load_custom(self._custom, true)

	-- 2) hooks 启动编排
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

	-- 3) custom 默认最后加载
	load_custom(self._custom, false)

	return Pack
end

--- 登记额外模块并启动。immediately=true 先于 hooks；其余最后加载。
---@param entries? (string|Pack.BootCustomEntry)[]
---@return Pack
function M:custom(entries)
	self._custom = normalize_custom(entries)
	return self:run()
end

return M
