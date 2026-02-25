-- ~/.config/nvim/init.lua
-- Minimal, safe starter with lazy.nvim and a couple of plugins.

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
  { "folke/tokyonight.nvim", lazy = false, priority = 1000 },
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" }},
})

-----------------------------------------------------------
-- Basic options
-----------------------------------------------------------
vim.g.mapleader = " "
local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.termguicolors = true

vim.cmd.colorscheme("tokyonight")

-----------------------------------------------------------
-- Safe plugin setup (guarded)
-----------------------------------------------------------

-- Lualine
local ok_lualine, lualine = pcall(require, "lualine")
if ok_lualine then
  lualine.setup({ options = { theme = "tokyonight" } })
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

-- Keymap: toggle file explorer with <leader>e (space+e if leader is space)
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true })
