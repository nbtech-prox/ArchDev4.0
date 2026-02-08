-- Neovim Keymaps
local keymap = vim.keymap

vim.g.mapleader = " " -- Space as leader

-- General
keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Project View (Netrw)" })
keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save" })
keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })

-- Better window navigation
keymap.set("n", "<C-h>", "<C-w>h")
keymap.set("n", "<C-j>", "<C-w>j")
keymap.set("n", "<C-k>", "<C-w>k")
keymap.set("n", "<C-l>", "<C-w>l")

-- Clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "No Highlight" })

-- Tabs / Buffer Navigation
keymap.set("n", "<Tab>", ":bnext<CR>", { desc = "Next Tab" })
keymap.set("n", "<S-Tab>", ":bprevious<CR>", { desc = "Prev Tab" })
keymap.set("n", "<leader>x", ":bdelete<CR>", { desc = "Close Tab" })

-- Terminal (Toggleterm)
keymap.set("n", "<leader>t", ":ToggleTerm<CR>", { desc = "Toggle Terminal" })
keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit Terminal Mode" })

-- Lazygit inside Neovim
keymap.set("n", "<leader>g", ":LazyGit<CR>", { desc = "Lazygit" })
