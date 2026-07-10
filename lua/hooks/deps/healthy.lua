--- 判断 vim.pack 插件目录的 git 仓库是否完整（clone 成功、HEAD 可用）
--- Whether vim.pack plugin dir has a complete git repo (clone ok, HEAD usable)
local cache = {}

local function invalidate(path)
	if path then
		cache[path] = nil
	else
		cache = {}
	end
end

local function listen()
	local Pack = _G.Pack
	if not Pack then
		return
	end
	Pack._listeners = Pack._listeners or {}
	if Pack._listeners.healthy then
		return
	end
	Pack._listeners.healthy = true

	vim.api.nvim_create_autocmd("PackChanged", {
		group = vim.api.nvim_create_augroup("PackHealthyCache", { clear = true }),
		callback = function(ev)
			if ev.data and ev.data.path then
				invalidate(ev.data.path)
			else
				invalidate()
			end
		end,
	})
end

local function healthy(dir)
	listen()
	if not dir or vim.fn.isdirectory(dir) ~= 1 then
		return false
	end

	local cached = cache[dir]
	if cached ~= nil then
		return cached
	end

	local git_path = dir .. "/.git"
	local has_git = vim.fn.isdirectory(git_path) == 1 or vim.fn.filereadable(git_path) == 1
	if not has_git then
		-- 非 git 目录：非空视为健康，空目录视为不完整
		-- Non-git dir: non-empty is healthy; empty dir is incomplete
		for _ in vim.fs.dir(dir) do
			cache[dir] = true
			return true
		end
		cache[dir] = false
		return false
	end

	local result = vim.system({ "git", "-C", dir, "rev-parse", "--verify", "HEAD" }):wait()
	local ok = result.code == 0
	cache[dir] = ok
	return ok
end

return setmetatable({
	healthy = healthy,
	invalidate = invalidate,
}, {
	__call = function(_, dir)
		return healthy(dir)
	end,
})
