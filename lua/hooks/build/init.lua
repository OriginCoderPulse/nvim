--- 执行插件 build_cmd（shell 或 : 开头的 Vim 命令）
local function build(name, build_cmd)
	local Pack = _G.Pack
	name = Pack.parse(name)
	if Pack.disabled[name] then
		return
	end
	if not build_cmd or Pack.building[name] then
		return
	end
	local dir = Pack.path(name)
	if not dir then
		return
	end
	local stamp = dir .. "/.build_done"
	Pack.building[name] = true

	local is_vim_cmd = false
	local vim_cmd_str = ""

	if type(build_cmd) == "string" and build_cmd:sub(1, 1) == ":" then
		is_vim_cmd = true
		vim_cmd_str = build_cmd:sub(2)
	elseif type(build_cmd) == "table" and type(build_cmd[1]) == "string" and build_cmd[1]:sub(1, 1) == ":" then
		is_vim_cmd = true
		vim_cmd_str = table.concat(build_cmd, " "):sub(2)
	end

	if is_vim_cmd then
		vim.schedule(function()
			vim.notify("⚙️ Running " .. name .. " setup command...", vim.log.levels.INFO)
			pcall(vim.cmd.packadd, name)
			local ok, err = pcall(vim.cmd, vim_cmd_str)
			Pack.building[name] = false
			if ok then
				local f = io.open(stamp, "w")
				if f then
					f:close()
				end
				vim.notify("✅ " .. name .. " setup success.", vim.log.levels.INFO)
			else
				vim.notify("❌ " .. name .. " setup failed: " .. tostring(err), vim.log.levels.ERROR)
			end
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
			Pack.building[name] = false
			if out.code == 0 then
				local f = io.open(stamp, "w")
				if f then
					f:close()
				end
				vim.schedule(function()
					vim.notify("✅ " .. name .. " build success.", vim.log.levels.INFO)
				end)
			else
				vim.schedule(function()
					vim.notify(
						"❌ " .. name .. " build failed: " .. (out.stderr or "Unknown Error"),
						vim.log.levels.ERROR
					)
				end)
			end
		end)
	end
end

return build
