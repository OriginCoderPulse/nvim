--- After install/build, ask whether to restart; prefer Snacks.picker, else vim.fn.confirm
local state = require("hooks.restart.state")
local should_auto_restart = require("hooks.restart.should_restart")

local function do_restart()
	vim.notify("Restarting Neovim...", vim.log.levels.INFO)
	vim.schedule(function()
		vim.cmd.restart()
	end)
end

---@param prompt string
---@param on_yes fun()
local function ask_confirm(prompt, on_yes)
	-- No first + default No, so Enter / dismiss cannot mean Yes
	local choice = vim.fn.confirm(prompt, "&No\n&Yes", 1, "Question")
	if choice == 2 then
		on_yes()
	end
end

---@param prompt string
---@param on_yes fun()
---@return boolean ok
local function ask_snacks(prompt, on_yes)
	if not (Snacks and Snacks.picker and Snacks.picker.select) then
		return false
	end
	local ok = pcall(function()
		Snacks.picker.select({ "No", "Yes" }, {
			prompt = prompt,
			kind = "pack_restart",
			snacks = {
				layout = {
					preset = "select",
					layout = {
						width = 0.4,
						height = 0.25,
						min_width = 40,
						max_width = 72,
						border = "rounded",
					},
				},
			},
		}, function(item)
			-- Only explicit "Yes" restarts; cancel / No / nil do nothing
			if item == "Yes" then
				on_yes()
			end
		end)
	end)
	return ok
end

---@param prompt string
---@param on_yes fun()
local function ask(prompt, on_yes)
	-- Defer so startup UI / Snacks VimEnter config can finish first
	vim.defer_fn(function()
		if ask_snacks(prompt, on_yes) then
			return
		end
		-- Snacks not ready yet: one short retry, then confirm
		vim.defer_fn(function()
			if ask_snacks(prompt, on_yes) then
				return
			end
			ask_confirm(prompt, on_yes)
		end, 200)
	end, 100)
end

return function()
	if #state.installed == 0 and #state.built == 0 then
		return
	end

	if not should_auto_restart() then
		state.installed = {}
		state.built = {}
		return
	end

	state.installed = {}
	state.built = {}

	ask("Install finished. Restart Neovim?", do_restart)
end
