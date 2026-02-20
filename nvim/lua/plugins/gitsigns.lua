return {
{
    "lewis6991/gitsigns.nvim",
    opts = {
      -- This turns off the gutter signs on startup
      signcolumn = true,
      -- This turns off the "Blame" text on startup
      current_line_blame = false,
      -- We still define the signs so they look good when you DO toggle them
      signs = {
        add = { text = '┃' },
        change = { text = '┃' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
    config = function(_, opts)
      require('gitsigns').setup(opts)
      -- Master Toggle Keymap: One button to turn everything on/off
      vim.keymap.set('n', '<leader>gt', function()
        require('gitsigns').toggle_signs()
        require('gitsigns').toggle_current_line_blame()
      end, { desc = "Toggle Git integration" })
    end
  }
}

