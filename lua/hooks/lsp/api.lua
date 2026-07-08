--- 按当前 buffer filetype 同步 enable/disable LSP
local state = require("hooks.lsp.state")
local control = require("hooks.lsp.control")
local sync = require("hooks.lsp.sync")
local listen = require("hooks.lsp.listen")

local M = {}

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

	listen()
	sync(nil, true)
end

---@param name string
function M.disable(name)
	name = state.norm(name)
	state.disabled[name] = true
	state.enabled[name] = nil
	vim.lsp.enable(name, false)
	control.stop(name)
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
