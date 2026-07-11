--- 登记 config 中的插件声明
--- Register plugin declaration from config
---
--- 用法 / Usage:
---   Pack.register("https://github.com/user/plug", { module = "plug" })
---   Pack.register({ "https://...", module = "plug" }):load({ utils = { menu = "plug.menu" }, var = {...}, config = fn })
---   Pack.register({ spec = { src = "...", name = "..." }, module = "..." })
local cycle = require("hooks.deps.cycle")
local notify_once = require("hooks.util.notify_once")
local ensure_spec = require("hooks.register.ensure_spec")
local register_dep_tree = require("hooks.register.dep_tree")
local Handle = require("hooks.register.handle")
local identity = require("hooks.register.identity")
local listen = require("hooks.build.listen")

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

--- 规范化 register 参数：字符串首参 → spec.src；spec 仅允许 table
--- Normalize register args: leading string → spec.src; spec must be a table
--- 始终拷贝，不修改调用方传入的表
--- Always copy; never mutate the caller's table
---@param src_or_plugin string|table
---@param opts? table
---@return Pack.Plugin|nil
local function normalize_plugin(src_or_plugin, opts)
	local P
	if type(src_or_plugin) == "string" then
		P = vim.tbl_deep_extend("force", {}, opts or {})
		if P.spec ~= nil then
			notify_once(
				"register:spec_conflict",
				"Pack.register: 首参已是 URL 时不要再传 spec 字段",
				vim.log.levels.ERROR
			)
			return nil
		end
		P.spec = { src = src_or_plugin }
	elseif type(src_or_plugin) == "table" then
		P = vim.tbl_deep_extend("force", {}, src_or_plugin)
		-- 表内 [1] 字符串：单行地址简写
		-- Table [1] string: one-line URL shorthand
		if type(P[1]) == "string" then
			local src = P[1]
			P[1] = nil
			if P.spec ~= nil then
				notify_once(
					"register:spec_conflict",
					"Pack.register: 已有 [1] URL 时不要再传 spec 字段",
					vim.log.levels.ERROR
				)
				return nil
			end
			P.spec = { src = src }
		end
	else
		return nil
	end

	if type(P.spec) == "string" then
		notify_once(
			"register:spec_string",
			"Pack.register: spec 只能是 table；单行地址请写 Pack.register(\"url\", { ... })",
			vim.log.levels.ERROR
		)
		return nil
	end
	if type(P.spec) ~= "table" or type(P.spec.src) ~= "string" or P.spec.src == "" then
		notify_once(
			"register:spec_invalid",
			"Pack.register: 需要 spec = { src = \"...\" } 或首参 URL 字符串",
			vim.log.levels.ERROR
		)
		return nil
	end

	return P
end

---@param src_or_plugin string|Pack.Plugin
---@param opts? Pack.Plugin
---@return Pack.Handle|nil handle
return function(src_or_plugin, opts)
	local Pack = _G.Pack
	local P = normalize_plugin(src_or_plugin, opts)
	if not P then
		return nil
	end

	local id_ok, id_err = pcall(identity, P)
	if not id_ok or not P.name then
		notify_once(
			"register:identity",
			"Pack.register: 无法解析插件名\n" .. tostring(id_err or "unknown"),
			vim.log.levels.ERROR
		)
		return nil
	end

	if type(P.module) ~= "string" or P.module == "" then
		notify_once(
			"register:module",
			"Pack.register(" .. P.name .. "): module 为必填字符串（不再从 name 猜测）",
			vim.log.levels.ERROR
		)
		return nil
	end

	if P.utils ~= nil then
		notify_once(
			"register:utils",
			"Pack.register(" .. P.name .. "): utils moved to :load({ utils = ... })",
			vim.log.levels.ERROR
		)
		return nil
	end
	if P.var ~= nil then
		notify_once(
			"register:var",
			"Pack.register(" .. P.name .. "): var belongs on :load({ var = ... })",
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
		-- pairs 不会带上显式 nil；省略的字段需清掉，避免残留
		-- pairs skips explicit nil; clear omitted fields to avoid stale data
		if rawget(P, "dependencies") == nil then
			existing.dependencies = nil
		end
		if rawget(P, "build") == nil then
			existing.build = nil
		end
		existing.utils = nil
		existing.var = nil
		P = existing
	end

	local cycle_ok, cycle_err = cycle.check_tree(P.name, P.dependencies)
	if not cycle_ok then
		notify_once("register:cycle:" .. (P.name or "?"), cycle_err, vim.log.levels.ERROR)
		return nil
	end

	prune_refs(P.name)
	if P.dependencies then
		for _, dep in ipairs(P.dependencies) do
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

	-- 始终同步 cmds：去掉 build 时必须 cmds.set(nil)
	-- Always sync cmds: clearing build must cmds.set(nil)
	listen(P.name, P.build)

	return Handle.new(P)
end
