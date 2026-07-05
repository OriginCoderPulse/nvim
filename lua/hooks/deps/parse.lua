--- 从 vim.pack spec 解析插件目录名
local function parse(spec)
	local url = type(spec) == "table" and spec.src or spec
	return type(spec) == "table" and spec.name or url:match("([^/]+)$"):gsub("%.git$", "")
end

return parse
