--- 同步注册表、安装插件、统一构建，全部完成后再询问重启
--- Sync registry, install plugins, batch-build, then ask to restart
---@param active_specs? table
---@param disabled_specs? table
return function(active_specs, disabled_specs)
	local Pack = _G.Pack
	local sort = require("hooks.install.sort")
	local sync = require("hooks.install.sync")
	local repair = require("hooks.install.repair")
	local batch = require("hooks.build.batch")
	local relaunch = require("hooks.restart").relaunch
	local restart_state = require("hooks.restart.state")
	active_specs = active_specs or Pack.active
	disabled_specs = disabled_specs or Pack.idle

	local stamp_path = vim.fn.stdpath("state") .. "/pack-hooks-install.stamp"

	local function spec_key(spec)
		local name = Pack.parse(spec)
		local src = type(spec) == "table" and tostring(spec.src or spec[1] or name) or tostring(spec)
		return name .. "\t" .. src
	end

	local function fingerprint()
		local keys = {}
		for _, spec in ipairs(active_specs) do
			keys[#keys + 1] = "a:" .. spec_key(spec)
		end
		for _, spec in ipairs(disabled_specs) do
			keys[#keys + 1] = "i:" .. spec_key(spec)
		end
		table.sort(keys)
		return vim.fn.sha256(table.concat(keys, "\0"))
	end

	--- 快路径：只查目录是否存在，不做 git healthy（省 ~100ms/启动）
	--- Fast path: directory presence only, no git healthy (~100ms/boot saved)
	local function dirs_present()
		for name in pairs(Pack.registry) do
			if not Pack.path(name) then
				return false
			end
		end
		for _, spec in ipairs(active_specs) do
			if not Pack.path(Pack.parse(spec)) then
				return false
			end
		end
		return true
	end

	local function after_install()
		batch(function(result)
			for _, name in ipairs(result.ok_names) do
				restart_state.built[#restart_state.built + 1] = name
			end
			relaunch()
		end)
	end

	local fp = fingerprint()
	local stamp_lines = vim.fn.filereadable(stamp_path) == 1 and vim.fn.readfile(stamp_path) or {}
	local sorted = sort(active_specs)
	if not sorted then
		vim.notify("install aborted: dependency sort failed", vim.log.levels.ERROR)
		return
	end

	-- 指纹命中 + 目录在：跳过 git 检查与 sync/repair
	-- Stamp hit + dirs present: skip git checks and sync/repair
	if stamp_lines[1] == fp and dirs_present() then
		vim.pack.add(sorted, { confirm = false, load = false })
		after_install()
		return
	end

	sync(active_specs, disabled_specs)
	repair()
	vim.pack.add(sorted, { confirm = false, load = false })
	vim.fn.writefile({ fp }, stamp_path)
	after_install()
end
