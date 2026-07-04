--- 判断 vim.pack 插件目录的 git 仓库是否完整（clone 成功、HEAD 可用）
local function is_install_healthy(path)
	if not path or vim.fn.isdirectory(path) ~= 1 then
		return false
	end
	if vim.fn.isdirectory(path .. "/.git") ~= 1 then
		return false
	end
	local result = vim.system({ "git", "-C", path, "rev-parse", "--verify", "HEAD" }):wait()
	return result.code == 0
end

return is_install_healthy
