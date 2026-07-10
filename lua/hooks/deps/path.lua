--- 解析插件在 packpath 上的安装路径（优先 data/site/pack）
--- Resolve install path on packpath (prefer data/site/pack)
---@param name string
---@return string?
return function(name)
	local Pack = _G.Pack
	name = Pack.parse(name)
	local paths = vim.api.nvim_get_runtime_file("pack/*/*/" .. name, true)
	if #paths == 0 then
		local glob = vim.fn.globpath(vim.o.packpath, "pack/*/*/" .. name, 0, 1)
		paths = glob
	end
	if #paths == 0 then
		return nil
	end
	local data_pack = vim.fn.stdpath("data") .. "/site/pack"
	for _, p in ipairs(paths) do
		if p:find(data_pack, 1, true) then
			return p
		end
	end
	return paths[1]
end
