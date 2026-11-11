return {
	"ThePrimeagen/refactoring.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		-- required since the 2025 rewrite; without it `require("async")` fails
		"lewis6991/async.nvim",
	},
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("refactoring").setup()
	end,
}
