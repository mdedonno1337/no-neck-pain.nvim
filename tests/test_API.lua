local helpers = dofile("tests/helpers.lua")

local child = helpers.new_child_neovim()
local eq_global, eq_option, eq_state =
    helpers.expect.global_equality, helpers.expect.option_equality, helpers.expect.state_equality
local eq_type_global, eq_type_option, eq_type_state =
    helpers.expect.global_type_equality,
    helpers.expect.option_type_equality,
    helpers.expect.state_type_equality

local T = MiniTest.new_set({
    hooks = {
        -- This will be executed before every (even nested) case
        pre_case = function()
            -- Restart child process with custom 'init.lua' script
            child.restart({ "-u", "scripts/minimal_init.lua" })
        end,
        -- This will be executed one after all tests from this set are finished
        post_once = child.stop,
    },
})

local SCOPES = { "left", "right" }

T["install"] = MiniTest.new_set()

T["install"]["sets global loaded variable and provide toggle command"] = function()
    eq_type_global(child, "_G.NoNeckPainLoaded", "boolean")
    eq_global(child, "_G.NoNeckPain", vim.NIL)

    child.cmd("NoNeckPain")
    eq_state(child, "enabled", true)

    child.cmd("NoNeckPain")
    eq_state(child, "enabled", false)
end

T["setup()"] = MiniTest.new_set()

T["setup()"]["sets exposed methods and default options value"] = function()
    child.lua([[require('no-neck-pain').setup()]])

    eq_type_global(child, "_G.NoNeckPain", "table")

    -- public methods
    eq_type_global(child, "_G.NoNeckPain.toggle", "function")
    eq_type_global(child, "_G.NoNeckPain.enable", "function")
    eq_type_global(child, "_G.NoNeckPain.setup", "function")

    -- config
    eq_type_global(child, "_G.NoNeckPain.config", "table")
    eq_type_option(child, "buffers", "table")

    eq_option(child, "width", 100)
    eq_option(child, "debug", false)
    eq_option(child, "disableOnLastBuffer", false)
    eq_option(child, "killAllBuffersOnDisable", false)

    -- buffers
    eq_type_option(child, "buffers", "table")
    eq_type_option(child, "buffers.bo", "table")
    eq_type_option(child, "buffers.wo", "table")

    eq_option(child, "buffers.setNames", false)
    eq_option(child, "buffers.backgroundColor", vim.NIL)
    eq_option(child, "buffers.blend", 0)
    eq_option(child, "buffers.textColor", vim.NIL)

    eq_option(child, "buffers.bo.filetype", "no-neck-pain")
    eq_option(child, "buffers.bo.buftype", "nofile")
    eq_option(child, "buffers.bo.bufhidden", "hide")
    eq_option(child, "buffers.bo.modifiable", false)
    eq_option(child, "buffers.bo.buflisted", false)
    eq_option(child, "buffers.bo.swapfile", false)

    eq_option(child, "buffers.wo.cursorline", false)
    eq_option(child, "buffers.wo.cursorcolumn", false)
    eq_option(child, "buffers.wo.number", false)
    eq_option(child, "buffers.wo.relativenumber", false)
    eq_option(child, "buffers.wo.foldenable", false)
    eq_option(child, "buffers.wo.list", false)

    for _, scope in pairs(SCOPES) do
        eq_type_option(child, "buffers." .. scope, "table")
        eq_type_option(child, "buffers." .. scope .. ".bo", "table")
        eq_type_option(child, "buffers." .. scope .. ".wo", "table")

        eq_option(child, "buffers." .. scope .. ".backgroundColor", vim.NIL)
        eq_option(child, "buffers." .. scope .. ".blend", 0)
        eq_option(child, "buffers." .. scope .. ".textColor", vim.NIL)

        eq_option(child, "buffers." .. scope .. ".bo.filetype", "no-neck-pain")
        eq_option(child, "buffers." .. scope .. ".bo.buftype", "nofile")
        eq_option(child, "buffers." .. scope .. ".bo.bufhidden", "hide")
        eq_option(child, "buffers." .. scope .. ".bo.modifiable", false)
        eq_option(child, "buffers." .. scope .. ".bo.buflisted", false)
        eq_option(child, "buffers." .. scope .. ".bo.swapfile", false)

        eq_option(child, "buffers." .. scope .. ".wo.cursorline", false)
        eq_option(child, "buffers." .. scope .. ".wo.cursorcolumn", false)
        eq_option(child, "buffers." .. scope .. ".wo.number", false)
        eq_option(child, "buffers." .. scope .. ".wo.relativenumber", false)
        eq_option(child, "buffers." .. scope .. ".wo.foldenable", false)
        eq_option(child, "buffers." .. scope .. ".wo.list", false)
    end
end

T["setup()"]["buffers: throws with wrong values"] = function()
    local keyValueSetupErrors = {
        { "backgroundColor", "no-neck-pain" },
        { "blend", 30 },
    }

    for _, keyValueSetupError in pairs(keyValueSetupErrors) do
        helpers.expect.error(function()
            child.lua(string.format(
                [[require('no-neck-pain').setup({
            buffers = {
                %s = "%s",
            },
        })]],
                keyValueSetupError[1],
                keyValueSetupError[2]
            ))
        end)
    end
end

T["setup()"]["overrides default values"] = function()
    child.lua([[require('no-neck-pain').setup({
        width = 42,
        debug = true,
        disableOnLastBuffer = true,
        killAllBuffersOnDisable = true,
        buffers = {
            setNames = true,
            backgroundColor = "catppuccin-frappe",
            blend = 0.4,
            textColor = "#7480c2",
            bo = {
                filetype = "my-file-type",
                buftype = "help",
                bufhidden = "",
                modifiable = true,
                buflisted = true,
                swapfile = true,
            },
            wo = {
                cursorline = true,
                cursorcolumn = true,
                number = true,
                relativenumber = true,
                foldenable = true,
                list = true,
            },
            left = {
                backgroundColor = "catppuccin-frappe",
                blend = 0.2,
            	textColor = "#7480c2",
                bo = {
                    filetype = "my-file-type",
                    buftype = "help",
                    bufhidden = "",
                    modifiable = true,
                    buflisted = true,
                    swapfile = true,
                },
                wo = {
                    cursorline = true,
                    cursorcolumn = true,
                    number = true,
                    relativenumber = true,
                    foldenable = true,
                    list = true,
                },
            },
            right = {
                backgroundColor = "catppuccin-frappe",
                blend = 0.2,
            	textColor = "#7480c2",
                bo = {
                    filetype = "my-file-type",
                    buftype = "help",
                    bufhidden = "",
                    modifiable = true,
                    buflisted = true,
                    swapfile = true,
                },
                wo = {
                    cursorline = true,
                    cursorcolumn = true,
                    number = true,
                    relativenumber = true,
                    foldenable = true,
                    list = true,
                },
            },
        },
    })]])

    -- config
    eq_option(child, "width", 42)
    eq_option(child, "debug", true)
    eq_option(child, "disableOnLastBuffer", true)
    eq_option(child, "killAllBuffersOnDisable", true)

    -- buffers
    eq_type_option(child, "buffers", "table")
    eq_type_option(child, "buffers.bo", "table")
    eq_type_option(child, "buffers.wo", "table")

    eq_option(child, "buffers.setNames", true)
    eq_option(child, "buffers.backgroundColor", "#828590")
    eq_option(child, "buffers.blend", 0.4)
    eq_option(child, "buffers.textColor", "#7480c2")

    eq_option(child, "buffers.bo.filetype", "my-file-type")
    eq_option(child, "buffers.bo.buftype", "help")
    eq_option(child, "buffers.bo.bufhidden", "")
    eq_option(child, "buffers.bo.modifiable", true)
    eq_option(child, "buffers.bo.buflisted", true)
    eq_option(child, "buffers.bo.swapfile", true)

    eq_option(child, "buffers.wo.cursorline", true)
    eq_option(child, "buffers.wo.cursorcolumn", true)
    eq_option(child, "buffers.wo.number", true)
    eq_option(child, "buffers.wo.relativenumber", true)
    eq_option(child, "buffers.wo.foldenable", true)
    eq_option(child, "buffers.wo.list", true)

    for _, scope in pairs(SCOPES) do
        eq_option(child, "buffers." .. scope .. ".backgroundColor", "#595c6b")
        eq_option(child, "buffers." .. scope .. ".blend", 0.2)
        eq_option(child, "buffers." .. scope .. ".textColor", "#7480c2")

        eq_option(child, "buffers." .. scope .. ".bo.filetype", "my-file-type")
        eq_option(child, "buffers." .. scope .. ".bo.buftype", "help")
        eq_option(child, "buffers." .. scope .. ".bo.bufhidden", "")
        eq_option(child, "buffers." .. scope .. ".bo.modifiable", true)
        eq_option(child, "buffers." .. scope .. ".bo.buflisted", true)
        eq_option(child, "buffers." .. scope .. ".bo.swapfile", true)

        eq_option(child, "buffers." .. scope .. ".wo.cursorline", true)
        eq_option(child, "buffers." .. scope .. ".wo.cursorcolumn", true)
        eq_option(child, "buffers." .. scope .. ".wo.number", true)
        eq_option(child, "buffers." .. scope .. ".wo.relativenumber", true)
        eq_option(child, "buffers." .. scope .. ".wo.foldenable", true)
        eq_option(child, "buffers." .. scope .. ".wo.list", true)
    end
end

T["setup()"]["`left` or `right` buffer options overrides `common` ones"] = function()
    child.lua([[require('no-neck-pain').setup({
        buffers = {
            backgroundColor = "catppuccin-frappe",
            blend = 0.1,
            textColor = "#7480c2",
            bo = {
                filetype = "TEST",
            },
            wo = {
                cursorline = false,
            },
            left = {
                backgroundColor = "catppuccin-frappe-dark",
                blend = -0.8,
                textColor = "#123123",
                bo = {
                    filetype = "TEST-left",
                },
                wo = {
                    cursorline = true,
                },
            },
            right = {
                backgroundColor = "catppuccin-latte",
                blend = 1,
                textColor = "#456456",
                bo = {
                    filetype = "TEST-right",
                },
                wo = {
                    number = true,
                },
            },
        },
    })]])

    eq_option(child, "buffers.backgroundColor", "#444858")
    eq_option(child, "buffers.blend", 0.1)
    eq_option(child, "buffers.textColor", "#7480c2")
    eq_option(child, "buffers.bo.filetype", "TEST")
    eq_option(child, "buffers.wo.cursorline", false)

    eq_option(child, "buffers.left.backgroundColor", "#08080b")
    eq_option(child, "buffers.right.backgroundColor", "#ffffff")

    eq_option(child, "buffers.left.blend", -0.8)
    eq_option(child, "buffers.right.blend", 1)

    eq_option(child, "buffers.left.textColor", "#123123")
    eq_option(child, "buffers.right.textColor", "#456456")

    eq_option(child, "buffers.left.bo.filetype", "TEST-left")
    eq_option(child, "buffers.right.bo.filetype", "TEST-right")

    eq_option(child, "buffers.left.wo.cursorline", true)
    eq_option(child, "buffers.right.wo.number", true)
end

T["setup()"]["`common` options spreads it to `left` and `right` buffers"] = function()
    child.lua([[require('no-neck-pain').setup({
        buffers = {
            backgroundColor = "catppuccin-frappe",
            blend = 1,
            bo = {
                filetype = "TEST",
            },
            wo = {
                number = true,
            },
        },
    })]])

    eq_option(child, "buffers.backgroundColor", "#ffffff")
    eq_option(child, "buffers.bo.filetype", "TEST")
    eq_option(child, "buffers.wo.number", true)

    eq_option(child, "buffers.left.backgroundColor", "#ffffff")
    eq_option(child, "buffers.right.backgroundColor", "#ffffff")

    eq_option(child, "buffers.left.blend", 1)
    eq_option(child, "buffers.right.blend", 1)

    eq_option(child, "buffers.left.textColor", "#ffffff")
    eq_option(child, "buffers.right.textColor", "#ffffff")

    eq_option(child, "buffers.left.wo.number", true)
    eq_option(child, "buffers.right.wo.number", true)

    eq_option(child, "buffers.left.bo.filetype", "TEST")
    eq_option(child, "buffers.right.bo.filetype", "TEST")
end

T["setup()"]["colorCode: map integration name to a value"] = function()
    local integrationsMapping = {
        { "catppuccin-frappe", "#303446" },
        { "catppuccin-frappe-dark", "#292c3c" },
        { "catppuccin-latte", "#eff1f5" },
        { "catppuccin-latte-dark", "#e6e9ef" },
        { "catppuccin-macchiato", "#24273a" },
        { "catppuccin-macchiato-dark", "#1e2030" },
        { "catppuccin-mocha", "#1e1e2e" },
        { "catppuccin-mocha-dark", "#181825" },
        { "tokyonight-day", "#16161e" },
        { "tokyonight-moon", "#1e2030" },
        { "tokyonight-storm", "#1f2335" },
        { "tokyonight-night", "#16161e" },
        { "rose-pine", "#191724" },
        { "rose-pine-moon", "#232136" },
        { "rose-pine-dawn", "#faf4ed" },
    }

    for _, integration in pairs(integrationsMapping) do
        child.lua(string.format(
            [[require('no-neck-pain').setup({
                buffers = {
                    backgroundColor = "%s",
                    left = { backgroundColor = "%s" },
                    right = { backgroundColor = "%s" },
                },
            })]],
            integration[1],
            integration[1],
            integration[1]
        ))
        for _, scope in pairs(SCOPES) do
            eq_option(child, "buffers." .. scope .. ".backgroundColor", integration[2])
        end
    end
end

T["enable()"] = MiniTest.new_set()

T["enable()"]["sets state and internal methods"] = function()
    child.lua([[
        require('no-neck-pain').setup({width=50})
        require('no-neck-pain').enable()
    ]])

    -- internal methods
    eq_type_global(child, "_G.NoNeckPain.internal.toggle", "function")
    eq_type_global(child, "_G.NoNeckPain.internal.enable", "function")
    eq_type_global(child, "_G.NoNeckPain.internal.disable", "function")

    -- state
    eq_type_global(child, "_G.NoNeckPain.state", "table")

    eq_state(child, "enabled", true)
    eq_state(child, "augroup", 15)

    eq_type_state(child, "win", "table")
    eq_type_state(child, "win.main", "table")
    eq_type_state(child, "win.external", "table")

    eq_state(child, "win.main.curr", 1000)
    eq_state(child, "win.main.left", 1001)
    eq_state(child, "win.main.right", 1002)
    eq_state(child, "win.main.split", vim.NIL)
    eq_state(child, "vsplit", false)

    eq_type_state(child, "win.external.trees", "table")

    local integrations = { "NvimTree", "undotree" }
    for _, integration in pairs(integrations) do
        eq_state(child, "win.external.trees." .. integration .. ".id", vim.NIL)
        eq_state(child, "win.external.trees." .. integration .. ".width", 0)
    end
end

T["disable()"] = MiniTest.new_set()

T["disable()"]["resets state and remove internal methods"] = function()
    child.lua([[require('no-neck-pain').disable()]])

    -- state
    eq_type_global(child, "_G.NoNeckPain.state", "table")

    eq_state(child, "enabled", false)
    eq_state(child, "augroup", vim.NIL)

    eq_type_state(child, "win", "table")
    eq_type_state(child, "win.main", "table")
    eq_type_state(child, "win.external", "table")

    eq_state(child, "win.main.curr", vim.NIL)
    eq_state(child, "win.main.left", vim.NIL)
    eq_state(child, "win.main.right", vim.NIL)
    eq_state(child, "win.main.split", vim.NIL)
    eq_state(child, "vsplit", false)

    eq_type_state(child, "win.external.trees", "table")

    local integrations = { "NvimTree", "undotree" }
    for _, integration in pairs(integrations) do
        eq_state(child, "win.external.trees." .. integration .. ".id", vim.NIL)
        eq_state(child, "win.external.trees." .. integration .. ".width", 0)
    end
end

T["toggle()"] = MiniTest.new_set()

T["toggle()"]["sets state and internal methods and resets everything when toggled again"] =
    function()
        child.lua([[
        require('no-neck-pain').setup({width=50})
        require('no-neck-pain').enable()
    ]])

        -- internal methods
        eq_type_global(child, "_G.NoNeckPain.internal.toggle", "function")
        eq_type_global(child, "_G.NoNeckPain.internal.enable", "function")
        eq_type_global(child, "_G.NoNeckPain.internal.disable", "function")

        -- state
        eq_type_global(child, "_G.NoNeckPain.state", "table")

        eq_state(child, "enabled", true)
        eq_state(child, "augroup", 15)

        eq_type_state(child, "win", "table")
        eq_type_state(child, "win.main", "table")
        eq_type_state(child, "win.external", "table")

        eq_state(child, "win.main.curr", 1000)
        eq_state(child, "win.main.left", 1001)
        eq_state(child, "win.main.right", 1002)
        eq_state(child, "win.main.split", vim.NIL)
        eq_state(child, "vsplit", false)

        eq_type_state(child, "win.external.trees", "table")

        local integrations = { "NvimTree", "undotree" }
        for _, integration in pairs(integrations) do
            eq_state(child, "win.external.trees." .. integration .. ".id", vim.NIL)
            eq_state(child, "win.external.trees." .. integration .. ".width", 0)
        end

        -- disable
        child.lua([[require('no-neck-pain').toggle()]])

        -- state
        eq_type_state(child, "win", "table")

        eq_state(child, "enabled", false)
        eq_state(child, "augroup", vim.NIL)

        eq_type_state(child, "win", "table")
        eq_type_state(child, "win.main", "table")
        eq_type_state(child, "win.external", "table")

        eq_state(child, "win.main.curr", vim.NIL)
        eq_state(child, "win.main.left", vim.NIL)
        eq_state(child, "win.main.right", vim.NIL)
        eq_state(child, "win.main.split", vim.NIL)
        eq_state(child, "vsplit", false)

        eq_type_state(child, "win.external.tree", "table")
        eq_state(child, "win.external.tree.id", vim.NIL)
        eq_state(child, "win.external.tree.width", 0)
    end

return T
