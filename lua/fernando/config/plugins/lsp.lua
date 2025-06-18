return {
  "neovim/nvim-lspconfig",
  config = function()
      vim.lsp.enable('intelephense')
      vim.lsp.enable('jdtls')
  end,
}

