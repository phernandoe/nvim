vim.keymap.set("n", "Q", "<nop>")
-- keep search terms in the middle of screen
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "gd", vim.lsp.buf.definition)
