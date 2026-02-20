return {
  {
    "stevearc/conform.nvim",
    opts = {
formatters_by_ft = {
  lua = { "stylua" },
  rust = { "rustfmt" },
  javascript = { "prettierd", "prettier", stop_after_first = true },
  typescript = { "prettierd", "prettier", stop_after_first = true },
    },
      --[[
      conformat_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
      ]]--
    },
  },
}
