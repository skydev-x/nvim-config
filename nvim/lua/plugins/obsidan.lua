return {
	"epwalsh/obsidian.nvim",
	version = "3.7.5", -- recommended, use latest release instead of latest commit
	lazy = true,
	-- Vault: $OBSIDIAN_VAULT or ~/docx/shared-vault. Plugin is skipped when the folder is absent.
	cond = function()
		return vim.fn.isdirectory(vim.fn.expand(vim.env.OBSIDIAN_VAULT or "~/docx/shared-vault")) == 1
	end,
	event = {
		"BufReadPre " .. vim.fn.expand(vim.env.OBSIDIAN_VAULT or "~/docx/shared-vault") .. "/**.md",
		"BufNewFile " .. vim.fn.expand(vim.env.OBSIDIAN_VAULT or "~/docx/shared-vault") .. "/**.md",
	},
	dependencies = {
		-- Required.
		"nvim-lua/plenary.nvim",

		-- see below for full list of optional dependencies 👇
	},
	opts = {

		workspaces = {
			{
				name = "personal",
				path = vim.env.OBSIDIAN_VAULT or "~/docx/shared-vault",
			},
		},

		templates = {
			subdir = "templates",
			date_format = "%Y-%m-%d-%a",
			time_format = "%H:%M",
			substitutions = {
				yesterday = function()
					return os.date("%Y-%m-%d", os.time() - 86400)
				end,
			},
		},

		-- this is the default configuration
		mappings = {
			-- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
			["gf"] = {
				action = function()
					return require("obsidian").util.gf_passthrough()
				end,
				opts = { noremap = false, expr = true, buffer = true },
			},
			-- Toggle check-boxes.
			["<leader>ch"] = {
				action = function()
					return require("obsidian").util.toggle_checkbox()
				end,
				opts = { buffer = true },
			},
		},
	}, -- Specify how to handle attachments.
}
