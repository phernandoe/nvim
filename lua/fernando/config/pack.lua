-- Plugin management with the built-in |vim.pack|. Plugins are cloned into
-- `stdpath("data")/site/pack/core/opt` and their exact revisions are tracked in
-- `nvim-pack-lock.json` next to this file's config root -- that lockfile is the
-- replacement for `lazy-lock.json` and belongs in git.

local github = function(repo)
    return "https://github.com/" .. repo
end

-- Build steps have to be registered before the first `vim.pack.add()` call, so
-- that they fire on a cold install and not only on later updates.
vim.api.nvim_create_autocmd("PackChanged", {
    group = vim.api.nvim_create_augroup("fernando.pack.build", { clear = true }),
    callback = function(event)
        local name, kind = event.data.spec.name, event.data.kind
        if kind ~= "install" and kind ~= "update" then
            return
        end

        if name == "telescope-fzf-native.nvim" then
            -- Compiles libfzf.so. Blocking, because telescope may look for it
            -- immediately after this call returns.
            vim.system({ "make" }, { cwd = event.data.path }):wait()
        elseif name == "nvim-treesitter" and kind == "update" then
            -- Stands in for `build = ":TSUpdate"`. On a fresh install the
            -- parsers are pulled by the treesitter module instead.
            pcall(function()
                require("nvim-treesitter").update()
            end)
        end
    end,
})

vim.pack.add({
    -- Colorscheme first so everything loaded after it renders correctly.
    { src = github("ellisonleao/gruvbox.nvim") },

    { src = github("mason-org/mason.nvim") },

    -- Completion, and the snippet collection it reads from.
    { src = github("rafamadriz/friendly-snippets") },
    { src = github("saghen/blink.cmp"), version = vim.version.range("1.*") },

    { src = github("neovim/nvim-lspconfig") },

    -- nvim-java plus the three plugins it depends on. spring-boot.nvim is
    -- pinned to the revision nvim-java itself pins.
    { src = github("MunifTanjim/nui.nvim") },
    { src = github("mfussenegger/nvim-dap") },
    { src = github("JavaHello/spring-boot.nvim"), version = "218c0c26c14d99feca778e4d13f5ec3e8b1b60f0" },
    { src = github("nvim-java/nvim-java") },

    { src = github("nvim-tree/nvim-web-devicons") },
    { src = github("nvim-lualine/lualine.nvim") },

    -- The treesitter rewrite this config is written against lives on `main`,
    -- not on the repository's default branch.
    { src = github("nvim-treesitter/nvim-treesitter"), version = "main" },
    { src = github("nvim-treesitter/nvim-treesitter-textobjects"), version = "main" },
    { src = github("nvim-treesitter/nvim-treesitter-context") },

    { src = github("nvim-lua/plenary.nvim") },
    { src = github("nvim-telescope/telescope-fzf-native.nvim") },
    { src = github("nvim-telescope/telescope.nvim"), version = "master" },

    { src = github("tpope/vim-fugitive") },
    { src = github("airblade/vim-gitgutter") },
}, { confirm = false })

-- `vim.pack.add()` only puts plugins on the runtimepath. Each module below does
-- the configuring that lazy.nvim used to drive from `opts` and `config`, in
-- dependency order.
require("fernando.config.plugins.colorscheme")
require("fernando.config.plugins.mason")
require("fernando.config.plugins.completion")
require("fernando.config.plugins.lsp")
require("fernando.config.plugins.java")
require("fernando.config.plugins.lualine")
require("fernando.config.plugins.nvim-treesitter")
require("fernando.config.plugins.telescope")
require("fernando.config.plugins.vim-fugitive")
