--- Pack API 类型（供 lua-language-server 补全；无运行时逻辑）
--- Pack API types for lua-language-server; no runtime logic

---@class Pack.SpecTable
---@field src string 仓库 URL
--- Repository URL
---@field name? string pack 目录名（覆盖从 URL 解析的结果）
--- Pack directory name (overrides URL-derived name)
---@field version? string|table 版本 / 分支 / tag / version range（vim.pack）
--- Version, branch, tag, or version range (vim.pack)

---@alias Pack.Spec string|Pack.SpecTable

---@class Pack.Dep
---@field src? string 依赖仓库（与 spec 二选一）
--- Dependency repo URL (mutually exclusive with spec)
---@field spec? Pack.Spec 依赖规格（与 src 二选一）
--- Dependency spec (mutually exclusive with src)
---@field name? string pack 目录名
--- Pack directory name
---@field module? string require 路径，默认 name
--- Require path; defaults to name
---@field setup? fun(plugin: any) 依赖 packadd 后执行
--- Runs after dependency packadd
---@field build_cmd? string|string[]|fun(name: string, dir: string) 构建：shell / :Vim 命令 / 函数
--- Build: shell, :Vim command, or function
---@field deps? (string|Pack.Dep)[] 嵌套依赖
--- Nested dependencies
---@field immediately? boolean true 且有 setup 时，install/eager 阶段抢先加载（默认 false）
--- If true with setup, load early during install/eager (default false)

---@class Pack.Plugin
---@field spec Pack.Spec 插件规格（必填）
--- Plugin spec (required)
---@field module? string require 路径；默认等于解析出的 name
--- Require path; defaults to resolved name
---@field name? string pack 目录名；通常由 spec 自动解析
--- Pack directory name; usually resolved from spec
---@field deps? (string|Pack.Dep)[] 依赖列表
--- Dependency list
---@field disabled? boolean true 时登记但不加载
--- If true, register but do not load
---@field build_cmd? string|string[]|fun(name: string, dir: string) 安装后构建：shell / ":TSUpdate" / function
--- Post-install build: shell, ":TSUpdate", or function
---@field lock? boolean true 时跳过 Pack.update（连同依赖）
--- Skip Pack.update for this plugin and its deps when true
---@field build_id? string 可选；变更时强制重建（函数 build_cmd 指纹补充）
--- Optional; change to force rebuild (supplements function build_cmd fingerprint)
---@field _registered? boolean 内部：已完成 Pack.register
--- Internal: already passed through Pack.register

--- nvim_create_autocmd 第一参事件名
--- Autocmd event name for nvim_create_autocmd arg 1
---@alias Pack.AutocmdEvent string

--- :load() 选项。除下列 Pack 字段外，其余透传 nvim_create_autocmd 第二参。
--- :load() options. Pack fields below; remaining keys pass through to nvim_create_autocmd arg 2.
---@class Pack.LoadOpts
---@field event? Pack.AutocmdEvent|Pack.AutocmdEvent[] autocmd 第一参；省略则立即加载
--- Autocmd arg 1; omit to load immediately
---@field time_sequence? boolean true → vim.schedule 后再 Pack.load（默认 false）
--- If true, Pack.load via vim.schedule (default false)
---@field config? fun(plugin: any) 加载后回调，只接收 module；无 module 时为 nil
--- Post-load callback; receives module or nil
---@field once? boolean 透传 autocmd
--- Pass-through autocmd option
---@field pattern? string|string[] 透传 autocmd
--- Pass-through autocmd option
---@field group? integer|string 透传 autocmd
--- Pass-through autocmd option
---@field desc? string 透传 autocmd
--- Pass-through autocmd option
---@field nested? boolean 透传 autocmd
--- Pass-through autocmd option
---@field buffer? integer 透传 autocmd
--- Pass-through autocmd option

---@class Pack.Handle
---@field load fun(self: Pack.Handle, opts?: Pack.LoadOpts): Pack.Handle

---@class Pack.BootCustomEntry
---@field [1] string 模块路径，如 `"core.options"`
--- Module path, e.g. `"core.options"`
---@field immediately? boolean `true`：hooks 之前；缺省则最后加载（无此字段时可直接写字符串 `"mod"`）
--- `true`: before hooks; default: load last (plain string `"mod"` also ok)

---@class Pack.BootHandle
---@field _config string
---@field _custom Pack.BootCustomEntry[]
---@field _ran boolean
---@field custom fun(self: Pack.BootHandle, entries?: (string|Pack.BootCustomEntry)[]): Pack 登记 custom 并启动。字符串项=最后加载；`{ mod, immediately=true }`=hooks 前
--- Register custom modules and boot. String = load last; `{ mod, immediately=true }` = before hooks
---@field run fun(self: Pack.BootHandle): Pack 启动（无 custom 时也可）
--- Boot (works without custom)

---@class Pack.Lsp
---@field enable fun(servers: table<string, string|string[]>) 登记 ft→server；内部延到首个 FileType 再加载 vim.lsp
--- Register ft→server; defer vim.lsp until first FileType
---@field disable fun(name: string)
---@field is_enabled fun(name: string): boolean
---@field is_disabled fun(name: string): boolean

--- 用户配置侧可见的 Pack API（内部方法/状态不在此声明，避免 Pack. 补全刷屏）
--- User-facing Pack API only (internals omitted so Pack. completion stays clean)
---@class Pack
---@field boot fun(config: string): Pack.BootHandle
---@field register fun(P: Pack.Plugin): Pack.Handle|nil
---@field update fun(targets?: string[], opts?: table)
---@field lsp Pack.Lsp
---@field root fun(markers: string|(string|string[])[]): fun(bufnr: integer, on_dir: fun(dir: string))

---@type Pack
Pack = Pack
