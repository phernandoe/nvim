return {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
      dependencies = { 'nvim-lua/plenary.nvim' },
      keys = {
          { "<leader>sf", function() require("telescope.builtin").grep_string({search = vim.fn.input("Grep > ")}) end},
          { "<leader>ff", function() require("telescope.builtin").find_files({}) end},
          { "<leader>fg", function() require("telescope.builtin").git_files({}) end},
          { "<leader>ss", function() require("telescope.builtin").lsp_document_symbols({}) end},
    }
}
