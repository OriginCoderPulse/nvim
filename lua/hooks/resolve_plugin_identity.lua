--- 规范化 P.name（pack 目录名）与 P.module（require 路径）
local function resolve_plugin_identity(P)
	if not P then
		return P
	end

	local PackUtils = _G.PackUtils

	if P.spec then
		-- name 始终为 pack 目录名（由 spec 解析），与 module 不同
		-- 例：catppuccin/nvim → name = "nvim", module = "catppuccin"
		P.name = PackUtils.parse_spec_name(P.spec)
	elseif P.name then
		P.name = PackUtils.parse_spec_name(P.name)
	end

	P.module = P.module or P.name

	return P
end

return resolve_plugin_identity
