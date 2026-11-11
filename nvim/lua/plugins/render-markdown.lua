-- Renders markdown in the buffer: headings, code blocks, tables, checkboxes, callouts,
-- [[wikilinks]]. The cursor line shows raw text, so editing and link navigation are unchanged.
-- Toggle: <leader>mr
return {
	"MeanderingProgrammer/render-markdown.nvim",
	ft = { "markdown" },
	dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
	opts = {
		completions = { lsp = { enabled = true } },
		heading = { width = "block", left_pad = 1, right_pad = 2 },
		code = { width = "block", left_pad = 2, right_pad = 4, border = "thin" },
		pipe_table = { preset = "round" },
		checkbox = { checked = { scope_highlight = "@markup.strikethrough" } },
		-- Obsidian-style links in the DSA study vault
		link = { wiki = { icon = "󰌹 ", highlight = "RenderMarkdownWikiLink" } },
	},
	keys = {
		{ "<leader>mr", "<cmd>RenderMarkdown toggle<CR>", ft = "markdown", desc = "Markdown: toggle rendering" },
	},
}
