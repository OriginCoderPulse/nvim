local state = require("hooks.lsp.state")
local stop = require("hooks.lsp.stop")

---@param name string
local function activate(name)
	name = state.norm(name)
	if state.disabled[name] or state.enabled[name] then
		return
	end
	state.enabled[name] = true
	vim.lsp.enable(name)
end

---@param name string
local function deactivate(name)
	name = state.norm(name)
	state.enabled[name] = nil
	vim.lsp.enable(name, false)
	stop(name)
end

return {
	activate = activate,
	deactivate = deactivate,
	stop = stop,
}
