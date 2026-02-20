return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    --bigfile = { enabled = true },
    dashboard = { 
      enabled = true,
      formats = {
        key = function(item)
          return { { "[", hl = "special" }, { item.key, hl = "key" }, { "]", hl = "special" } }
        end,
      },
      sections = {
        {section = "terminal", cmd = "pokeget --hide-name mudkip", height = 10, indent = 20},
        {section = "keys", indent = 2, padding = 1},
        {section = "startup"},
      }
    },
    -- explorer = { enabled = true },
    image = {enabled = true},
    -- indent = { enabled = true },
    -- input = { enabled = true },
    -- picker = { enabled = true },
    -- notifier = { enabled = true },
    -- quickfile = { enabled = true },
    -- scope = { enabled = true },
    scroll = { enabled = true },
    -- statuscolumn = { enabled = true },
    -- words = { enabled = true },
    -- zen = { enabled = true },
  },

  keys = {
    { "<leader>z",  function() Snacks.zen() end, desc = "Toggle Zen Mode" },
    { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
  }
}
