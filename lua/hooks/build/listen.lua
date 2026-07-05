--- 监听 PackChanged，安装/更新后自动重新构建
local function listen(name, build_cmd)
	local Pack = _G.Pack
	name = Pack.parse(name)
	if Pack.disabled[name] then
		return
	end
	if not build_cmd then
		return
	end
	vim.api.nvim_create_autocmd("PackChanged", {
		pattern = "*",
		callback = function(ev)
			if ev.data.spec.name == name and (ev.data.kind == "update" or ev.data.kind == "install") then
				local stamp = ev.data.path .. "/.build_done"
				os.remove(stamp)
				Pack.build(name, build_cmd)
			end
		end,
	})
end

return listen
