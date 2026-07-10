--- Pack.register() 返回的链式句柄：:load({ event, time_sequence, config, ...autocmd })
--- Chainable handle from Pack.register(): :load({ event, time_sequence, config, ...autocmd })
local M = {}
M.__index = M

---@param P Pack.Plugin 已登记的插件声明
--- Registered plugin declaration
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
	local notify_once = require("hooks.util.notify_once")

	local function run()
		local go = function()
			-- packadd / deps；不传 config_fn，避免 Pack.inited 挡住每次 event 的 config
			-- packadd/deps; omit config_fn so Pack.inited does not block per-event config
			if not Pack.load(P) then
				return
			end
			if not opts.config then
				return
			end
			local mod
			if P.module then
				local ok, loaded = pcall(require, P.module)
				if not ok then
					Pack.loaded[P.name] = nil
					notify_once(
						"handle:require:" .. P.name,
						"Pack.handle:load(" .. P.name .. "): require 失败\n" .. tostring(loaded),
						vim.log.levels.ERROR
					)
					return
				end
				mod = loaded
			end
			local setup_ok, err = pcall(opts.config, mod)
			if not setup_ok then
				Pack.loaded[P.name] = nil
				notify_once(
					"handle:setup:" .. P.name,
					"Pack.handle:load(" .. P.name .. "): config 失败\n" .. tostring(err),
					vim.log.levels.ERROR
				)
				return
			end
			Pack.inited[P.name] = true
			-- config 成功后再跑延迟的 :Vim 构建
			-- Run deferred :Vim builds after successful config
			Pack.ensure(P.name, P.build_cmd)
		end
		if opts.time_sequence then
			vim.schedule(go)
		else
			go()
		end
	end

	if opts.event then
		local au = vim.tbl_deep_extend("force", {}, opts)
		au.event = nil
		au.time_sequence = nil
		au.config = nil
		au.callback = function()
			run()
		end
		-- augroup 含 event/pattern，避免二次 :load 清掉其它事件的 autocmd
		-- Include event/pattern in augroup so a second :load does not clear other events
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
