return {
  -- Tokyo Night with transparency & cursive (italic) text
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",        -- storm, night, moon, day
      transparent = true,     -- transparent background
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = { italic = true },
        variables = { italic = true },
        sidebars = "transparent",
        floats = "transparent",
      },
      dim_inactive = true,
      lualine_bold = true,
      on_colors = function(colors)
        -- Force true black background
        colors.bg = "#000000"
        colors.bg_dark = "#000000"
        colors.bg_float = "#000000"
        colors.bg_sidebar = "#000000"
        colors.bg_statusline = "#000000"
      end,
      on_highlights = function(hl, c)
        -- Additional transparency for UI elements
        hl.Normal = { fg = c.fg, bg = "NONE" }
        hl.NormalNC = { fg = c.fg, bg = "NONE" }
        hl.NormalFloat = { fg = c.fg, bg = "NONE" }
        hl.FloatBorder = { fg = c.border, bg = "NONE" }
        hl.Pmenu = { fg = c.fg, bg = "NONE" }
        hl.SignColumn = { bg = "NONE" }
        hl.StatusLine = { bg = "NONE" }
        hl.StatusLineNC = { bg = "NONE" }
        hl.TabLine = { bg = "NONE" }
        hl.TabLineFill = { bg = "NONE" }
        hl.WinSeparator = { fg = c.border, bg = "NONE" }
        -- Cursive/italic for more elements
        hl["@function"] = { fg = c.blue, italic = true }
        hl["@function.call"] = { fg = c.blue, italic = true }
        hl["@method"] = { fg = c.blue, italic = true }
        hl["@method.call"] = { fg = c.blue, italic = true }
        hl["@keyword"] = { fg = c.purple, italic = true }
        hl["@keyword.function"] = { fg = c.purple, italic = true }
        hl["@keyword.return"] = { fg = c.purple, italic = true }
        hl["@keyword.conditional"] = { fg = c.purple, italic = true }
        hl["@keyword.repeat"] = { fg = c.purple, italic = true }
        hl["@comment"] = { fg = c.comment, italic = true }
        hl["@parameter"] = { fg = c.orange, italic = true }
        hl["@variable"] = { fg = c.fg, italic = true }
        hl["@variable.builtin"] = { fg = c.red, italic = true }
      end,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")
    end,
  },

  -- Catppuccin Mocha with transparency & cursive
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = true,
      term_colors = true,
      dim_inactive = { enabled = true, shade = "dark", percentage = 0.15 },
      styles = {
        comments = { "italic" },
        conditionals = { "italic" },
        loops = { "italic" },
        functions = { "italic" },
        keywords = { "italic" },
        strings = { "italic" },
        variables = { "italic" },
        numbers = {},
        booleans = { "italic" },
        properties = { "italic" },
        types = { "italic" },
        operators = { "italic" },
      },
      color_overrides = {
        mocha = {
          base = "#000000",
          mantle = "#000000",
          crust = "#000000",
        },
      },
      custom_highlights = function(colors)
        return {
          Normal = { bg = "NONE" },
          NormalNC = { bg = "NONE" },
          NormalFloat = { bg = "NONE" },
          FloatBorder = { fg = colors.surface2, bg = "NONE" },
          Pmenu = { bg = "NONE" },
          SignColumn = { bg = "NONE" },
          StatusLine = { bg = "NONE" },
          StatusLineNC = { bg = "NONE" },
          TabLine = { bg = "NONE" },
          TabLineFill = { bg = "NONE" },
          WinSeparator = { fg = colors.surface2, bg = "NONE" },
        }
      end,
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        telescope = true,
        treesitter = true,
        mason = true,
        native_lsp = {
          enabled = true,
          virtual_text = { errors = { "italic" }, hints = { "italic" }, warnings = { "italic" }, information = { "italic" } },
          underlines = { errors = { "underline" }, hints = { "underline" }, warnings = { "underline" }, information = { "underline" } },
        },
      },
    },
  },

  -- Gruvbox Material (from taihen/nvim-dotfiles) with transparency & italics
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.gruvbox_material_better_performance = 1
      vim.g.gruvbox_material_background = "hard"     -- hard, medium, soft
      vim.g.gruvbox_material_foreground = "original"
      vim.g.gruvbox_material_enable_italic = 1       -- enable italics
      vim.g.gruvbox_material_disable_italic_comment = 0 -- don't disable italic comments
      vim.g.gruvbox_material_enable_bold = 1         -- enable bold
      -- 0 = no transparency, 1 = background and bars, 2 = full transparency
      vim.g.gruvbox_material_transparent_background = 1
      vim.g.gruvbox_material_dim_inactive_windows = 1
      vim.g.gruvbox_material_visual = "grey background"
      vim.g.gruvbox_material_sign_column_background = "none"
      vim.g.gruvbox_material_ui_contrast = "low"
      vim.g.gruvbox_material_show_eob = 1
      vim.g.gruvbox_material_float_style = "bright"
      vim.g.gruvbox_material_diagnostic_text_highlight = 1
      vim.g.gruvbox_material_diagnostic_virtual_text = "gray"
      vim.g.gruvbox_material_disable_terminal_colors = 1
    end,
  },
}