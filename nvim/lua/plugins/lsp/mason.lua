-- mason.nvim v2 + mason-lspconfig v2.
-- v2 renamed `automatic_installation` -> `automatic_enable`, dropped `setup_handlers`,
-- and `ensure_installed` only accepts *LSP server* names (linters/formatters go to
-- mason-tool-installer below).
return {
	"mason-org/mason.nvim",
	dependencies = {
		"mason-org/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		"neovim/nvim-lspconfig",
	},
	config = function()
		require("mason").setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		require("mason-lspconfig").setup({
			ensure_installed = {
				-- requested languages
				"clangd", -- c / c++
				"gopls", -- go
				"kotlin_language_server", -- kotlin
				"pyright", -- python
				"rust_analyzer", -- rust
				"ts_ls", -- javascript / typescript (was "tsserver")
				-- web / misc
				"cssls",
				"emmet_ls",
				"graphql",
				"html",
				"lua_ls",
				"prismals",
				"svelte",
				"tailwindcss",
				-- NOTE: swift/objective-c use sourcekit-lsp, which ships with Xcode and
				-- is NOT a Mason package. It is enabled in lspconfig.lua instead.
			},
			automatic_enable = true,
		})

		require("mason-tool-installer").setup({
			ensure_installed = {
				"prettier", -- js/ts/css/html/json/yaml/md formatter
				"stylua", -- lua formatter
				"ruff", -- python linter
				"eslint_d", -- js/ts linter
				"gofumpt", -- go formatter
				"goimports", -- go import fixer
				"ktlint", -- kotlin formatter + linter
				"clang-format", -- c / c++ / objective-c formatter
				"shfmt", -- shell formatter
			},
		})
	end,
}
