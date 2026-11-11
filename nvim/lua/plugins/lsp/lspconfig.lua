-- Neovim 0.11+ native LSP API.
-- nvim-lspconfig is kept only for the server *defaults* it ships in its `lsp/` directory
-- (cmd, filetypes, root markers). Configuration is done with vim.lsp.config/vim.lsp.enable;
-- the old `require("lspconfig").<server>.setup{}` framework is deprecated.
return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
	},
	config = function()
		---------------------------------------------------------------------
		-- diagnostics
		---------------------------------------------------------------------
		vim.diagnostic.config({
			virtual_text = true,
			severity_sort = true,
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = " ",
					[vim.diagnostic.severity.WARN] = " ",
					[vim.diagnostic.severity.HINT] = "󰠠 ",
					[vim.diagnostic.severity.INFO] = " ",
				},
			},
			float = { border = "rounded", source = true },
		})

		---------------------------------------------------------------------
		-- keymaps, bound once per attached buffer
		---------------------------------------------------------------------
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
			callback = function(ev)
				local function map(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
				end

				map("n", "gR", "<cmd>Telescope lsp_references<CR>", "Show LSP references")
				map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
				map("n", "gd", "<cmd>Telescope lsp_definitions<CR>", "Show LSP definitions")
				map("n", "gi", "<cmd>Telescope lsp_implementations<CR>", "Show LSP implementations")
				map("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", "Show LSP type definitions")
				map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "See available code actions")
				vim.keymap.set("n", "<leader>rn", function()
					return ":IncRename " .. vim.fn.expand("<cword>")
				end, { buffer = ev.buf, expr = true, silent = false, desc = "Smart rename (live preview)" })
				map("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", "Show buffer diagnostics")
				map("n", "<leader>ld", vim.diagnostic.open_float, "Show line diagnostics")
				map("n", "K", vim.lsp.buf.hover, "Show documentation under cursor")
				map("n", "<leader>rs", "<cmd>LspRestart<CR>", "Restart LSP")

				-- vim.diagnostic.goto_prev/goto_next were removed in 0.12
				map("n", "[d", function()
					vim.diagnostic.jump({ count = -1, float = true })
				end, "Go to previous diagnostic")
				map("n", "]d", function()
					vim.diagnostic.jump({ count = 1, float = true })
				end, "Go to next diagnostic")

				-- inlay hints, where the server supports them
				local client = vim.lsp.get_client_by_id(ev.data.client_id)
				if client and client:supports_method("textDocument/inlayHint") then
					map("n", "<leader>ih", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
					end, "Toggle inlay hints")
				end
			end,
		})

		---------------------------------------------------------------------
		-- shared config: applied to every server
		---------------------------------------------------------------------
		vim.lsp.config("*", {
			capabilities = require("cmp_nvim_lsp").default_capabilities(),
		})

		---------------------------------------------------------------------
		-- per-server overrides (defaults come from nvim-lspconfig's lsp/*.lua)
		---------------------------------------------------------------------
		vim.lsp.config("gopls", {
			settings = {
				gopls = {
					analyses = { unusedparams = true, shadow = true },
					staticcheck = true,
					gofumpt = true,
				},
			},
		})

		-- kotlin-language-server crashes with
		--   "Expected BEGIN_OBJECT but was BEGIN_ARRAY at path $"
		-- when initializationOptions serialises to an empty JSON array, which is what
		-- happens with nvim-lspconfig's default (storagePath = nil outside a Gradle root).
		-- Always hand it a real path.
		local kotlin_storage = vim.fn.stdpath("cache") .. "/kotlin_language_server"
		vim.fn.mkdir(kotlin_storage, "p")
		vim.lsp.config("kotlin_language_server", {
			init_options = { storagePath = kotlin_storage },
			root_markers = {
				"settings.gradle",
				"settings.gradle.kts",
				"build.gradle",
				"build.gradle.kts",
				"pom.xml",
				".git",
			},
		})

		vim.lsp.config("rust_analyzer", {
			settings = {
				["rust-analyzer"] = {
					cargo = { allFeatures = true },
					check = { command = "clippy" },
				},
			},
		})

		vim.lsp.config("clangd", {
			-- sourcekit owns swift/objc; clangd keeps plain C/C++
			filetypes = { "c", "cpp", "cuda" },
			cmd = {
				"clangd",
				"--background-index",
				"--clang-tidy",
				"--header-insertion=iwyu",
				"--completion-style=detailed",
				"--offset-encoding=utf-16",
			},
		})

		vim.lsp.config("sourcekit", {
			-- Swift + Objective-C; C/C++ are left to clangd
			filetypes = { "swift", "objc", "objcpp" },
		})

		vim.lsp.config("pyright", {
			settings = {
				python = {
					analysis = {
						typeCheckingMode = "basic",
						autoSearchPaths = true,
						useLibraryCodeForTypes = true,
					},
				},
			},
		})

		vim.lsp.config("emmet_ls", {
			filetypes = {
				"html",
				"typescriptreact",
				"javascriptreact",
				"css",
				"sass",
				"scss",
				"less",
				"svelte",
			},
		})

		vim.lsp.config("graphql", {
			filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
		})

		vim.lsp.config("lua_ls", {
			settings = {
				Lua = {
					diagnostics = { globals = { "vim" } },
					workspace = {
						library = {
							vim.fn.expand("$VIMRUNTIME/lua"),
							vim.fn.stdpath("config") .. "/lua",
						},
						checkThirdParty = false,
					},
					telemetry = { enable = false },
				},
			},
		})

		-- svelte needs a nudge when a .js/.ts file it depends on changes
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("svelte_ts_reload", { clear = true }),
			callback = function(ev)
				local client = vim.lsp.get_client_by_id(ev.data.client_id)
				if not client or client.name ~= "svelte" then
					return
				end
				vim.api.nvim_create_autocmd("BufWritePost", {
					pattern = { "*.js", "*.ts" },
					callback = function(ctx)
						client:notify("$/onDidChangeTsOrJsFile", { uri = vim.uri_from_fname(ctx.match) })
					end,
				})
			end,
		})

		---------------------------------------------------------------------
		-- enable
		-- mason-lspconfig (automatic_enable) also enables anything installed
		-- through Mason; enabling twice is a no-op.
		---------------------------------------------------------------------
		vim.lsp.enable({
			-- requested languages
			"clangd", -- c, c++
			"gopls", -- go
			"kotlin_language_server", -- kotlin
			"pyright", -- python
			"rust_analyzer", -- rust
			"ts_ls", -- javascript, typescript
			-- web / misc
			"cssls",
			"emmet_ls",
			"graphql",
			"html",
			"lua_ls",
			"prismals",
			"svelte",
			"tailwindcss",
		})
		-- sourcekit-lsp ships with Xcode (macOS) or a Swift toolchain (Linux), not Mason
		if vim.fn.has("mac") == 1 or vim.fn.executable("sourcekit-lsp") == 1 then
			vim.lsp.enable("sourcekit")
		end
	end,
}
