-- nvim-treesitter-textobjects `main` branch: no more `nvim-treesitter.configs`,
-- keymaps are declared directly and call the select/move/swap modules.
return {
	"nvim-treesitter/nvim-treesitter-textobjects",
	branch = "main",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	config = function()
		require("nvim-treesitter-textobjects").setup({
			select = {
				lookahead = true,
			},
			move = {
				set_jumps = true,
			},
		})

		local select = require("nvim-treesitter-textobjects.select")
		local move = require("nvim-treesitter-textobjects.move")
		local swap = require("nvim-treesitter-textobjects.swap")
		local repeatable = require("nvim-treesitter-textobjects.repeatable_move")

		local function map_select(lhs, query, desc)
			vim.keymap.set({ "x", "o" }, lhs, function()
				select.select_textobject(query, "textobjects")
			end, { desc = desc })
		end

		-- selection
		map_select("a=", "@assignment.outer", "Outer assignment")
		map_select("i=", "@assignment.inner", "Inner assignment")
		map_select("l=", "@assignment.lhs", "Assignment LHS")
		map_select("r=", "@assignment.rhs", "Assignment RHS")
		map_select("a:", "@property.outer", "Outer property")
		map_select("i:", "@property.inner", "Inner property")
		map_select("aa", "@parameter.outer", "Outer parameter")
		map_select("ia", "@parameter.inner", "Inner parameter")
		map_select("ai", "@conditional.outer", "Outer conditional")
		map_select("ii", "@conditional.inner", "Inner conditional")
		map_select("al", "@loop.outer", "Outer loop")
		map_select("il", "@loop.inner", "Inner loop")
		map_select("af", "@call.outer", "Outer function call")
		map_select("if", "@call.inner", "Inner function call")
		map_select("am", "@function.outer", "Outer function definition")
		map_select("im", "@function.inner", "Inner function definition")
		map_select("ac", "@class.outer", "Outer class")
		map_select("ic", "@class.inner", "Inner class")

		-- swap
		local swaps_next = {
			["<leader>na"] = "@parameter.inner",
			["<leader>n:"] = "@property.outer",
			["<leader>nm"] = "@function.outer",
		}
		local swaps_prev = {
			["<leader>pa"] = "@parameter.inner",
			["<leader>p:"] = "@property.outer",
			["<leader>pm"] = "@function.outer",
		}
		for lhs, query in pairs(swaps_next) do
			vim.keymap.set("n", lhs, function()
				swap.swap_next(query)
			end, { desc = "Swap next " .. query })
		end
		for lhs, query in pairs(swaps_prev) do
			vim.keymap.set("n", lhs, function()
				swap.swap_previous(query)
			end, { desc = "Swap previous " .. query })
		end

		-- movement
		local motions = {
			{ "]f", move.goto_next_start, "@call.outer", "Next function call start" },
			{ "]m", move.goto_next_start, "@function.outer", "Next function def start" },
			{ "]c", move.goto_next_start, "@class.outer", "Next class start" },
			{ "]i", move.goto_next_start, "@conditional.outer", "Next conditional start" },
			{ "]l", move.goto_next_start, "@loop.outer", "Next loop start" },
			{ "]F", move.goto_next_end, "@call.outer", "Next function call end" },
			{ "]M", move.goto_next_end, "@function.outer", "Next function def end" },
			{ "]C", move.goto_next_end, "@class.outer", "Next class end" },
			{ "]I", move.goto_next_end, "@conditional.outer", "Next conditional end" },
			{ "]L", move.goto_next_end, "@loop.outer", "Next loop end" },
			{ "[f", move.goto_previous_start, "@call.outer", "Prev function call start" },
			{ "[m", move.goto_previous_start, "@function.outer", "Prev function def start" },
			{ "[c", move.goto_previous_start, "@class.outer", "Prev class start" },
			{ "[i", move.goto_previous_start, "@conditional.outer", "Prev conditional start" },
			{ "[l", move.goto_previous_start, "@loop.outer", "Prev loop start" },
			{ "[F", move.goto_previous_end, "@call.outer", "Prev function call end" },
			{ "[M", move.goto_previous_end, "@function.outer", "Prev function def end" },
			{ "[C", move.goto_previous_end, "@class.outer", "Prev class end" },
			{ "[I", move.goto_previous_end, "@conditional.outer", "Prev conditional end" },
			{ "[L", move.goto_previous_end, "@loop.outer", "Prev loop end" },
		}
		for _, m in ipairs(motions) do
			local lhs, fn, query, desc = m[1], m[2], m[3], m[4]
			vim.keymap.set({ "n", "x", "o" }, lhs, function()
				fn(query, "textobjects")
			end, { desc = desc })
		end

		vim.keymap.set({ "n", "x", "o" }, "]s", function()
			move.goto_next_start("@local.scope", "locals")
		end, { desc = "Next scope" })
		vim.keymap.set({ "n", "x", "o" }, "]z", function()
			move.goto_next_start("@fold", "folds")
		end, { desc = "Next fold" })

		-- make ; and , repeat the last treesitter move, and f/F/t/T too
		vim.keymap.set({ "n", "x", "o" }, ";", repeatable.repeat_last_move)
		vim.keymap.set({ "n", "x", "o" }, ",", repeatable.repeat_last_move_opposite)
		vim.keymap.set({ "n", "x", "o" }, "f", repeatable.builtin_f_expr, { expr = true })
		vim.keymap.set({ "n", "x", "o" }, "F", repeatable.builtin_F_expr, { expr = true })
		vim.keymap.set({ "n", "x", "o" }, "t", repeatable.builtin_t_expr, { expr = true })
		vim.keymap.set({ "n", "x", "o" }, "T", repeatable.builtin_T_expr, { expr = true })
	end,
}
