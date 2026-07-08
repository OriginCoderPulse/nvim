local notify_once = require("hooks.util.notify_once")

local register_dep_tree

register_dep_tree = function(dep, consumer_name, disabled, ensure_spec)
	local Pack = _G.Pack
	local ok, item = pcall(Pack.norm, dep)
	if not ok then
		notify_once(
			"register:dep:" .. tostring(dep),
			"register 依赖解析失败 (" .. consumer_name .. "): " .. tostring(item),
			vim.log.levels.ERROR
		)
		return
	end

	Pack.track(dep, consumer_name)

	if disabled then
		if item.deps then
			for _, nested in ipairs(item.deps) do
				register_dep_tree(nested, consumer_name, disabled, ensure_spec)
			end
		end
		return
	end

	if item.spec then
		ensure_spec(Pack.active, item.spec)
	end
	if item.build_cmd then
		Pack.listen(item.name, item.build_cmd)
	end
	if item.deps then
		for _, nested in ipairs(item.deps) do
			register_dep_tree(nested, consumer_name, disabled, ensure_spec)
		end
	end
end

return register_dep_tree
