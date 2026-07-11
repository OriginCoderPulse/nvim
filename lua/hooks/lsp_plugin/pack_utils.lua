--- Pack.utils/var → lua_ls：正确补全 + 任意调用签名兼容
---
--- 可用范围 / Where names are usable:
---   utils → 仅 var 函数体内（setfenv）
---   var   → var 体内互调 + config 内
---
--- 补全策略 / Completion:
---   utils：if-false 里 `name = require(path)` → 模块字段/方法补全
---   var 调用：if-false 里 `---@type fun(...): any` → 任意实参调用不报错
---   var 形参：源码 `---@param name T`（不写死 ---@type fun(具体签名)）→ 体内 name. 补全
---
--- 由 Pack.lsp activate → ensure_lua_ls_plugin 挂载

---@class diff
---@field start integer
---@field finish integer
---@field text string

---@param s string
---@param i integer
---@return string?
local function prev_significant(s, i)
	i = i - 1
	while i >= 1 do
		local c = s:sub(i, i)
		if not c:match("%s") then
			return c
		end
		i = i - 1
	end
	return nil
end

local BLOCK_OPEN = {
	["function"] = true,
	["if"] = true,
	["for"] = true,
	["while"] = true,
	["do"] = true,
	["repeat"] = true,
}

---@param block string
---@return string[]
local function top_level_keys(block)
	local keys = {}
	local depth = 0
	local block_depth = 0
	local i = 1
	local n = #block
	while i <= n do
		local c = block:sub(i, i)
		if c == "{" then
			depth = depth + 1
			i = i + 1
		elseif c == "}" then
			depth = depth - 1
			i = i + 1
		elseif c == '"' or c == "'" then
			local q = c
			i = i + 1
			while i <= n do
				local ch = block:sub(i, i)
				if ch == "\\" then
					i = i + 2
				elseif ch == q then
					i = i + 1
					break
				else
					i = i + 1
				end
			end
		elseif c == "[" then
			local eq = block:match("^%[=*%[", i)
			if eq then
				local close = "]" .. string.rep("=", #eq - 2) .. "]"
				local j = block:find(close, i + #eq, true)
				i = j and (j + #close) or (n + 1)
			else
				i = i + 1
			end
		else
			local word, wrest = block:match("^([%a_][%w_]*)()", i)
			if word then
				if BLOCK_OPEN[word] then
					block_depth = block_depth + 1
					i = wrest
				elseif word == "end" or word == "until" then
					block_depth = math.max(0, block_depth - 1)
					i = wrest
				elseif depth == 1 and block_depth == 0 then
					local name, rest = block:match("^([%a_][%w_]*)%s*=%s*()", i)
					if name then
						local prev = prev_significant(block, i)
						if prev == "{" or prev == "," then
							keys[#keys + 1] = name
						end
						i = rest
					else
						i = wrest
					end
				else
					i = wrest
				end
			else
				i = i + 1
			end
		end
	end
	return keys
end

---@param text string
---@return table<string, string>
local function parse_utils(text)
	local map = {}
	for block in text:gmatch("utils%s*=%s*(%b{})") do
		for _, name in ipairs(top_level_keys(block)) do
			local path = block:match(name .. "%s*=%s*[\"']([^\"']+)[\"']")
			if path then
				map[name] = path
			end
		end
	end
	return map
end

---@param utils table<string, string>
---@param uri string
---@return boolean, boolean
local function detect_libs(utils, uri)
	local has_blink, has_snacks = false, false
	for _, path in pairs(utils) do
		if path:find("blink", 1, true) or path == "colorful-menu" or path:find("colorful%-menu", 1) then
			has_blink = true
		end
		if path:find("snacks", 1, true) then
			has_snacks = true
		end
	end
	if uri:match("blink%.lua$") then
		has_blink = true
	end
	if uri:match("snacks%.lua$") then
		has_snacks = true
	end
	return has_blink, has_snacks
end

--- 形参补全用类型（只影响定义处补全，不约束调用 arity）
---@param pname string
---@param has_blink boolean
---@param has_snacks boolean
---@return string
local function param_complete_type(pname, has_blink, has_snacks)
	if pname == "ctx" and has_blink then
		return "blink.cmp.DrawItemContext"
	end
	if pname == "text" or pname == "icon" then
		return "string"
	end
	if pname == "item" and has_snacks then
		return "snacks.picker.Item"
	end
	if pname == "picker" and has_snacks then
		return "snacks.Picker"
	end
	if pname == "plugin" then
		return "any"
	end
	return "any"
end

--- 解析 `function(a, b, ...)` 形参名列表（Lua 5.4 勿给 for 变量赋值）
---@param params string
---@return string[]
local function param_names(params)
	params = (params and params:match("^%s*(.-)%s*$")) or ""
	local names = {}
	if params == "" then
		return names
	end
	for raw in (params .. ","):gmatch("([^,]*),") do
		local part = raw:match("^%s*(.-)%s*$") or ""
		if part == "..." then
			names[#names + 1] = "..."
		elseif part ~= "" then
			names[#names + 1] = part:match("^([%a_][%w_]*)") or part
		end
	end
	return names
end

---@param params string
---@param has_blink boolean
---@param has_snacks boolean
---@return string @ 多行 ---@param ...
local function param_annotations(params, has_blink, has_snacks)
	local lines = {}
	for _, name in ipairs(param_names(params)) do
		if name == "..." then
			lines[#lines + 1] = "---@vararg any\n"
		else
			lines[#lines + 1] = ("---@param %s %s\n"):format(name, param_complete_type(name, has_blink, has_snacks))
		end
	end
	return table.concat(lines)
end

---@param block string
---@param name string
---@return boolean
local function is_top_level_fn(block, name)
	local i = 1
	local n = #block
	local depth = 0
	local block_depth = 0
	while i <= n do
		local c = block:sub(i, i)
		if c == "{" then
			depth = depth + 1
			i = i + 1
		elseif c == "}" then
			depth = depth - 1
			i = i + 1
		elseif c == '"' or c == "'" then
			local q = c
			i = i + 1
			while i <= n do
				local ch = block:sub(i, i)
				if ch == "\\" then
					i = i + 2
				elseif ch == q then
					i = i + 1
					break
				else
					i = i + 1
				end
			end
		else
			local word, wrest = block:match("^([%a_][%w_]*)()", i)
			if word then
				if BLOCK_OPEN[word] then
					block_depth = block_depth + 1
					i = wrest
				elseif word == "end" or word == "until" then
					block_depth = math.max(0, block_depth - 1)
					i = wrest
				elseif depth == 1 and block_depth == 0 and word == name then
					if block:match("^" .. name .. "%s*=%s*function%s*%(", i) then
						local prev = prev_significant(block, i)
						if prev == "{" or prev == "," then
							return true
						end
					end
					i = wrest
				else
					i = wrest
				end
			else
				i = i + 1
			end
		end
	end
	return false
end

--- 源码 var 内 `key = function(params)`：只插 ---@param（体内补全），不插窄签名 ---@type
---@param block_start integer
---@param block string
---@param has_blink boolean
---@param has_snacks boolean
---@return diff[]
local function var_param_complete_diffs(block_start, block, has_blink, has_snacks)
	---@type diff[]
	local diffs = {}
	local i = 1
	while true do
		local ns, ne, name, params = block:find("([%a_][%w_]*)%s*=%s*function%s*%(([^)]*)%)", i)
		if not ns then
			break
		end
		local prev = prev_significant(block, ns)
		if prev == "{" or prev == "," then
			local ann = param_annotations(params, has_blink, has_snacks)
			if ann ~= "" then
				diffs[#diffs + 1] = {
					start = block_start + ns - 1,
					finish = block_start + ns - 2,
					text = ann,
				}
			end
		end
		i = ne + 1
	end
	return diffs
end

--- config = function(plugin)：用 module 的 require 覆盖，使 plugin.setup 等可补全（仅分析期）
---@param text string
---@return diff[]
local function config_plugin_complete_diffs(text)
	---@type diff[]
	local diffs = {}
	local mod = text:match("module%s*=%s*[\"']([^\"']+)[\"']")
	if not mod then
		return diffs
	end
	local search = 1
	while true do
		local ns, ne, params = text:find("config%s*=%s*function%s*%(([^)]*)%)", search)
		if not ns then
			break
		end
		-- 仅当形参含 plugin 时注入
		local has_plugin = false
		for _, name in ipairs(param_names(params)) do
			if name == "plugin" then
				has_plugin = true
				break
			end
		end
		if has_plugin then
			local ann = param_annotations(params, false, false)
			diffs[#diffs + 1] = {
				start = ns,
				finish = ns - 1,
				text = ann,
			}
			diffs[#diffs + 1] = {
				start = ne + 1,
				finish = ne,
				text = ("\n\tplugin = require(%q)\n"):format(mod),
			}
		end
		search = ne + 1
	end
	return diffs
end

---@param uri string
---@param text string
---@return diff[]|nil
function OnSetText(uri, text)
	if not uri:match("[/\\]packages[/\\]configs[/\\][^/\\]+%.lua$") then
		return nil
	end

	local utils = parse_utils(text)
	local has_blink, has_snacks = detect_libs(utils, uri)
	local seen = {}

	local stub = {
		-- setfenv 场景下的误报；不关补全
		"---@diagnostic disable: undefined-global,undefined-field,unused-local,unused-function,unused-vararg,lowercase-global,missing-return,redundant-return-value,redundant-parameter,missing-parameter,param-type-mismatch,assign-type-mismatch,return-type-mismatch,cast-local-type,need-check-nil,missing-fields,inject-field\n",
		"if false then --[[ Pack.utils/var → lua_ls completion ]]\n",
	}

	local refs = {}

	-- utils：真实模块 → menu./lsp_config. 等补全
	for name, path in pairs(utils) do
		seen[name] = true
		refs[#refs + 1] = name
		stub[#stub + 1] = ("  %s = require(%q)\n"):format(name, path)
	end

	-- var：调用侧 fun(...): any（任意实参）；非函数 any
	for block in text:gmatch("var%s*=%s*(%b{})") do
		for _, name in ipairs(top_level_keys(block)) do
			if not seen[name] then
				seen[name] = true
				refs[#refs + 1] = name
				if is_top_level_fn(block, name) then
					stub[#stub + 1] = ("  ---@type fun(...): any\n  %s = function(...) return nil end\n"):format(name)
				else
					stub[#stub + 1] = ("  ---@type any\n  %s = {}\n"):format(name)
				end
			end
		end
	end

	if #refs > 0 then
		table.sort(refs)
		stub[#stub + 1] = ("  local _PackUsed = { %s }\n"):format(table.concat(refs, ", "))
	end
	stub[#stub + 1] = "end\n"

	---@type diff[]
	local diffs = {
		{ start = 1, finish = 0, text = table.concat(stub) },
	}

	-- var 源码函数：---@param → 体内形参补全（ctx. / item.）
	local search = 1
	while true do
		local ks, ke = text:find("var%s*=%s*", search)
		if not ks then
			break
		end
		local bs, be = text:find("%b{}", ke)
		if not bs then
			break
		end
		for _, d in ipairs(var_param_complete_diffs(bs, text:sub(bs, be), has_blink, has_snacks)) do
			diffs[#diffs + 1] = d
		end
		search = be + 1
	end

	for _, d in ipairs(config_plugin_complete_diffs(text)) do
		diffs[#diffs + 1] = d
	end

	return diffs
end
