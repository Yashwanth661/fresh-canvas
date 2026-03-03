-- ~/.config/nvim/init.lua
-- Yashwanth's config for nvim
-----------------------------------------------------------
-- Dependencies
-----------------------------------------------------------

-----------------------------------------------------------
-- Bootstrap lazy.nvim
-----------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-----------------------------------------------------------
-- Plugins
-----------------------------------------------------------
require("lazy").setup({
 -- { "folke/tokyonight.nvim", lazy = false, priority = 1000 },
  {
  "Mofiqul/vscode.nvim",
  config = function()
    require("vscode").setup({
      style = "dark",
      transparent = false,
      italic_comments = true,
    })
    require("vscode").load()
  end,
  },
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" }},
---Snacks for image rendering (Dashboard)
{
  "folke/snacks.nvim",
  priority = 1000,
  opts = {
    image = {
      enabled = true,
    },
    dashboard = {
      enabled = true,
      -- your dashboard config here
    sections = {
	    {section = "header"},
{ section = "keys", gap = 1, padding = 1},
{ section = "startup" },
},
  },
},
},
{
  'nvim-orgmode/orgmode',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  event = 'VeryLazy',
  config = function()
    require('orgmode').setup({
      org_agenda_files = '~/org/*.org',
      org_default_notes_file = '~/org/todo.org',
    })
  end,
},
})

-----------------------------------------------------------
-- Basic options
-----------------------------------------------------------
vim.g.mapleader = " "
local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.termguicolors = true

vim.cmd.colorscheme("vscode")

-----------------------------------------------------------
-- Safe plugin setup (guarded)
-----------------------------------------------------------

-- Lualine
local ok_lualine, lualine = pcall(require, "lualine")
if ok_lualine then
  lualine.setup({ options = { theme = "vscode" } })
end

-- Treesitter
local ok_ts, ts_configs = pcall(require, "nvim-treesitter.configs")
if ok_ts then
  ts_configs.setup({
    ensure_installed = { "lua", "vim", "vimdoc" },
    highlight = { enable = true },
    indent    = { enable = true },
  })
end

-- nvim-tree setup
local ok_tree, nvim_tree = pcall(require, "nvim-tree")
if ok_tree then
  nvim_tree.setup({})
end

--------------------------------------------------
-- Keybindings
--------------------------------------------------
-- Keymap: toggle file explorer with <leader>e (space+e if leader is space)
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true })
-- Keymap: Go to Dashboard
vim.keymap.set("n", "<leader>od", function() Snacks.dashboard() end, { desc = "Open Dashboard" })

vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
    ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
  },
  paste = {
    ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
    ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
  },
}
