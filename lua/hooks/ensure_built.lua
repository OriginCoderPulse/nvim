--- 若存在 build_cmd 且尚未构建，则触发 execute_build
local function ensure_built(name, build_cmd)
	local PackUtils = _G.PackUtils
	name = PackUtils.parse_spec_name(name)
	if PackUtils.disabled_plugins[name] then
		return
	end
	if not build_cmd then
		return
	end
	local path = PackUtils.resolve_plugin_path(name)
	if path then
		local stamp = path .. "/.build_done"
		if vim.fn.filereadable(stamp) == 0 then
			PackUtils.execute_build(name, build_cmd)
		end
	end
end

return ensure_built
