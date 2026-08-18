## What's in the box:

Neovim config on the built-in plugin manager, |vim.pack| (requires Neovim 0.12+).

### Layout

| Path | What it is |
| --- | --- |
| `init.lua` | Enables the Lua module cache, then loads `lua/fernando`. |
| `lua/fernando/config/pack.lua` | The plugin list: `vim.pack.add(...)` plus build hooks, then loads each plugin module. |
| `lua/fernando/config/plugins/*.lua` | One module per plugin, configuring it imperatively. |
| `lua/fernando/{set,remap,autocmds}.lua` | Options, keymaps, autocommands. |
| `nvim-pack-lock.json` | Resolved plugin revisions. Tracked in git; do not edit by hand. |

### Managing plugins

- **Add one**: a `{ src = github("owner/repo") }` entry in `pack.lua`, plus a module in
  `plugins/` if it needs configuring. Restart.
- **Update**: `:lua vim.pack.update()`, review the confirmation buffer, `:w` to accept
  or `:q` to discard, then `:restart`.
- **Remove**: delete the entry from `pack.lua`, then `:lua vim.pack.del({ "name" })`.
- **Inspect**: `:lua vim.pack.update(nil, { offline = true })`.

Plugins live in `stdpath("data")/site/pack/core/opt`.
