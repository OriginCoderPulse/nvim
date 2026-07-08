local immed = require("hooks.load.immed")

return {
	load = require("hooks.load.load"),
	eager = require("hooks.load.eager"),
	configured = immed.configured,
}
