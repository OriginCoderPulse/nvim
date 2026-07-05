--- 若存在 build_cmd 且尚未构建，则触发 build
local function ensure(name, build_cmd)
	local Pack = _G.Pack
	name = Pack.parse(name)
	if Pack.disabled[name] then
		return
	end
	if not build_cmd then
		return
	end
	local dir = Pack.path(name)
	if dir then
		local stamp = dir .. "/.build_done"
		if vim.fn.filereadable(stamp) == 0 then
			Pack.build(name, build_cmd)
		end
	end
end

return ensure
