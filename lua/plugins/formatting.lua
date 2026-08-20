return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		-- Xcode ships swift-format inside the toolchain, not on $PATH.
		conform.formatters.swift_format = {
			command = vim.fn.exepath("swift-format") ~= "" and "swift-format"
				or vim.trim(vim.fn.system({ "xcrun", "--find", "swift-format" })),
		}

		conform.setup({
			formatters_by_ft = {
				-- web
				javascript = { "prettier" },
				javascriptreact = { "prettier" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				svelte = { "prettier" },
				css = { "prettier" },
				scss = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				jsonc = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				graphql = { "prettier" },
				-- languages
				go = { "goimports", "gofumpt" },
				rust = { "rustfmt" },
				kotlin = { "ktlint" },
				python = { "ruff_organize_imports", "ruff_format" },
				c = { "clang_format" },
				cpp = { "clang_format" },
				objc = { "clang_format" },
				objcpp = { "clang_format" },
				swift = { "swift_format" },
				lua = { "stylua" },
				sh = { "shfmt" },
				bash = { "shfmt" },
			},
			-- anything without an entry above falls back to the LSP formatter
			default_format_opts = { lsp_format = "fallback" },
			format_on_save = {
				timeout_ms = 1000,
				lsp_format = "fallback",
			},
		})

		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({ async = false, timeout_ms = 1000, lsp_format = "fallback" })
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
