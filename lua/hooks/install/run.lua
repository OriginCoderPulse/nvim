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

	--- 目录存在且仓库完整：有 .git 时走 healthy（含 git rev-parse）；否则非空即可
	--- Dirs present and complete: git repos use healthy (rev-parse); else non-empty
	local healthy = require("hooks.deps.healthy")
	local function dirs_healthy()
		local seen = {}
		local function check_name(name)
			if seen[name] then
				return true
			end
			seen[name] = true
			local dir = Pack.path(name)
			if not dir then
				return false
			end
			return healthy(dir)
		end
		for name in pairs(Pack.registry) do
			if not check_name(name) then
				return false
			end
		end
		for _, spec in ipairs(active_specs) do
			if not check_name(Pack.parse(spec)) then
				return false
			end
		end
		for _, spec in ipairs(disabled_specs) do
			if not check_name(Pack.parse(spec)) then
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

	-- 指纹命中 + 目录完整：跳过 sync/repair
	-- Stamp hit + dirs healthy: skip sync/repair
	if stamp_lines[1] == fp and dirs_healthy() then
		vim.pack.add(sorted, { confirm = false, load = false })
		after_install()
		return
	end

	sync(active_specs, disabled_specs)
	repair()
	vim.pack.add(sorted, { confirm = false, load = false })
	local tmp = stamp_path .. ".tmp." .. tostring(vim.uv.os_getpid())
	vim.fn.writefile({ fp }, tmp)
	vim.uv.fs_rename(tmp, stamp_path)
	after_install()
end
