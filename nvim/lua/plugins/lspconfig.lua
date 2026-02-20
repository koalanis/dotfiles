return {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local blink = require("blink.cmp")

      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "ts_ls", "pyright" }, -- Add your servers here
        handlers = {
          function(server_name)
            lspconfig[server_name].setup({
              -- This line is the "magic" that connects blink to your LSPs
              capabilities = blink.get_lsp_capabilities(),
            })
          end,
        ["lua_ls"] = function()
         require("lspconfig").lua_ls.setup({
        capabilities = require("blink.cmp").get_lsp_capabilities(),
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" }, -- This stops the "undefined global vim" error
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
          },
        },
      }) 
          end,
        },
      })
    end,
  }
