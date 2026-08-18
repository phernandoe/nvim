-- blink.cmp registers its completion capabilities for every server from its own
-- `plugin/` file, so there is nothing to wire up by hand here.
-- jdtls is enabled from java.lua, because nvim-java has to build its config first.
vim.lsp.enable({ "intelephense", "ts_ls", "lua_ls" })
