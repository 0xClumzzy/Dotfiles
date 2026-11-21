return {
  -- Auto dark/light mode based on system (from taihen/nvim-dotfiles)
  {
    "f-person/auto-dark-mode.nvim",
    opts = {
      update_interval = 1000,
      set_light_mode = function()
        vim.api.nvim_set_option_value("background", "light", {})
        vim.cmd.colorscheme("tokyonight")
      end,
      set_dark_mode = function()
        vim.api.nvim_set_option_value("background", "dark", {})
        vim.cmd.colorscheme("tokyonight")
      end,
    },
  },
  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle file explorer" },
      { "<leader>E", "<cmd>Neotree focus<cr>", desc = "Focus file explorer" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      close_if_last_window = true,
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      default_component_configs = {
        indent = { indent_size = 2, padding = 1 },
        icon = { folder_closed = "󰉋", folder_open = "󰝰", folder_empty = "󰉖", default = "" },
        modified = { symbol = "[+]" },
        git_status = {
          symbols = {
            added = "✚", modified = "", deleted = "✖", renamed = "󰁕",
            untracked = "", ignored = "◌", unstaged = "", staged = "",
            conflict = "",
          },
        },
      },
      window = {
        position = "left",
        width = 30,
        mappings = {
          ["<space>"] = "toggle_node",
          ["<cr>"] = "open",
          ["S"] = "open_split",
          ["s"] = "open_vsplit",
          ["t"] = "open_tabnew",
          ["C"] = "close_node",
          ["z"] = "close_all_nodes",
          ["R"] = "refresh",
        },
      },
      filesystem = {
        filtered_items = { visible = true, hide_dotfiles = false, hide_gitignored = true },
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
      },
    },
  },

  -- Better quickfix
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    opts = {
      auto_enable = true,
      preview = { win_height = 12, win_vheight = 12, delay_syntax = 80, border_chars = { "┃", "┃", "━", "━", "┏", "┓", "┗", "┛", "█" } },
      func_map = { drop = "o", openc = "O", split = "<C-s>", tabdrop = "<C-t>", tabc = "", ptogglemode = "z," },
      filter = { fzf = { action_for = { ["ctrl-s"] = "split", ["ctrl-t"] = "tabdrop" }, extra_opts = { "--bind", "ctrl-o:toggle-all", "--prompt", "> " } } },
    },
  },

  -- Session management
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = { dir = vim.fn.stdpath("state") .. "/sessions/", options = { "buffers", "curdir", "tabpages", "winsize" } },
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't save session" },
    },
  },

  -- Surround (also in editor.lua but here for reference)
  -- Already defined in editor.lua

  -- Better search/replace
  {
    "nvim-pack/nvim-spectre",
    cmd = "Spectre",
    opts = { open_cmd = "noswapfile vnew", live_update = true },
    keys = {
      { "<leader>sr", function() require("spectre").open() end, desc = "Replace in files (Spectre)" },
      { "<leader>sw", function() require("spectre").open_visual({ select_word = true }) end, desc = "Replace word (Spectre)" },
      { "<leader>sp", function() require("spectre").open_file_search({ select_word = true }) end, desc = "Replace in current file (Spectre)" },
    },
  },

  -- Markdown preview
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown preview" },
    },
  },

  -- REST client
  {
    "mistweaverco/kulala.nvim",
    ft = { "http", "rest" },
    opts = {
      global_keymaps = true,
      global_keymaps_prefix = "<leader>R",
      kulala = {
        ui = { winbar = true, default_view = "body" },
      },
    },
    keys = {
      { "<leader>Rr", "<cmd>lua require('kulala').run()<cr>", desc = "Run request" },
      { "<leader>Ra", "<cmd>lua require('kulala').run_all()<cr>", desc = "Run all requests" },
      { "<leader>Rt", "<cmd>lua require('kulala').toggle_view()<cr>", desc = "Toggle view" },
      { "<leader>Ri", "<cmd>lua require('kulala').inspect()<cr>", desc = "Inspect" },
    },
  },

  -- Database
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_force_echo_notifications = 1
    end,
    keys = {
      { "<leader>du", "<cmd>DBUIToggle<cr>", desc = "Toggle DB UI" },
      { "<leader>df", "<cmd>DBUIFindBuffer<cr>", desc = "Find buffer" },
    },
  },

  -- Test runner
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-neotest/neotest-python",
      "nvim-neotest/neotest-go",
      "nvim-neotest/neotest-jest",
      "rouge8/neotest-rust",
    },
    keys = {
      { "<leader>tt", function() require("neotest").run.run() end, desc = "Run nearest test" },
      { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run file tests" },
      { "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Debug nearest test" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle summary" },
      { "<leader>to", function() require("neotest").output_panel.toggle() end, desc = "Toggle output" },
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-python")({ dap = { justMyCode = false } }),
          require("neotest-go")(),
          require("neotest-jest")(),
          require("neotest-rust")(),
        },
      })
    end,
  },
}