--- 登记 config 中的插件声明（spec / name / module / disabled / deps）
local cycle = require("hooks.deps.cycle")
local notify_once = require("hooks.util.notify_once")
local ensure_spec = require("hooks.register.ensure_spec")
local register_dep_tree = require("hooks.register.dep_tree")

---@param P table
return function(P)
	local Pack = _G.Pack
	if not P or not P.spec then
		return
	end

	local id_ok, id_err = pcall(Pack.identity, P)
	if not id_ok or not P.name then
		notify_once(
			"register:identity",
			"Pack.register: 无法解析插件名\n" .. tostring(id_err or "unknown"),
			vim.log.levels.ERROR
		)
		return
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
		return
	end

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
end
