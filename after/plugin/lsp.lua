local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
    lsp.default_keymaps({ buffer = bufnr })
    local opts = { buffer = bufnr }

    vim.keymap.set({ 'n', 'x' }, 'gq', function()
        vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
    end, opts)
    vim.keymap.set('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
end)

lsp.ensure_installed({
    'tsserver',
    'intelephense',
})

local lspconfig = require('lspconfig')
-- (Optional) Configure lua language server for neovim
lspconfig.lua_ls.setup(lsp.nvim_lua_ls())

lspconfig.helm_ls.setup {
    settings = {
        ['helm-ls'] = {
            yamlls = {
                enabled = false,
                path = "yaml-language-server",
            }
        }
    }
}

lsp.skip_server_setup({ 'jdtls' })

lsp.setup()
