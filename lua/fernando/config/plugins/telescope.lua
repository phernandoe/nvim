return {
    'nvim-telescope/telescope.nvim',
    branch = 'master',
      dependencies = { 
          'nvim-lua/plenary.nvim',
          { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
      },
    config = function()
        vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files)
        vim.keymap.set('n', '<leader>fg', require('telescope.builtin').git_files)
        vim.keymap.set('n', '<leader>ss', require('telescope.builtin').lsp_document_symbols)
        vim.keymap.set('n', '<leader>fb', require('telescope.builtin').buffers)
        vim.keymap.set('n', '<leader>fh', require('telescope.builtin').help_tags)
        vim.keymap.set('n', '<leader>sf', function ()
            require('telescope.builtin').grep_string {
                search = vim.fn.input("Grep > ")
            }
        end)
    end
}
