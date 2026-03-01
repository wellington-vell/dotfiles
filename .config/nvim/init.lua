vim.o.number = true
vim.o.relativenumber = true
vim.o.wrap = false
vim.o.tabstop = 2
vim.o.swapfile = false
vim.o.signcolumn = "yes"
vim.o.winborder = "rounded"

vim.g.mapleader = " "

vim.keymap.set('n', '<leader>w', ':write<CR>')
vim.keymap.set('n', '<leader>q', ':quit<CR>')

vim.pack.add({
        {src="https://github.com/neovim/nvim-lspconfig"},
        {src="https://github.com/echasnovski/mini.pick"},
        {src="https://github.com/folke/snacks.nvim"},
})
require "mini.pick".setup()
vim.keymap.set('n', '<leader>f', ":Pick files<CR>")
vim.keymap.set('n', '<leader>h', ":Pick help<CR>")

vim.lsp.enable('lua_ls')

vim.lsp.config.lua_ls = {
  settings = {
    Lua = {
      runtime = { version = "Lua 5.1" },
      diagnostics = { globals = { "vim" } },
      workspace = { library = vim.api.nvim_get_runtime_file("", true) },
      telemetry = { enable = false },
    },
  },
}
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)

require("snacks").setup({
  lazygit = {
    enabled = true,
  }
})
vim.keymap.set('n', '<leader>gg', function()
  Snacks.lazygit()
end, { desc = "LazyGit" })
