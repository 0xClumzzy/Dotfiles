--[[
=====================================================================
                           LSP Configuration
=====================================================================
Uses new vim.lsp.config API (neovim 0.11+) with fallback for older versions
--]]

local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Diagnostic signs
local signs = {
  Error = " ",
  Warn = " ",
  Hint = " ",
  Info = " ",
}
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Global diagnostic config
vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
    spacing = 4,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "if_many",
    header = "",
    prefix = "",
  },
})

-- LSP servers to install/configure
local servers = {
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        workspace = {
          checkThirdParty = false,
          library = vim.api.nvim_get_runtime_file("", true),
        },
        diagnostics = { globals = { "vim" } },
        telemetry = { enable = false },
      },
    },
  },
  pyright = {},
  rust_analyzer = {
    settings = {
      ["rust-analyzer"] = {
        cargo = { allFeatures = true },
        checkOnSave = { command = "clippy" },
      },
    },
  },
  gopls = {
    settings = {
      gopls = {
        analyses = { unusedparams = true },
        staticcheck = true,
      },
    },
  },
  -- Use ts_ls instead of deprecated tsserver
  ts_ls = {},
  html = {},
  cssls = {},
  jsonls = {},
  yamlls = {},
  bashls = {},
  dockerls = {},
}

-- Setup each server using new vim.lsp.config API (neovim 0.11+)
-- Falls back to lspconfig for older versions
local function setup_server(server, config)
  config.capabilities = capabilities

  -- Try new API first (neovim 0.11+)
  if vim.lsp.config then
    vim.lsp.config(server, config)
    vim.lsp.enable(server)
  else
    -- Fallback to lspconfig (deprecated but works on older neovim)
    local ok, lspconfig = pcall(require, "lspconfig")
    if ok and lspconfig[server] then
      lspconfig[server].setup(config)
    end
  end
end

for server, config in pairs(servers) do
  setup_server(server, config)
end

-- LSP keymaps
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local opts = { buffer = ev.buf, silent = true }
    local map = vim.keymap.set

    map("n", "gD", vim.lsp.buf.declaration, opts)
    map("n", "gd", vim.lsp.buf.definition, opts)
    map("n", "K", vim.lsp.buf.hover, opts)
    map("n", "gi", vim.lsp.buf.implementation, opts)
    map("n", "<C-k>", vim.lsp.buf.signature_help, opts)
    map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
    map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
    map("n", "<leader>wl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    map("n", "<leader>D", vim.lsp.buf.type_definition, opts)
    map("n", "<leader>rn", vim.lsp.buf.rename, opts)
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
    map("n", "gr", vim.lsp.buf.references, opts)
    map("n", "<leader>f", function()
      vim.lsp.buf.format({ async = true })
    end, opts)
  end,
})

-- Mason integration
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = vim.tbl_keys(servers),
  automatic_installation = true,
})