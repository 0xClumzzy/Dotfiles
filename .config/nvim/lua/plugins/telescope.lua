return {
  -- Telescope (fuzzy finder)
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-ui-select.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
      { "<leader>fc", "<cmd>Telescope commands<cr>", desc = "Commands" },
      { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document symbols" },
      { "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "Workspace symbols" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
      { "<leader>fq", "<cmd>Telescope quickfix<cr>", desc = "Quickfix" },
      { "<leader>fm", "<cmd>Telescope marks<cr>", desc = "Marks" },
      { "<leader>f/", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer fuzzy find" },
      { "<leader>f:", "<cmd>Telescope command_history<cr>", desc = "Command history" },
      { "<leader>f\"", "<cmd>Telescope registers<cr>", desc = "Registers" },
      { "<leader>ft", "<cmd>Telescope treesitter<cr>", desc = "Treesitter" },
      { "<leader>fp", "<cmd>Telescope projects<cr>", desc = "Projects" },
    },
    opts = {
      defaults = {
        prompt_prefix = " ",
        selection_caret = " ",
        path_display = { "truncate" },
        sorting_strategy = "ascending",
        layout_config = {
          horizontal = { prompt_position = "top", preview_width = 0.55 },
          vertical = { mirror = false },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },
        mappings = {
          i = {
            ["<C-n>"] = function() require("telescope.actions").move_selection_next() end,
            ["<C-p>"] = function() require("telescope.actions").move_selection_previous() end,
            ["<C-q>"] = function() require("telescope.actions").send_to_qflist(); require("telescope.actions").open_qflist() end,
            ["<C-x>"] = false,
            ["<C-v>"] = false,
            ["<C-t>"] = function() require("telescope.actions").select_tab() end,
          },
          n = {
            ["q"] = function() require("telescope.actions").close() end,
            ["<C-q>"] = function() require("telescope.actions").send_to_qflist(); require("telescope.actions").open_qflist() end,
          },
        },
      },
      pickers = {
        find_files = { hidden = true, follow = true },
        live_grep = { additional_args = { "--hidden" } },
        buffers = { sort_lastused = true, ignore_current_buffer = true },
      },
      extensions = {
        fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true, case_mode = "smart_case" },
        ["ui-select"] = {}, -- configured in config function
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      -- Configure ui-select extension
      opts.extensions = opts.extensions or {}
      opts.extensions["ui-select"] = { require("telescope.themes").get_dropdown() }
      telescope.setup(opts)
      telescope.load_extension("fzf")
      telescope.load_extension("ui-select")
    end,
  },

  -- Project management
  {
    "ahmedkhalf/project.nvim",
    event = "VeryLazy",
    opts = {
      detection_methods = { "lsp", "pattern" },
      patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" },
      show_hidden = true,
    },
    config = function(_, opts)
      require("project_nvim").setup(opts)
      require("telescope").load_extension("projects")
    end,
  },
}