return {
  "lervag/vimtex",
  lazy = false, -- we don't want to lazy load VimTeX
  -- tag = "v2.15", -- uncomment to pin to a specific release
  init = function()
    -- VimTeX configuration goes here, e.g.
    vim.g.vimtex_view_method = "zathura_simple"
    -- vim.g.vimtex_view_skim_sync = 1
    vim.g.vimtex_quickfix_ignore_filters = {
      "Underfull",
      "Overfull",
    }
    vim.o.conceallevel = 1
    vim.g.tex_conceal = "abdmg"
    -- vim.g.vimtex_view_forward_search_on_start = 0
    vim.g.vimtex_compiler_latexmk = {
      aux_dir = "/Users/econhead/.texfiles/",
    }
    vim.g.vimtex_quickfix_mode = 0
  end,
}
