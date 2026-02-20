-- 'gl' for "Go Look" at the diagnostic
vim.keymap.set("n", "gl", vim.diagnostic.open_float)

-- '<leader>ca' for Code Actions (Fixes)
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)

-- To THIS:
vim.keymap.set('n', 'gi', function()
  require('telescope.builtin').lsp_implementations()
end, { desc = '[G]oto [I]mplementation' })

vim.keymap.set('n', 'gr', function()
  require('telescope.builtin').lsp_references()
end, { desc = '[G]oto [R]eferences' })

-- formatting
vim.keymap.set({ "n", "v" }, "<leader>f", function()
	require("conform").format({
		lsp_fallback = true,
		async = false,
		timeout_ms = 500,
	})
end, { desc = "Format file or range (in visual mode)" })
