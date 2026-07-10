--- 登记 config 中的插件声明（spec / name / module / disabled / deps）
--- Register plugin declaration from config (spec / name / module / disabled / deps)
local cycle = require("hooks.deps.cycle")
local notify_once = require("hooks.util.notify_once")
local ensure_spec = require("hooks.register.ensure_spec")
local register_dep_tree = require("hooks.register.dep_tree")
local Handle = require("hooks.register.handle")

--- 重登记前移除该消费者在所有 dep 上的引用
--- Before re-register, remove this consumer from all dep ref lists
---@param consumer string
local function prune_refs(consumer)
	local Pack = _G.Pack
	for dep_name, refs in pairs(Pack.refs) do
		for i = #refs, 1, -1 do
			if refs[i] == consumer then
				table.remove(refs, i)
			end
		end
		if #refs == 0 then
			Pack.refs[dep_name] = nil
		end
	end
end

---@param P Pack.Plugin
---@return Pack.Handle|nil handle
return function(P)
	local Pack = _G.Pack
	if not P or not P.spec then
		return nil
	end

	local id_ok, id_err = pcall(Pack.identity, P)
	if not id_ok or not P.name then
		notify_once(
			"register:identity",
			"Pack.register: 无法解析插件名\n" .. tostring(id_err or "unknown"),
			vim.log.levels.ERROR
		)
		return nil
	end

	P.disabled = P.disabled == true

	local existing = Pack.registry[P.name]
	if existing and existing._registered then
		for k, v in pairs(P) do
			existing[k] = v
		end
		P = existing
	end

	local cycle_ok, cycle_err = cycle.check_tree(P.name, P.deps)
	if not cycle_ok then
		notify_once("register:cycle:" .. (P.name or "?"), cycle_err, vim.log.levels.ERROR)
		return nil
	end

	prune_refs(P.name)
	if P.deps then
		for _, dep in ipairs(P.deps) do
			register_dep_tree(dep, P.name, P.disabled, ensure_spec)
		end
	end

	if P.disabled then
		ensure_spec(Pack.idle, P.spec)
		Pack.disabled[P.name] = true
	else
		ensure_spec(Pack.active, P.spec)
		Pack.disabled[P.name] = nil
	end

	Pack.registry[P.name] = P
	P._registered = true

	if P.build_cmd then
		Pack.listen(P.name, P.build_cmd)
	end

	return Handle.new(P)
end
