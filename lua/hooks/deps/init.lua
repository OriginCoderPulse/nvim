--- deps 子模块聚合（供内部 require；不再整包挂到 Pack）
--- deps submodule barrel (internal require; not mounted on Pack wholesale)
return {
	norm = require("hooks.deps.norm"),
	depname = require("hooks.deps.depname"),
	walk = require("hooks.deps.walk"),
	track = require("hooks.deps.track"),
	needed = require("hooks.deps.needed"),
	protect = require("hooks.deps.protect").protect,
	users = require("hooks.deps.protect").users,
}
