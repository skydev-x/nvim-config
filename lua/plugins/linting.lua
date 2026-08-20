-- Replaces the diagnostics half of none-ls (unmaintained, and it calls APIs
-- that were removed in Neovim 0.12).
return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			svelte = { "eslint_d" },
			python = { "ruff" },
			kotlin = { "ktlint" },
		}

		-- Only run linters whose binary actually exists, otherwise every BufEnter
		-- throws "Error running <linter>: ENOENT".
		local function try_lint()
			local names = lint.linters_by_ft[vim.bo.filetype] or {}
			local runnable = vim.tbl_filter(function(name)
				local linter = lint.linters[name]
				local cmd = type(linter) == "table" and linter.cmd or nil
				if type(cmd) == "function" then
					local ok, resolved = pcall(cmd)
					cmd = ok and resolved or nil
				end
				return vim.fn.executable(cmd or name) == 1
			end, names)
			if #runnable > 0 then
				lint.try_lint(runnable)
			end
		end

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = vim.api.nvim_create_augroup("nvim_lint", { clear = true }),
			callback = try_lint,
		})

		vim.keymap.set("n", "<leader>ll", try_lint, { desc = "Lint current file" })
	end,
}
