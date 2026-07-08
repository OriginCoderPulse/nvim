--- 执行插件 build_cmd（shell 或 : 开头的 Vim 命令）
local stamp = require("hooks.build.stamp")
local retry = require("hooks.build.retry")

---@param name string
---@param build_cmd string|string[]
return function(name, build_cmd)
	local Pack = _G.Pack
	name = Pack.parse(name)
	if Pack.disabled[name] or not build_cmd then
		return
	end
	if Pack.building[name] or retry.pending(name) then
		return
	end
	local dir = Pack.path(name)
	if not dir then
		return
	end
	Pack.building[name] = true

	local is_vim_cmd = false
	local vim_cmd_str = ""

	if type(build_cmd) == "string" and build_cmd:sub(1, 1) == ":" then
		is_vim_cmd = true
		vim_cmd_str = build_cmd:sub(2)
	elseif type(build_cmd) == "table" and type(build_cmd[1]) == "string" and build_cmd[1]:sub(1, 1) == ":" then
		is_vim_cmd = true
		vim_cmd_str = build_cmd[1]:sub(2)
	end

	local function finish(ok, err_msg)
		Pack.building[name] = false
		if ok then
			retry.reset(name)
			stamp.write(dir, build_cmd)
			vim.notify("✅ " .. name .. " build success.", vim.log.levels.INFO)
		else
			stamp.clear(dir)
			vim.notify("❌ " .. name .. " build failed: " .. tostring(err_msg), vim.log.levels.ERROR)
			retry.schedule(name, build_cmd)
		end
	end

	if is_vim_cmd then
		vim.schedule(function()
			vim.notify("⚙️ Running " .. name .. " setup command...", vim.log.levels.INFO)
			pcall(vim.cmd.packadd, name)
			local ok, err = pcall(vim.cmd, vim_cmd_str)
			finish(ok, err)
		end)
	else
		local final_cmd = {}
		if type(build_cmd) == "string" then
			for word in build_cmd:gmatch("%S+") do
				table.insert(final_cmd, word)
			end
		else
			final_cmd = build_cmd
		end
		vim.schedule(function()
			vim.notify("⚙️ Building " .. name .. " (Background)...", vim.log.levels.INFO)
		end)
		vim.system(final_cmd, { cwd = dir }, function(out)
			if out.code == 0 then
				finish(true)
			else
				finish(false, out.stderr or "Unknown Error")
			end
		end)
	end
end
