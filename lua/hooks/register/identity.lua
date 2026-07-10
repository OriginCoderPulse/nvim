--- 规范化 P.name（pack 目录名）与 P.module（require 路径）
--- Normalize P.name (pack dir) and P.module (require path)
local function identity(P)
	if not P then
		return P
	end

	local Pack = _G.Pack

	if P.spec then
		P.name = Pack.parse(P.spec)
	elseif P.name then
		P.name = Pack.parse(P.name)
	end

	P.module = P.module or P.name

	return P
end

return identity
