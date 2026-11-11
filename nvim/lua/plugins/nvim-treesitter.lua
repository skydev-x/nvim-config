-- nvim-treesitter `main` branch (the old `nvim-treesitter.configs` module is gone).
-- Highlighting / indent are now started per-buffer with the core vim.treesitter API.
return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local ts = require("nvim-treesitter")

			ts.setup({})

			local ensure_installed = {
				-- config / markup
				"bash",
				"css",
				"dockerfile",
				"gitignore",
				"graphql",
				"html",
				"json",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"prisma",
				"query",
				"regex",
				"svelte",
				"toml",
				"vim",
				"vimdoc",
				"yaml",
				-- languages asked for
				"c",
				"cpp",
				"objc",
				"go",
				"gomod",
				"gosum",
				"gowork",
				"javascript",
				"jsdoc",
				"tsx",
				"typescript",
				"kotlin",
				"python",
				"rust",
				"swift",
			}

			local installed = ts.get_installed()
			local missing = vim.tbl_filter(function(lang)
				return not vim.tbl_contains(installed, lang)
			end, ensure_installed)
			if #missing > 0 then
				ts.install(missing)
			end

			-- start highlighting + treesitter indent for any buffer with a parser
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
				callback = function(ev)
					local lang = vim.treesitter.language.get_lang(ev.match)
					if not lang or not pcall(vim.treesitter.start, ev.buf, lang) then
						return
					end
					vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
			-- NOTE: `incremental_selection` no longer exists on the main branch.
			-- Node-wise selection is covered by the textobjects keymaps below.
		end,
	},
	{
		"windwp/nvim-ts-autotag",
		event = { "BufReadPre", "BufNewFile" },
		opts = {},
	},
}
