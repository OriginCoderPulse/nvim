--- 插件管理公共 API，挂载到全局 Pack
require("hooks.pack_types")

---@type Pack
_G.Pack = vim.tbl_extend("force", _G.Pack or {
	building = {},
	inited = {},
	loaded = {},
	disabled = {},
	active = {},
	idle = {},
	registry = {},
	refs = {},
	_listeners = {},
}, {
	parse = require("hooks.deps.parse"),
	path = require("hooks.deps.path"),
	available = require("hooks.deps.available"),
	norm = require("hooks.deps").norm,
	needed = require("hooks.deps").needed,
	protect = require("hooks.deps").protect,
	users = require("hooks.deps").users,
	depname = require("hooks.deps").depname,
	walk = require("hooks.deps").walk,
	track = require("hooks.deps").track,
	register = require("hooks.register"),
	identity = require("hooks.register.identity"),
	load = require("hooks.load").load,
	eager = require("hooks.load").eager,
	configured = require("hooks.load").configured,
	load_listen = require("hooks.load.listen"),
	build = require("hooks.build"),
	ensure = require("hooks.build.ensure"),
	listen = require("hooks.build.listen"),
	sync = require("hooks.install.sync"),
	repair = require("hooks.install.repair"),
	install = require("hooks.install"),
	update = require("hooks.update").update,
	complete = require("hooks.update.complete"),
	restart = require("hooks.restart").restart,
	relaunch = require("hooks.restart").relaunch,
	root = require("hooks.util.root"),
	lsp = require("hooks.lsp"),
	boot = require("hooks.boot"),
})

return _G.Pack
