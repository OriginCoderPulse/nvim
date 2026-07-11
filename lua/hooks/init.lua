--- 插件管理公共 API，挂载到全局 Pack
--- Public plugin-manager API mounted on global Pack
---
--- 配置侧：register / boot / lsp / root（更新走 :PackUpdate）
--- Configs: register / boot / lsp / root (updates via :PackUpdate)
require("hooks.pack_types")

---@type Pack
_G.Pack = vim.tbl_extend("force", _G.Pack or {
	building = {},
	inited = {},
	loaded = {},
	disabled = {},
	var_used = {},
	active = {},
	idle = {},
	registry = {},
	refs = {},
	_listeners = {},
}, {
	parse = require("hooks.deps.parse"),
	path = require("hooks.deps.path"),
	available = require("hooks.deps.available"),
	norm = require("hooks.deps.norm"),
	register = require("hooks.register"),
	boot = require("hooks.boot"),
	lsp = require("hooks.lsp"),
	root = require("hooks.util.root"),
})

_G.Pack = require("hooks.util.seal_pack")(_G.Pack)

return _G.Pack
