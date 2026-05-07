return {
  {
    "rebelot/kanagawa.nvim", -- Можешь использовать любую другую тему
    lazy = false,
    priority = 1000,
    config = function()
      require("kanagawa").setup({
        transparent = true,      -- Включаем прозрачный фон
        terminal_colors = true,  -- ВАЖНО: Берем цвета из Kitty!
      })
      vim.cmd.colorscheme("kanagawa")
    end,
  },
}
