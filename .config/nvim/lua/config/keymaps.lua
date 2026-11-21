--[[
=====================================================================
                           Keymaps
=====================================================================
--]]

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Better window navigation
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- Resize windows
map("n", "<C-Up>", ":resize +2<CR>", opts)
map("n", "<C-Down>", ":resize -2<CR>", opts)
map("n", "<C-Left>", ":vertical resize -2<CR>", opts)
map("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Buffer navigation
map("n", "<S-h>", ":bprevious<CR>", opts)
map("n", "<S-l>", ":bnext<CR>", opts)
map("n", "<leader>bd", ":bdelete<CR>", opts)
map("n", "<leader>bo", ":%bd|e#<CR>", opts)

-- Better indenting in visual mode
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- Move lines up/down
map("n", "<A-j>", ":m .+1<CR>==", opts)
map("n", "<A-k>", ":m .-2<CR>==", opts)
map("v", "<A-j>", ":m '>+1<CR>gv=gv", opts)
map("v", "<A-k>", ":m '<-2<CR>gv=gv", opts)

-- Clear search highlight
map("n", "<leader>h", ":nohlsearch<CR>", opts)

-- Better escape
map("i", "jk", "<ESC>", opts)
map("i", "kj", "<ESC>", opts)

-- Save file
map("n", "<leader>w", ":w<CR>", opts)
map("n", "<leader>q", ":q<CR>", opts)
map("n", "<leader>Q", ":qa!<CR>", opts)

-- Toggle options
map("n", "<leader>tn", ":set number! relativenumber!<CR>", opts)
map("n", "<leader>tw", ":set wrap!<CR>", opts)
map("n", "<leader>ts", ":set spell!<CR>", opts)

-- Colorscheme toggle (Tokyo Night -> Catppuccin -> Gruvbox Material)
local colorschemes = { "tokyonight", "catppuccin-mocha", "gruvbox-material" }
local current_scheme = 1
map("n", "<leader>tc", function()
  current_scheme = current_scheme % #colorschemes + 1
  vim.cmd.colorscheme(colorschemes[current_scheme])
  vim.notify("Colorscheme: " .. colorschemes[current_scheme], vim.log.levels.INFO)
end, { desc = "Cycle colorscheme" })

-- Toggle transparency
map("n", "<leader>tT", function()
  local normal_hl = vim.api.nvim_get_hl(0, { name = "Normal" })
  if normal_hl.bg then
    -- Make transparent
    vim.api.nvim_set_hl(0, "Normal", { fg = normal_hl.fg, bg = "NONE" })
    vim.api.nvim_set_hl(0, "NormalNC", { fg = normal_hl.fg, bg = "NONE" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "FloatBorder", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "TabLine", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "TabLineFill", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WinSeparator", { bg = "NONE" })
    vim.notify("Transparency: ON", vim.log.levels.INFO)
  else
    -- Reload colorscheme to restore backgrounds
    vim.cmd.colorscheme(vim.g.colors_name or "tokyonight")
    vim.notify("Transparency: OFF", vim.log.levels.INFO)
  end
end, { desc = "Toggle transparency" })

-- Terminal
map("t", "<Esc>", "<C-\\><C-n>", opts)
map("t", "<C-h>", "<C-\\><C-n><C-w>h", opts)
map("t", "<C-j>", "<C-\\><C-n><C-w>j", opts)
map("t", "<C-k>", "<C-\\><C-n><C-w>k", opts)
map("t", "<C-l>", "<C-\\><C-n><C-w>l", opts)

-- Diagnostic navigation
map("n", "[d", vim.diagnostic.goto_prev, opts)
map("n", "]d", vim.diagnostic.goto_next, opts)
map("n", "<leader>e", vim.diagnostic.open_float, opts)
map("n", "<leader>q", vim.diagnostic.setloclist, opts)

-- LSP keymaps (set in on_attach in lsp.lua)
-- See lua/config/lsp.lua for LSP-specific keymaps

-- Quickfix navigation
map("n", "]q", ":cnext<CR>", opts)
map("n", "[q", ":cprev<CR>", opts)

-- Lazy
map("n", "<leader>l", ":Lazy<CR>", opts)
map("n", "<leader>L", ":Lazy sync<CR>", opts)

-- Mason
map("n", "<leader>m", ":Mason<CR>", opts)