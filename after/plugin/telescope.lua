local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.git_files, {})
vim.keymap.set('n', '<leader>ss', builtin.lsp_document_symbols, {})
vim.keymap.set('n', '<leader>sf', function()
    builtin.grep_string({search = vim.fn.input("Grep > ")})
end)
