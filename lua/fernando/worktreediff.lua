-- Pick a worktree of the current repository, then review everything that
-- worktree changed against the default branch -- committed and uncommitted --
-- as a difftool hunk list, with gitgutter marking the changes in each file.
--
-- The merge base is deliberate: a worktree branch is cut from origin/HEAD and
-- the default branch moves on afterwards, so a two-dot `diff master HEAD` would
-- report every later master commit as a deletion of your own work.

local M = {}

local BASE_CANDIDATES = { "origin/master", "origin/main", "master", "main" }

-- gitgutter's diff base is a global, and pointing it at a merge-base SHA makes
-- every other repository warn that the base is invalid. Bind it to the tab that
-- asked for it instead: inside a review tab the signs are relative to the merge
-- base, everywhere else they go back to the index.
vim.api.nvim_create_autocmd("TabEnter", {
    group = vim.api.nvim_create_augroup("fernando.worktreediff", { clear = true }),
    callback = function()
        local wanted = vim.t.worktreediff_base or ""
        if vim.g.gitgutter_diff_base ~= wanted then
            vim.g.gitgutter_diff_base = wanted
            pcall(vim.cmd, "GitGutterAll")
        end
    end,
})

local function git(path, args)
    local command = vim.list_extend({ "git", "-C", path }, args)
    local result = vim.system(command, { text = true }):wait()
    if result.code ~= 0 then
        return nil
    end
    return vim.trim(result.stdout)
end

local function default_branch(path)
    local origin_head = git(path, { "symbolic-ref", "--quiet", "--short", "refs/remotes/origin/HEAD" })
    if origin_head and origin_head ~= "" then
        return origin_head
    end
    for _, candidate in ipairs(BASE_CANDIDATES) do
        if git(path, { "rev-parse", "--verify", "--quiet", candidate .. "^{commit}" }) then
            return candidate
        end
    end
    return nil
end

local function worktrees(path)
    local listing = git(path, { "worktree", "list", "--porcelain" })
    if not listing or listing == "" then
        return {}
    end

    local found, current = {}, nil
    for _, line in ipairs(vim.split(listing, "\n")) do
        local root = line:match("^worktree (.+)$")
        local branch = line:match("^branch refs/heads/(.+)$")
        if root then
            current = { path = root, branch = "detached" }
            table.insert(found, current)
        elseif branch and current then
            current.branch = branch
        end
    end
    return found
end

-- Never open a tab there is nothing to look at in.
local function has_changes(worktree)
    if not worktree.base then
        vim.notify("worktreediff: no merge base for " .. worktree.path, vim.log.levels.WARN)
        return false
    end
    local changed = git(worktree.path, { "diff", "--name-only", worktree.base })
    if not changed or changed == "" then
        vim.notify(("worktreediff: %s has no changes against its merge base"):format(worktree.branch), vim.log.levels.INFO)
        return false
    end
    return true
end

function M.difftool(worktree)
    if not has_changes(worktree) then
        return
    end

    -- A tab-local cwd is what makes fugitive resolve the picked worktree's
    -- gitdir, so its uncommitted changes show up too.
    vim.cmd("tabnew")
    vim.cmd("tcd " .. vim.fn.fnameescape(worktree.path))

    -- Claimed before any file is opened, so the first buffer is already marked
    -- against the merge base. The TabEnter autocmd releases it on the way out.
    vim.t.worktreediff_base = worktree.base
    vim.g.gitgutter_diff_base = worktree.base

    -- difftool opens the working copy of the first changed file, and a FileType
    -- autocmd there can raise. The quickfix list is populated regardless, so an
    -- error must not abort the view.
    pcall(vim.cmd, "Git difftool " .. worktree.base)
    vim.cmd("copen")
    pcall(vim.cmd, "GitGutterAll")
end

function M.pick()
    local anchor = vim.fn.expand("%:p:h")
    if anchor == "" or vim.fn.isdirectory(anchor) == 0 then
        anchor = vim.fn.getcwd()
    end

    local found = worktrees(anchor)
    if vim.tbl_isempty(found) then
        vim.notify("worktreediff: not inside a git repository", vim.log.levels.WARN)
        return
    end

    local base = default_branch(anchor)
    if not base then
        vim.notify("worktreediff: no default branch to diff against", vim.log.levels.WARN)
        return
    end

    local width = 0
    for _, worktree in ipairs(found) do
        worktree.base = git(worktree.path, { "merge-base", base, "HEAD" })
        width = math.max(width, #worktree.branch)
    end

    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local previewers = require("telescope.previewers")
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local values = require("telescope.config").values

    pickers.new({}, {
        prompt_title = "Worktrees vs " .. base,
        finder = finders.new_table({
            results = found,
            entry_maker = function(worktree)
                return {
                    value = worktree,
                    path = worktree.path,
                    ordinal = worktree.branch .. " " .. worktree.path,
                    display = string.format("%-" .. width .. "s  %s", worktree.branch, vim.fn.fnamemodify(worktree.path, ":~")),
                }
            end,
        }),
        sorter = values.generic_sorter({}),
        previewer = previewers.new_termopen_previewer({
            title = "Changed files",
            get_command = function(entry)
                if not entry.value.base then
                    return { "echo", "no merge base with " .. base }
                end
                return { "git", "-C", entry.value.path, "diff", "--stat", entry.value.base }
            end,
        }),
        attach_mappings = function(prompt_buffer)
            actions.select_default:replace(function()
                actions.close(prompt_buffer)
                local entry = action_state.get_selected_entry()
                if entry then
                    M.difftool(entry.value)
                end
            end)
            return true
        end,
    }):find()
end

vim.keymap.set("n", "<leader>gw", M.pick, { desc = "Review a worktree against the default branch" })
vim.api.nvim_create_user_command("WorktreeDiff", M.pick, { desc = "Review a worktree against the default branch" })

return M
