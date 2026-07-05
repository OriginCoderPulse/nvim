--- 判断 vim.pack 插件目录的 git 仓库是否完整（clone 成功、HEAD 可用）
local function healthy(dir)
	if not dir or vim.fn.isdirectory(dir) ~= 1 then
		return false
	end
	if vim.fn.isdirectory(dir .. "/.git") ~= 1 then
		return false
	end
	local result = vim.system({ "git", "-C", dir, "rev-parse", "--verify", "HEAD" }):wait()
	return result.code == 0
end

return healthy
