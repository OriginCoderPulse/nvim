--- 从 vim.pack spec 解析插件目录名
local function parse_spec_name(spec)
	local url = type(spec) == "table" and spec.src or spec
	return type(spec) == "table" and spec.name or url:match("([^/]+)$"):gsub("%.git$", "")
end

return parse_spec_name
