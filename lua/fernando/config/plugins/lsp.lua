return {
    "neovim/nvim-lspconfig",
    dependencies = { 'saghen/blink.cmp' },
    config = function()
        local capabilities = require('blink.cmp').get_lsp_capabilities()
        vim.lsp.config('lua_ls', { setup = { capabilities = capabilities } })

        vim.lsp.enable('intelephense')
        vim.lsp.enable('jdtls')
        vim.lsp.enable('ts_ls')
        vim.lsp.enable('lua_ls')
    end,
}
