require("econhead.core")
require("econhead.lazy")
vim.g.python3_host_prog = "/Users/econhead/sympy-venv/bin/python"

-- Load snippets from ~/.config/nvim/LuaSnip/
require("luasnip.loaders.from_lua").load({ paths = { "~/.config/nvim/LuaSnip/" } })
-- Somewhere in your Neovim startup, e.g. init.lua
require("luasnip").config.set_config({ -- Setting LuaSnip config

  -- Enable autotriggered snippets
  enable_autosnippets = true,

  -- Use Tab (or some other key if you prefer) to trigger visual selection
  store_selection_keys = "<Tab>",
})
local vimrc = vim.fn.stdpath("config") .. "/vimrc.vim"
vim.cmd.source(vimrc)

vim.cmd([[autocmd BufEnter *.pdf execute "!zathura '%'" | bdelete %]])
