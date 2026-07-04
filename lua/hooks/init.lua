--- 插件管理公共 API，挂载到全局 PackUtils
_G.PackUtils = {
	is_building = {},
	is_initialized = {},
	plugin_loaded = {},
	disabled_plugins = {},
	active_specs = {},
	disabled_specs = {},
	registry = {},
	dep_refs = {},
}

local PackUtils = _G.PackUtils

local dep = require("hooks.track_dependency")
PackUtils.track_dependency = dep.track_dependency
PackUtils.is_dependency_needed = dep.is_dependency_needed
PackUtils.collect_protected_names = dep.collect_protected_names
PackUtils.get_dependents = dep.get_dependents
PackUtils.normalize_dep = dep.normalize_dep
PackUtils.resolve_dep_name = dep.resolve_dep_name
PackUtils.walk_dep_tree = dep.walk_dep_tree

PackUtils.register_plugin = require("hooks.register_plugin")
PackUtils.resolve_plugin_identity = require("hooks.resolve_plugin_identity")
PackUtils.parse_spec_name = require("hooks.parse_spec_name")
PackUtils.resolve_plugin_path = require("hooks.resolve_plugin_path")
PackUtils.is_plugin_available = require("hooks.is_plugin_available")
PackUtils.execute_build = require("hooks.execute_build")
PackUtils.ensure_built = require("hooks.ensure_built")
PackUtils.register_pack_listener = require("hooks.register_pack_listener")
PackUtils.synchronize_registry = require("hooks.synchronize_registry")
PackUtils.repair_incomplete_plugins = require("hooks.repair_incomplete_plugins")
PackUtils.sync_and_install = require("hooks.sync_and_install")
PackUtils.bootstrap_plugins = require("hooks.bootstrap_plugins")
local load_plugin_mod = require("hooks.load_plugin")
PackUtils.load_plugin = load_plugin_mod.load_plugin
PackUtils.load_eager_deps = load_plugin_mod.load_eager_deps
PackUtils.dep_has_config = load_plugin_mod.dep_has_config
PackUtils.complete_plugin_names = require("hooks.complete_plugin_names")

local pack_restart = require("hooks.setup_pack_restart")
PackUtils.setup_pack_restart = pack_restart.setup_pack_restart
PackUtils.maybe_restart_after_install = pack_restart.maybe_restart_after_install
PackUtils.lsp_root_dir = require("hooks.lsp_root_dir")

return PackUtils
