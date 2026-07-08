return {
	norm = require("hooks.deps.norm"),
	depname = require("hooks.deps.depname"),
	walk = require("hooks.deps.walk"),
	track = require("hooks.deps.track"),
	needed = require("hooks.deps.needed"),
	protect = require("hooks.deps.protect").protect,
	users = require("hooks.deps.protect").users,
}
