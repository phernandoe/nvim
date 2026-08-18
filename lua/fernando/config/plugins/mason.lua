-- Prepends mason's bin directory to $PATH, which is how the language servers
-- enabled in lsp.lua get found. Must run before any `vim.lsp.enable()` call.
require("mason").setup()
