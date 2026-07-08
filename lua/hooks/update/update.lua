local filter_targets = require("hooks.update.filter")

--- 过滤 lock = true 的插件及其依赖后调用 vim.pack.update
---@param targets? string[]
---@param opts? table
return function(targets, opts)
	local filtered, skipped = filter_targets(targets)
	if #skipped > 0 then
		vim.notify(
			"以下 lock 插件已跳过更新: " .. table.concat(skipped, ", "),
			vim.log.levels.INFO
		)
	end
	if #filtered == 0 then
		return nil
	end
	return vim.pack.update(filtered, opts)
end
