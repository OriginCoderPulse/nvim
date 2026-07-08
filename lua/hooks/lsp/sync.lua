local state = require("hooks.lsp.state")
local control = require("hooks.lsp.control")

---@return table<string, boolean>
local function all_managed()
	local managed = {}
	for _, servers in pairs(state.filetypes) do
		for _, name in ipairs(servers) do
			managed[state.norm(name)] = true
		end
	end
	return managed
end

---@param ft string
---@return table<string, boolean>
local function wanted_for(ft)
	local want = {}
	local servers = state.filetypes[ft]
	if not servers then
		return want
	end
	for _, name in ipairs(servers) do
		want[state.norm(name)] = true
	end
	return want
end

---@param buf integer
---@return boolean
local function counts_for_lsp(buf)
	if not vim.api.nvim_buf_is_loaded(buf) then
		return false
	end
	local bt = vim.bo[buf].buftype
	if bt == "terminal" or bt == "prompt" or bt == "quickfix" then
		return false
	end
	return vim.bo[buf].filetype ~= ""
end

--- 汇总所有已加载 buffer 需要的 server
---@return table<string, boolean>
local function wanted_globally()
	local want = {}
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if counts_for_lsp(buf) then
			for name in pairs(wanted_for(vim.bo[buf].filetype)) do
				want[name] = true
			end
		end
	end
	return want
end

---@param buf? integer
---@param force? boolean
return function(buf, force)
	buf = buf or vim.api.nvim_get_current_buf()
	local ft = vim.bo[buf].filetype
	if not force and state.last_buf == buf and state.last_ft == ft then
		return
	end
	state.last_buf = buf
	state.last_ft = ft

	local want = wanted_globally()
	for name in pairs(all_managed()) do
		if state.disabled[name] then
		elseif want[name] then
			control.activate(name)
		else
			control.deactivate(name)
		end
	end
end
