return {
	"epwalsh/obsidian.nvim",
	version = "3.7.5", -- recommended, use latest release instead of latest commit
	lazy = true,
	ft = "markdown",
	-- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
	event = {
		-- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
		"BufReadPre "
			.. vim.fn.expand("~")
			.. "docx/ipad-vault/**.md",
		"BufNewFile " .. vim.fn.expand("~") .. "docx/ipad-vault/**.md",
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
				path = "~/docx/ipad-vault/",
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
		-- see below for full list of options 👇
	},
}
