--[[
=====================================================================
                     Modular Neovim Configuration
=====================================================================
This configuration is organized into modules under lua/config/
Each module handles a specific aspect of the editor.
=====================================================================
--]]

-- Bootstrap lazy.nvim (modern plugin manager)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load core configuration modules
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- Load plugins via lazy.nvim
require("lazy").setup("plugins", {
  defaults = { lazy = true },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = { enabled = true, notify = false },
  change_detection = { notify = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "matchit", "matchparen", "netrwPlugin",
        "tarPlugin", "tohtml", "tutor", "zipPlugin",
      },
    },
  },
})

-- Load LSP configuration
require("config.lsp")