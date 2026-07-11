--- 持久化构建失败列表（供 :PackReBuild；不影响 stamp / 下次启动 batch）
--- Persist failed builds for :PackReBuild (does not replace stamp / next-boot batch)
local path = vim.fn.stdpath("state") .. "/pack-hooks-build-failed.json"

local M = {}
--- 会话内缓存，避免并行 build 同时 read-modify-write 丢项
--- Session cache so parallel builds do not clobber each other on disk
local cache = nil

---@return table<string, boolean>
local function read()
	if cache then
		return cache
	end
	if vim.fn.filereadable(path) == 0 then
		cache = {}
		return cache
	end
	local ok, decoded = pcall(vim.json.decode, table.concat(vim.fn.readfile(path), "\n"))
	if not ok or type(decoded) ~= "table" then
		cache = {}
		return cache
	end
	local set = {}
	if decoded[1] ~= nil then
		for _, name in ipairs(decoded) do
			if type(name) == "string" and name ~= "" then
				set[name] = true
			end
		end
	else
		for name, v in pairs(decoded) do
			if v and type(name) == "string" then
				set[name] = true
			end
		end
	end
	cache = set
	return cache
end

---@param set table<string, boolean>
local function write(set)
	cache = set
	local list = {}
	for name in pairs(set) do
		list[#list + 1] = name
	end
	table.sort(list)
	vim.fn.writefile({ vim.json.encode(list) }, path)
end

---@return string[]
function M.list()
	local set = read()
	local list = {}
	for name in pairs(set) do
		list[#list + 1] = name
	end
	table.sort(list)
	return list
end

---@param name string
function M.add(name)
	local set = read()
	set[name] = true
	write(set)
end

---@param name string
function M.remove(name)
	local set = read()
	if set[name] then
		set[name] = nil
		write(set)
	end
end

return M
