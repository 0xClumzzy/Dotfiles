--[[
=====================================================================
                           Core Options
=====================================================================
--]]

local opt = vim.opt
local g = vim.g

-- Leader keys (must be set before plugins load)
g.mapleader = " "
g.maplocalleader = " "

-- Enable faster startup by caching compiled Lua modules
vim.loader.enable()

-- UI
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.colorcolumn = "100"
opt.scrolloff = 10
opt.sidescrolloff = 8
opt.wrap = false
opt.linebreak = true
opt.breakindent = true
opt.showbreak = "↳ "
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣", extends = "→", precedes = "←" }
opt.fillchars = { eob = " ", fold = " ", foldopen = "▾", foldsep = "│", foldclose = "▸" }
opt.termguicolors = true
opt.winblend = 0          -- transparency for floating windows (0 = opaque, 100 = fully transparent)
opt.pumblend = 10         -- transparency for popup menu
opt.conceallevel = 2
opt.concealcursor = "nc"

-- Transparency support (works with transparent colorschemes)
opt.background = "dark"

-- Editing
opt.mouse = "a"
opt.undofile = true
opt.undolevels = 10000
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.confirm = true
opt.autowrite = true
opt.autoread = true
opt.clipboard = "unnamedplus"
opt.completeopt = "menu,menuone,noselect,preview"
opt.inccommand = "split"
opt.virtualedit = "block"
opt.formatoptions = "jcroqlnt"
opt.textwidth = 100

-- Indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.smartindent = true
opt.shiftround = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Splits
opt.splitright = true
opt.splitbelow = true

-- Timing
opt.updatetime = 200
opt.timeoutlen = 300
opt.ttimeoutlen = 10

-- Folding (using treesitter)
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true
opt.foldcolumn = "1"

-- Session
opt.sessionoptions = "buffers,curdir,folds,help,tabpages,terminal,globals"

-- Spell
opt.spelllang = { "en" }
opt.spelloptions = "camel"

-- Diff
opt.diffopt:append("linematch:60")
opt.diffopt:append("algorithm:histogram")

-- Provider shortcuts
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0

-- Diagnostics
vim.diagnostic.config({
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },
  virtual_text = {
    spacing = 4,
    prefix = "●",
    format = function(diagnostic)
      local icons = {
        [vim.diagnostic.severity.ERROR] = " ",
        [vim.diagnostic.severity.WARN] = " ",
        [vim.diagnostic.severity.INFO] = " ",
        [vim.diagnostic.severity.HINT] = " ",
      }
      return string.format("%s %s", icons[diagnostic.severity] or "", diagnostic.message)
    end,
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.INFO] = " ",
      [vim.diagnostic.severity.HINT] = " ",
    },
  },
})

-- Better command-line completion
opt.wildmode = "longest:full,full"
opt.wildignorecase = true
opt.wildignore = { "*.o", "*.obj", "*.pyc", "*.class", "*.jar", "*.war", "*.ear", "*.zip", "*.tar.gz", "*.tar.bz2", "*.rar", "*.tar.xz", "*/node_modules/*", "*/.git/*", "*/target/*", "*/build/*", "*/dist/*" }

-- Nerd font detection
g.have_nerd_font = vim.fn.has("gui_running") == 1 or os.getenv("TERM"):match("kitty") or os.getenv("TERM_PROGRAM") == "vscode" or os.getenv("TERM_PROGRAM") == "WezTerm"