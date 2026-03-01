return {
    "saghen/blink.cmp",
    version = "*",
    opts = {
      keymap = { preset = "default" },
      completion = {
        list  = {
          selection = {
            preselect = true
          }
        },
        menu = {
          border = "rounded"  
        }
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
    },
}
