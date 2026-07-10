--- 按当前 buffer filetype 同步 enable/disable LSP
--- Sync enable/disable LSP by current buffer filetype
local state = require("hooks.lsp.state")
local control = require("hooks.lsp.control")
local sync = require("hooks.lsp.sync")
local listen = require("hooks.lsp.listen")

local M = {}

local function activate()
	if state.activated then
		return
	end
	state.activated = true
	state.lazy_pending = false
	listen()
	sync(nil, true)
end

---@param map table<string, string|string[]>
function M.enable(map)
	if type(map) ~= "table" then
		vim.notify("Pack.lsp.enable: 需要 filetype → server 映射 table", vim.log.levels.ERROR)
		return
	end

	for ft, servers in pairs(map) do
		if type(servers) == "string" then
			servers = { servers }
		end
		state.filetypes[ft] = servers
		for _, name in ipairs(servers) do
			state.disabled[state.norm(name)] = nil
		end
	end

	-- 已激活：只合并映射并同步
	-- Already activated: merge map and sync only
	if state.activated then
		sync(nil, true)
		return
	end

	-- 内部登记：首个 FileType 再真正碰 vim.lsp
	-- Internal register: touch vim.lsp only on first FileType
	if not state.lazy_pending then
		state.lazy_pending = true
		vim.api.nvim_create_autocmd("FileType", {
			once = true,
			desc = "Pack.lsp.enable: load vim.lsp on first FileType",
			callback = function()
				vim.schedule(activate)
			end,
		})
	end

	-- 已有带 filetype 的 buffer 时立即激活
	-- Activate now if any loaded buffer already has a filetype
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype ~= "" then
			vim.schedule(activate)
			break
		end
	end
end

---@param name string
function M.disable(name)
	name = state.norm(name)
	state.disabled[name] = true
	state.enabled[name] = nil
	if state.activated then
		vim.lsp.enable(name, false)
		control.stop(name)
	end
end

---@return boolean
function M.is_enabled(name)
	name = state.norm(name)
	return state.enabled[name] == true
end

---@return boolean
function M.is_disabled(name)
	name = state.norm(name)
	return state.disabled[name] == true
end

return M
