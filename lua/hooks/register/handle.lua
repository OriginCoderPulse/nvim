--- Pack.register() 返回的链式句柄：:load({ event, defer, utils, var, config, ...autocmd })
--- Chainable handle from Pack.register(): :load({ event, defer, utils, var, config, ...autocmd })
local M = {}
M.__index = M

local pack_load = require("hooks.load.load")
local config_deps = require("hooks.load.config_deps")
local ensure = require("hooks.build.ensure")
local require_utils = require("hooks.load.require_utils")
local build_env = require("hooks.load.build_env")
local call_config = require("hooks.load.call_config")
local run_var_use = require("hooks.load.run_var_use")
local notify_once = require("hooks.util.notify_once")

---@param P Pack.Plugin
---@return Pack.Handle handle
function M.new(P)
	return setmetatable({ P = P }, M)
end

---@param opts? Pack.LoadOpts
---@return Pack.Handle self
function M:load(opts)
	opts = opts or {}
	local P = self.P
	local Pack = _G.Pack

	local function run()
		local go = function()
			-- 已 init：跳过 config / var_use（与依赖 config_deps 守卫对齐）
			-- Already inited: skip config / var_use (align with dep config_deps guard)
			if Pack.inited[P.name] then
				if not Pack.loaded[P.name] then
					pack_load(P)
				end
				return
			end

			if not pack_load(P) then
				return
			end

			local utils, utils_err = require_utils(opts.utils)
			if not utils then
				Pack.loaded[P.name] = nil
				notify_once(
					"handle:utils:" .. P.name,
					"Pack.handle:load(" .. P.name .. "): utils failed\n" .. tostring(utils_err),
					vim.log.levels.ERROR
				)
				return
			end

			local _, config_env, use_list, env_err = build_env.build(utils, opts.var)
			if not config_env then
				Pack.loaded[P.name] = nil
				notify_once(
					"handle:var:" .. P.name,
					"Pack.handle:load(" .. P.name .. "): var/utils env failed\n" .. tostring(env_err),
					vim.log.levels.ERROR
				)
				return
			end

			if P.dependencies and not config_deps.tree(P.dependencies) then
				Pack.loaded[P.name] = nil
				return
			end

			if not opts.config then
				if not run_var_use(P.name, use_list) then
					Pack.loaded[P.name] = nil
					return
				end
				Pack.inited[P.name] = true
				ensure(P.name, P.build)
				return
			end

			local ok, loaded = pcall(require, P.module)
			if not ok then
				Pack.loaded[P.name] = nil
				notify_once(
					"handle:require:" .. P.name,
					"Pack.handle:load(" .. P.name .. "): require failed\n" .. tostring(loaded),
					vim.log.levels.ERROR
				)
				return
			end

			local setup_ok, err = call_config(opts.config, loaded, config_env)
			if not setup_ok then
				Pack.loaded[P.name] = nil
				notify_once(
					"handle:config:" .. P.name,
					"Pack.handle:load(" .. P.name .. "): config failed\n" .. tostring(err),
					vim.log.levels.ERROR
				)
				return
			end

			if not run_var_use(P.name, use_list) then
				Pack.loaded[P.name] = nil
				return
			end

			-- 全部成功后再标记 inited（与 var_used 一致）
			-- Mark inited only after full success (aligned with var_used)
			Pack.inited[P.name] = true
			ensure(P.name, P.build)
		end
		if opts.defer then
			vim.schedule(go)
		else
			go()
		end
	end

	if opts.event then
		local au = vim.tbl_deep_extend("force", {}, opts)
		au.event = nil
		au.defer = nil
		au.config = nil
		au.utils = nil
		au.var = nil
		au.callback = function()
			run()
		end
		local ev = opts.event
		local ev_key = type(ev) == "table" and table.concat(ev, ",") or tostring(ev)
		local pat = opts.pattern
		local pat_key = type(pat) == "table" and table.concat(pat, ",") or tostring(pat or "")
		au.group = vim.api.nvim_create_augroup("PackLoad:" .. P.name .. ":" .. ev_key .. ":" .. pat_key, {
			clear = true,
		})
		vim.api.nvim_create_autocmd(opts.event, au)
	else
		run()
	end

	return self
end

return M
