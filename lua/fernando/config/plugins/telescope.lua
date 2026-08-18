local builtin = require("telescope.builtin")

vim.keymap.set('n', '<leader>ff', builtin.find_files)
vim.keymap.set('n', '<leader>fg', builtin.git_files)
vim.keymap.set('n', '<leader>ss', builtin.lsp_document_symbols)
vim.keymap.set('n', '<leader>fb', builtin.buffers)
vim.keymap.set('n', '<leader>fh', builtin.help_tags)
vim.keymap.set('n', '<leader>sf', function()
    builtin.grep_string {
        search = vim.fn.input("Grep > ")
    }
end)
vim.keymap.set('n', '<leader>fd', function()
    builtin.find_files {
        cwd = '~/dev/',
        find_command = { 'ls' }
    }
end)
