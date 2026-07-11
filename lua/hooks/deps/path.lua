--- 解析插件在 packpath 上的安装路径（优先 data/site/pack；带会话缓存）
--- Resolve install path on packpath (prefer data/site/pack; session-cached)
local cache = {}

local function listen()
	local Pack = _G.Pack
	if not Pack then
		return
	end
	Pack._listeners = Pack._listeners or {}
	if Pack._listeners.path then
		return
	end
	Pack._listeners.path = true
	vim.api.nvim_create_autocmd("PackChanged", {
		group = vim.api.nvim_create_augroup("PackPathCache", { clear = true }),
		callback = function(ev)
			local name = ev.data and ev.data.spec and ev.data.spec.name
			if name then
				cache[name] = nil
			else
				cache = {}
			end
		end,
	})
end

---@param name string
---@return string?
return function(name)
	listen()
	local Pack = _G.Pack
	name = Pack.parse(name)
	local hit = cache[name]
	if hit ~= nil then
		return hit ~= false and hit or nil
	end

	-- 快路径：vim.pack 默认 data/site/pack/core/{opt,start}/name
	-- Fast path: vim.pack default layout
	local data_pack = vim.fn.stdpath("data") .. "/site/pack"
	for _, kind in ipairs({ "opt", "start" }) do
		local p = data_pack .. "/core/" .. kind .. "/" .. name
		if vim.fn.isdirectory(p) == 1 then
			cache[name] = p
			return p
		end
	end

	local paths = vim.api.nvim_get_runtime_file("pack/*/*/" .. name, true)
	if #paths == 0 then
		paths = vim.fn.globpath(vim.o.packpath, "pack/*/*/" .. name, 0, 1)
	end
	if #paths == 0 then
		cache[name] = false
		return nil
	end
	for _, p in ipairs(paths) do
		if p:find(data_pack, 1, true) then
			cache[name] = p
			return p
		end
	end
	cache[name] = paths[1]
	return paths[1]
end
