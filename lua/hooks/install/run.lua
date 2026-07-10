--- 同步注册表、安装插件、必要时自动重启
--- Sync registry, install plugins, relaunch if needed
---@param active_specs? table
---@param disabled_specs? table
return function(active_specs, disabled_specs)
	local Pack = _G.Pack
	local sort = require("hooks.install.sort")
	local eager = require("hooks.load.eager")
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

	local function all_available()
		for name in pairs(Pack.registry) do
			if not Pack.available(name) then
				return false
			end
		end
		for _, spec in ipairs(active_specs) do
			if not Pack.available(Pack.parse(spec)) then
				return false
			end
		end
		return true
	end

	local fp = fingerprint()
	local stamp_lines = vim.fn.filereadable(stamp_path) == 1 and vim.fn.readfile(stamp_path) or {}
	if stamp_lines[1] == fp and all_available() then
		eager()
		Pack.relaunch()
		return
	end

	Pack.sync(active_specs, disabled_specs)
	Pack.repair()
	local sorted = sort(active_specs)
	if not sorted then
		vim.notify("install 已中止: 依赖排序失败", vim.log.levels.ERROR)
		return
	end
	vim.pack.add(sorted, { confirm = false, load = false })
	eager()
	Pack.relaunch()
	vim.fn.writefile({ fp }, stamp_path)
end
