vim.keymap.set('n', 'gd', vim.lsp.buf.definition)

return { 
    "nvim-treesitter/nvim-treesitter",
    branch = 'main',
    lazy = false,
    build = ":TSUpdate",
    opts = function()
      return {
        ensure_installed = { "java", "php", "javascript", "typescript", "python", "c", "lua", "vim" },
        sync_install = false,
        auto_install = true,
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
        },
      }
    end,
}

