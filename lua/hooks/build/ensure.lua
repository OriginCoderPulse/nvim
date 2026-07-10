--- 若存在 build_cmd 且尚未构建，则触发 build
--- If build_cmd exists and not yet built, trigger build
local stamp = require("hooks.build.stamp")
local retry = require("hooks.build.retry")

--- :Vim 构建命令需在插件 init 之后执行
--- :Vim build commands must run after plugin init
---@param build_cmd string|string[]|function
---@return boolean
local function is_vim_cmd(build_cmd)
	if type(build_cmd) == "string" and build_cmd:sub(1, 1) == ":" then
		return true
	end
	if type(build_cmd) == "table" and type(build_cmd[1]) == "string" and build_cmd[1]:sub(1, 1) == ":" then
		return true
	end
	return false
end

---@param name string
---@param build_cmd string|string[]|function
return function(name, build_cmd)
	local Pack = _G.Pack
	name = Pack.parse(name)
	if Pack.disabled[name] or not build_cmd then
		return
	end
	if is_vim_cmd(build_cmd) and not Pack.inited[name] then
		return
	end
	local dir = Pack.path(name)
	local P = Pack.registry[name]
	if not dir or stamp.current(dir, build_cmd, P and P.build_id) then
		return
	end
	if Pack.building[name] or retry.pending(name) then
		return
	end
	retry.reset(name)
	Pack.build(name, build_cmd)
end
