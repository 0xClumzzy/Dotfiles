--[[
=====================================================================
                           Autocommands
=====================================================================
--]]

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
  group = "YankHighlight",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- Remove trailing whitespace on save
augroup("TrimWhitespace", { clear = true })
autocmd("BufWritePre", {
  group = "TrimWhitespace",
  pattern = "*",
  command = "%s/\\s\\+$//e",
})

-- Auto-create directories when saving
augroup("AutoCreateDir", { clear = true })
autocmd("BufWritePre", {
  group = "AutoCreateDir",
  pattern = "*",
  callback = function(event)
    if event.match:match("^%w%w+://") then return end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Restore cursor position
augroup("RestoreCursor", { clear = true })
autocmd("BufReadPost", {
  group = "RestoreCursor",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Close certain filetypes with 'q'
augroup("CloseWithQ", { clear = true })
autocmd("FileType", {
  group = "CloseWithQ",
  pattern = { "help", "man", "qf", "lspinfo", "checkhealth", "notify", "tsplayground", "PlenaryTestPopup" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Wrap and check spelling in text files
augroup("TextWrap", { clear = true })
autocmd("FileType", {
  group = "TextWrap",
  pattern = { "gitcommit", "markdown", "text", "plaintex" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Auto-resize splits when window is resized
augroup("AutoResize", { clear = true })
autocmd("VimResized", {
  group = "AutoResize",
  command = "wincmd =",
})

-- Disable auto-comment on new line
augroup("NoAutoComment", { clear = true })
autocmd("BufEnter", {
  group = "NoAutoComment",
  pattern = "*",
  command = "setlocal formatoptions-=c formatoptions-=r formatoptions-=o",
})

-- Terminal settings
augroup("TerminalSettings", { clear = true })
autocmd("TermOpen", {
  group = "TerminalSettings",
  pattern = "*",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
  end,
})

-- Check if file changed outside of nvim
augroup("CheckOutsideChanges", { clear = true })
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = "CheckOutsideChanges",
  command = "checktime",
})

-- LSP progress notification
augroup("LspProgress", { clear = true })
autocmd("User", {
  group = "LspProgress",
  pattern = "LspProgressStatusUpdated",
  callback = function(args)
    vim.notify(args.data.message, vim.log.levels.INFO, { title = "LSP" })
  end,
})