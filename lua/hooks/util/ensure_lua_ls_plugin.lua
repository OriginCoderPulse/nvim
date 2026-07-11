--- 内置挂载 Pack.utils/var 的 lua_ls 插件（无需外部 .luarc / 不改 configs）
--- Built-in: attach Pack.utils/var lua_ls plugin (no external .luarc / no config edits)
---
--- 须在 Pack.lsp activate 时调用，勿在 hooks 初始化调用（会提前 require vim.lsp）
--- Call from Pack.lsp activate only; not at hooks init (would eager-load vim.lsp)
local applied = false

---@return string
local function plugin_path()
	local src = debug.getinfo(1, "S").source
	if type(src) == "string" and src:sub(1, 1) == "@" then
		local here = vim.fs.normalize(src:sub(2))
		return vim.fs.normalize(vim.fs.dirname(here) .. "/../lsp_plugin/pack_utils.lua")
	end
	return vim.fn.stdpath("config") .. "/lua/hooks/lsp_plugin/pack_utils.lua"
end

--- 写入 lua_ls logpath/trusted，避免交互信任失败导致插件静默不加载
--- Write logpath/trusted so plugin loads without interactive trust prompt
---@param path string
local function ensure_trusted(path)
	local candidates = {
		vim.fn.stdpath("log") .. "/lua-language-server",
		vim.fn.stdpath("cache") .. "/lua-language-server",
		vim.fn.stdpath("state") .. "/lua-language-server",
	}
	for _, dir in ipairs(candidates) do
		vim.fn.mkdir(dir, "p")
		local trusted = dir .. "/trusted"
		local existing = ""
		if vim.fn.filereadable(trusted) == 1 then
			existing = table.concat(vim.fn.readfile(trusted), "\n")
		end
		if not existing:find(path, 1, true) then
			local lines = {}
			if existing ~= "" then
				for line in (existing .. "\n"):gmatch("([^\n]*)\n") do
					if line ~= "" then
						lines[#lines + 1] = line
					end
				end
			end
			lines[#lines + 1] = path
			vim.fn.writefile(lines, trusted)
		end
	end
end

--- 合并进 vim.lsp.config("lua_ls")；可重复调用
--- Merge into vim.lsp.config("lua_ls"); safe to call repeatedly
return function()
	if applied then
		return
	end
	applied = true

	local path = plugin_path()
	ensure_trusted(path)

	local library = {
		vim.env.VIMRUNTIME,
		-- Pack / pack_types 注解，避免 Pack.register 等被推成 fun()
		-- Pack / pack_types annotations so Pack.register is not inferred as fun()
		vim.fn.stdpath("config") .. "/lua",
	}
	-- 让 require("blink...") / require("snacks...") 能解析到 pack 插件以提供补全
	-- Resolve pack plugins so require() yields real types for completion
	for _, rtp in ipairs(vim.opt.runtimepath:get()) do
		if rtp:find("[/\\]site[/\\]pack[/\\]", 1) or rtp:find("[/\\]lazy[/\\]", 1) then
			library[#library + 1] = rtp
		end
	end

	vim.lsp.config("lua_ls", {
		cmd = { "lua-language-server", "--develop" },
		init_options = {
			-- 跳过「是否信任插件」询问（插件由 hooks 内置提供）
			trustByClient = true,
		},
		settings = {
			Lua = {
				runtime = {
					version = "LuaJIT",
					plugin = { path },
				},
				diagnostics = {
					globals = { "vim", "Pack", "Snacks" },
				},
				workspace = {
					checkThirdParty = false,
					library = library,
				},
			},
		},
	})
end
