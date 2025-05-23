local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
    lsp.default_keymaps({ buffer = bufnr })
    local opts = { buffer = bufnr }

    vim.keymap.set({ 'n', 'x' }, 'gq', function()
        vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
    end, opts)
    vim.keymap.set('n', 'gr', '<cmd>Telescope lsp_references<cr>', opts)
    vim.keymap.set('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
end)

lsp.ensure_installed({
    'intelephense',
})

local lspconfig = require('lspconfig')
lspconfig.lua_ls.setup(lsp.nvim_lua_ls()) -- (Optional) Configure lua language server for neovim
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
