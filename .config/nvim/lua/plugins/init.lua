--[[
=====================================================================
                           Plugin Specifications
=====================================================================
Each file in this directory returns a plugin spec table for lazy.nvim
=====================================================================
--]]

return {
  -- Colorscheme
  { import = "plugins.colorscheme" },

  -- UI
  { import = "plugins.ui" },

  -- Editor enhancements
  { import = "plugins.editor" },

  -- LSP & Completion
  { import = "plugins.lsp" },

  -- Treesitter
  { import = "plugins.treesitter" },

  -- Telescope (fuzzy finder)
  { import = "plugins.telescope" },

  -- Git
  { import = "plugins.git" },

  -- Terminal
  { import = "plugins.terminal" },

  -- Utility
  { import = "plugins.utility" },
}