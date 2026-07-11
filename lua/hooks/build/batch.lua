--- 安装结束后并行异步构建所有待 build 插件（含 :Vim 命令；run 内会 packadd）
--- After install: build all pending plugins in parallel (incl. :Vim cmds; run packadds first)
local cmds = require("hooks.build.cmds")
local stamp = require("hooks.build.stamp")
local run = require("hooks.build.run")
local retry = require("hooks.build.retry")

---@param names? string[] 若提供则只构建这些名字（仍须有 build 且无有效 stamp，除非 force）
--- If set, only these names (still need build + missing stamp unless force)
---@param opts? { force?: boolean }
---@return { name: string, build: string|string[]|function }[]
local function collect_pending(names, opts)
	opts = opts or {}
	local Pack = _G.Pack
	local want = nil
	if names and #names > 0 then
		want = {}
		for _, n in ipairs(names) do
			want[Pack.parse(n)] = true
		end
	end

	local list = {}
	for name, build in pairs(cmds.all()) do
		local skip = (want and not want[name])
			or Pack.disabled[name]
			or false
		local dir = not skip and Pack.path(name) or nil
		local P = Pack.registry[name]
		if not skip and not dir then
			skip = true
		end
		if not skip and not opts.force and stamp.current(dir, build, P and P.build_id) then
			skip = true
		end
		if not skip and (Pack.building[name] or retry.pending(name)) then
			skip = true
		end
		if not skip then
			list[#list + 1] = { name = name, build = build }
		end
	end
	table.sort(list, function(a, b)
		return a.name < b.name
	end)
	return list
end

---@class Pack.BuildBatchResult
---@field ran integer
---@field ok_names string[]
---@field fail_names string[]

---@param on_done fun(result: Pack.BuildBatchResult)
---@param names? string[]
---@param opts? { force?: boolean, silent_start?: boolean }
local function batch(on_done, names, opts)
	opts = opts or {}
	local todo = collect_pending(names, opts)
	if #todo == 0 then
		on_done({ ran = 0, ok_names = {}, fail_names = {} })
		return
	end

	if not opts.silent_start then
		vim.notify("Building " .. #todo .. " plugins in parallel...", vim.log.levels.INFO)
	end

	local left = #todo
	local ok_names, fail_names = {}, {}

	local function one_done()
		left = left - 1
		if left > 0 then
			return
		end
		if #fail_names == 0 and #ok_names > 0 then
			vim.notify("Build success", vim.log.levels.INFO)
		end
		on_done({
			ran = #ok_names + #fail_names,
			ok_names = ok_names,
			fail_names = fail_names,
		})
	end

	for _, item in ipairs(todo) do
		retry.reset(item.name)
		if opts.force then
			local dir = require("hooks.deps.path")(item.name)
			if dir then
				stamp.clear(dir)
			end
		end
		run(item.name, item.build, function(ok, err)
			if ok then
				ok_names[#ok_names + 1] = item.name
			elseif err == "already building" then
				-- 与 ensure 重叠：不记失败，构建仍在进行
				-- Overlap with ensure: not a failure; build still in progress
			else
				fail_names[#fail_names + 1] = item.name
			end
			one_done()
		end, { quiet = true, no_retry = true })
	end
end

return batch
