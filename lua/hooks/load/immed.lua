---@param dep any
---@return boolean
local function configured(dep)
	local ok, item = pcall(_G.Pack.norm, dep)
	return ok and item.setup ~= nil
end

---@param dep any
---@return boolean
local function immed(dep)
	if type(dep) ~= "table" then
		return false
	end
	return dep.setup ~= nil and dep.immediately == true
end

return {
	configured = configured,
	immed = immed,
}
