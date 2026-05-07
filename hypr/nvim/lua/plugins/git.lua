return {
  "wsdjeg/git.nvim",
  cmd = { "Git" }, -- ленивая загрузка при первом вызове :Git
  config = function()
    vim.g.git_nvim_keymaps_auto = false -- чтобы не навязывал свои горячие клавиши
  end,
}
