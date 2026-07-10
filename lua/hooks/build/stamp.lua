--- build_cmd 指纹 stamp：cmd 变更后自动失效
--- build_cmd fingerprint stamp: invalidate when cmd changes
local M = {}

local function stamp_path(dir)
	return dir .. "/.build_done"
end

---@param build_cmd string|string[]|function
---@param build_id? string
local function fingerprint(build_cmd, build_id)
	local base
	if type(build_cmd) == "function" then
		-- 函数地址每次 reload 会变；用定义位置做稳定指纹（install/update 仍会清 stamp）
		-- Function address changes on reload; use def location as stable fingerprint (install/update still clear stamp)
		local info = debug.getinfo(build_cmd, "S")
		base = string.format(
			"fn:%s:%s:%s",
			info.source or "?",
			info.linedefined or 0,
			info.lastlinedefined or 0
		)
	elseif type(build_cmd) == "table" then
		base = table.concat(build_cmd, "\0")
	else
		base = tostring(build_cmd)
	end
	if build_id then
		base = base .. "\0" .. tostring(build_id)
	end
	return vim.fn.sha256(base)
end

---@param dir string
---@param build_cmd string|string[]|function
---@param build_id? string
function M.current(dir, build_cmd, build_id)
	if not dir or vim.fn.isdirectory(dir) ~= 1 then
		return false
	end
	local path = stamp_path(dir)
	if vim.fn.filereadable(path) == 0 then
		return false
	end
	local lines = vim.fn.readfile(path)
	return lines[1] == fingerprint(build_cmd, build_id)
end

---@param dir string
---@param build_cmd string|string[]|function
---@param build_id? string
function M.write(dir, build_cmd, build_id)
	vim.fn.writefile({ fingerprint(build_cmd, build_id) }, stamp_path(dir))
end

function M.clear(dir)
	pcall(vim.fn.delete, stamp_path(dir))
end

return M
