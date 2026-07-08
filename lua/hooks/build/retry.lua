local state = require("hooks.build.state")

---@param name string
local function cancel(name)
	local timer = state.timers[name]
	if timer then
		vim.fn.timer_stop(timer)
		state.timers[name] = nil
	end
end

---@param name string
local function reset(name)
	cancel(name)
	state.attempts[name] = nil
end

---@param name string
---@param build_cmd string|string[]
local function schedule(name, build_cmd)
	cancel(name)
	local next_attempt = (state.attempts[name] or 0) + 1
	if next_attempt > state.max_attempts then
		state.attempts[name] = nil
		vim.notify(
			"❌ " .. name .. " build 重试已达上限 (" .. state.max_attempts .. " 次)，请检查 build_cmd",
			vim.log.levels.ERROR
		)
		return
	end
	state.attempts[name] = next_attempt
	vim.notify(
		"⚠️ "
			.. name
			.. " build 失败，"
			.. (state.delay_ms / 1000)
			.. "s 后第 "
			.. next_attempt
			.. " 次重试...",
		vim.log.levels.WARN
	)
	state.timers[name] = vim.defer_fn(function()
		state.timers[name] = nil
		require("hooks.build.run")(name, build_cmd)
	end, state.delay_ms)
end

return {
	schedule = schedule,
	reset = reset,
	cancel = cancel,
	pending = function(name)
		return state.timers[name] ~= nil
	end,
}
