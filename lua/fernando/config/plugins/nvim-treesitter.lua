-- Ported from the lazy.nvim spec. Original idea from
-- https://github.com/fredrikaverpil/dotfiles/blob/main/nvim-fredrik/lua/fredrik/plugins/core/treesitter.lua
local ensure_installed = {
	"bash",
	"c",
	"css",
	"diff",
	"html",
	"javascript",
	"jsdoc",
	"json",
	"json5",
	"lua",
	"luadoc",
	"luap",
	"markdown",
	"markdown_inline",
	"python",
	"query",
	"regex",
	"toml",
	"tsx",
	"typescript",
	"vim",
	"vimdoc",
	"yaml",
	"java",
	"php",
}

-- zsh has no dedicated parser; use bash
vim.treesitter.language.register("bash", "zsh")
-- neither does jsonc; asking to install it only produces a warning
vim.treesitter.language.register("json", "jsonc")

-- This module used to be loaded on BufRead. It now runs at startup, so only ask
-- for the parsers that are actually missing instead of on every launch.
local installed = {}
for _, parser in ipairs(require("nvim-treesitter").get_installed("parsers")) do
	installed[parser] = true
end

local missing = vim.tbl_filter(function(parser)
	return not installed[parser]
end, ensure_installed)

if #missing > 0 then
	require("nvim-treesitter").install(missing)
end

-- register and start parsers for filetypes
for _, parser in ipairs(ensure_installed) do
	local filetypes = parser -- In this case, parser is the filetype/language name
	vim.treesitter.language.register(parser, filetypes)

	vim.api.nvim_create_autocmd({ "FileType" }, {
		pattern = filetypes,
		callback = function(event)
			vim.treesitter.start(event.buf, parser)
		end,
	})
end

-- Auto-install and start parsers for any buffer.
-- This hangs off FileType rather than the original BufRead: an autocmd registered
-- while init.lua runs fires before filetype detection, so on BufRead the filetype
-- is still empty and every buffer took the early return. lazy.nvim happened to
-- hide that by re-emitting BufRead after it loaded the plugin.
vim.api.nvim_create_autocmd({ "FileType" }, {
	callback = function(event)
		local bufnr = event.buf
		local filetype = event.match

		-- Skip if no filetype
		if filetype == "" then
			return
		end

		-- Check if this filetype is already handled by the explicit list above
		for _, filetypes in pairs(ensure_installed) do
			local ft_table = type(filetypes) == "table" and filetypes or { filetypes }
			if vim.tbl_contains(ft_table, filetype) then
				return -- Already handled above
			end
		end

		-- Get parser name based on filetype
		local parser_name = vim.treesitter.language.get_lang(filetype) -- might return filetype (not helpful)
		if not parser_name then
			return
		end
		-- Try to get existing parser (helpful check if filetype was returned above)
		local parser_configs = require("nvim-treesitter.parsers")
		if not parser_configs[parser_name] then
			return -- Parser not available, skip silently
		end

		local parser_installed = pcall(vim.treesitter.get_parser, bufnr, parser_name)

		if not parser_installed then
			-- If not installed, install parser synchronously
			require("nvim-treesitter").install({ parser_name }):wait(30000)
		end

		-- let's check again
		parser_installed = pcall(vim.treesitter.get_parser, bufnr, parser_name)

		if parser_installed then
			-- Start treesitter for this buffer
			vim.treesitter.start(bufnr, parser_name)
		end
	end,
})

require("treesitter-context").setup({
	multiwindow = true,
})

require("nvim-treesitter-textobjects").setup({
	multiwindow = true,
})

local select_textobject = function(query, group)
	return function()
		require("nvim-treesitter-textobjects.select").select_textobject(query, group)
	end
end

vim.keymap.set({ "x", "o" }, "af", select_textobject("@function.outer", "textobjects"), { desc = "Select outer function" })
vim.keymap.set({ "x", "o" }, "if", select_textobject("@function.inner", "textobjects"), { desc = "Select inner function" })
vim.keymap.set({ "x", "o" }, "ac", select_textobject("@class.outer", "textobjects"), { desc = "Select outer class" })
vim.keymap.set({ "x", "o" }, "ic", select_textobject("@class.inner", "textobjects"), { desc = "Select inner class" })
vim.keymap.set({ "x", "o" }, "as", select_textobject("@local.scope", "locals"), { desc = "Select local scope" })
