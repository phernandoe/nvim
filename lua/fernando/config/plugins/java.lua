-- Under lazy.nvim all of this was dead code: the jdtls `settings` and the
-- `require("java").setup()` call sat in an `opts` table on the nvim-lspconfig
-- dependency, and lsp.lua declared nvim-lspconfig with a `config` function,
-- which made lazy.nvim ignore `opts` entirely. Neither ever ran.

-- The old config passed the `java_home` command line itself as `path`, which
-- jdtls cannot use. Resolve it for real, and omit the entry if there is no JDK 21.
local function java_21_runtimes()
    local home = vim.trim(vim.fn.system({ "/usr/libexec/java_home", "-v21" }))
    if vim.v.shell_error ~= 0 or home == "" then
        return {}
    end
    return { { name = "JavaSE-21", path = home } }
end

-- nvim-java downloads jdtls and its bundles the first time it is set up, so keep
-- it behind the Java filetype the way `ft = { "java" }` used to.
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("fernando.java", { clear = true }),
    pattern = "java",
    once = true,
    desc = "Set up nvim-java and start jdtls on the first Java buffer",
    callback = function()
        -- Builds jdtls' cmd, environment, bundles, root markers and filetypes.
        require("java").setup()

        -- `vim.lsp.config` deep-merges and the last writer wins, so this has to
        -- come after nvim-java to survive.
        vim.lsp.config("jdtls", {
            settings = {
                java = {
                    eclipse = { downloadSources = true },
                    maven = { downloadSources = true },
                    implementationsCodeLens = { enabled = true },
                    referencesCodeLens = { enabled = true },
                    format = { enabled = true },
                    configuration = {
                        runtimes = java_21_runtimes(),
                    },
                    sources = {
                        organizeImports = {
                            starThreshold = 9999,
                            staticStarThreshold = 9999,
                        },
                    },
                    codeGeneration = {
                        toString = {
                            template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}',
                        },
                        useBlocks = true,
                    },
                },
            },
        })

        vim.lsp.enable("jdtls")
    end,
})
