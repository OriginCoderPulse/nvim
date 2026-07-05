--- 解析插件在 packpath 上的安装路径
local function path(name)
	local Pack = _G.Pack
	name = Pack.parse(name)
	local paths = vim.api.nvim_get_runtime_file("pack/*/*/" .. name, true)
	if #paths > 0 then
		return paths[1]
	end
	local glob = vim.fn.globpath(vim.o.packpath, "pack/*/*/" .. name, 0, 1)
	return glob[1] or nil
end

return path
