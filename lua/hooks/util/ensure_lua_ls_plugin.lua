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

--- 仅信任 hooks 内置 pack_utils 路径（写入 trusted，避免交互询问）
--- Trust only the built-in pack_utils path (write trusted; skip interactive prompt)
---@param path string
local function ensure_trusted(path)
	-- 只写 state，避免扩大 log/cache 信任面
	-- Only state dir; do not widen log/cache trust surface
	local dir = vim.fn.stdpath("state") .. "/lua-language-server"
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
		vim.fn.stdpath("config") .. "/lua",
	}
	for _, rtp in ipairs(vim.opt.runtimepath:get()) do
		if rtp:find("[/\\]site[/\\]pack[/\\]", 1) or rtp:find("[/\\]lazy[/\\]", 1) then
			library[#library + 1] = rtp
		end
	end

	vim.lsp.config("lua_ls", {
		-- 不用 --develop：缩小 LSP 能力面；信任靠 trusted + trustByClient
		-- No --develop: smaller LSP surface; trust via trusted + trustByClient
		cmd = { "lua-language-server" },
		init_options = {
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
