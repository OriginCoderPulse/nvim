Pack.boot():keys({
    { "n", "<leader>t", "<cmd>TestNeovim<cr>", { desc = "Run tests" } },
})

-- Test名称处为command的group参数值
Pack.boot():commands({
    Test = {
        evnet = "xxx",
        ...
    }
})

-- 同一个group写法如下
Pack.boot():commands({
    Test = {
        {
            evnet = "xxx",
            ...
        },
        {
            evnet = "xxx",
            ...
        }
    }
})


Pack.boot():options({
    g = {
        number = true
    },
    opt = {
        ...
    },
    diagnostic = {
        ...
    },
    ...
})

-- Pack.lsp.enable()/Pack.lsp.disable()改为采用此方式，不支持
Pack.boot():lsp({
    -- enabled
},{
    --disabled
})

或

Pack.boot():lsp({
    enable = {},
    disable = {}
})

-- 支持Pack.boot():keys():commands():options():lsp()的链式调用
-- 支持Pack.boot():keys("require"):commands("require"):options("require"):lsp("require") require处为配置文件位置返回一个table