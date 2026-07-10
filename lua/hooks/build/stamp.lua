--- build_cmd 指纹 stamp：cmd 变更后自动失效
local M = {}

local function stamp_path(dir)
	return dir .. "/.build_done"
end

local function fingerprint(build_cmd)
	if type(build_cmd) == "function" then
		-- 函数地址每次 reload 会变；用定义位置做稳定指纹（install/update 仍会清 stamp）
		local info = debug.getinfo(build_cmd, "S")
		return vim.fn.sha256(string.format("fn:%s:%s", info.source or "?", info.linedefined or 0))
	end
	if type(build_cmd) == "table" then
		return vim.fn.sha256(table.concat(build_cmd, "\0"))
	end
	return vim.fn.sha256(tostring(build_cmd))
end

function M.current(dir, build_cmd)
	if not dir or vim.fn.isdirectory(dir) ~= 1 then
		return false
	end
	local path = stamp_path(dir)
	if vim.fn.filereadable(path) == 0 then
		return false
	end
	local lines = vim.fn.readfile(path)
	return lines[1] == fingerprint(build_cmd)
end

function M.write(dir, build_cmd)
	vim.fn.writefile({ fingerprint(build_cmd) }, stamp_path(dir))
end

function M.clear(dir)
	pcall(vim.fn.delete, stamp_path(dir))
end

return M
