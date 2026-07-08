--- 从 vim.pack spec 解析插件目录名
local function parse(spec)
	if type(spec) == "table" then
		if spec.name then
			return spec.name:gsub("%.git$", "")
		end
		spec = spec.src or spec[1]
	end
	if type(spec) ~= "string" or spec == "" then
		error("invalid pack spec: " .. vim.inspect(spec))
	end
	local name = spec:match("([^/]+)$")
	if not name then
		error("cannot parse plugin name from spec: " .. spec)
	end
	return name:gsub("%.git$", "")
end

return parse
