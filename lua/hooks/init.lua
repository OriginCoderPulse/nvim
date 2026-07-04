--- 插件管理公共 API，挂载到全局 Pack
_G.Pack = {
	building = {},
	inited = {},
	loaded = {},
	disabled = {},
	active = {},
	idle = {},
	registry = {},
	refs = {},
}

local Pack = _G.Pack

local deps = require("hooks.deps")
Pack.norm = deps.norm
Pack.needed = deps.needed
Pack.protect = deps.protect
Pack.users = deps.users
Pack.depname = deps.depname
Pack.walk = deps.walk
Pack.track = deps.track

Pack.register = require("hooks.register")
Pack.identity = require("hooks.identity")
Pack.parse = require("hooks.parse")
Pack.path = require("hooks.path")
Pack.available = require("hooks.available")
Pack.build = require("hooks.build")
Pack.ensure = require("hooks.ensure")
Pack.listen = require("hooks.listen")
Pack.sync = require("hooks.sync")
Pack.repair = require("hooks.repair")
Pack.install = require("hooks.install")
Pack.boot = require("hooks.boot")
local load = require("hooks.load")
Pack.load = load.load
Pack.eager = load.eager
Pack.configured = load.configured
Pack.complete = require("hooks.complete")
Pack.update = require("hooks.update").update
local restart = require("hooks.restart")
Pack.restart = restart.restart
Pack.relaunch = restart.relaunch
Pack.root = require("hooks.root")

return Pack
