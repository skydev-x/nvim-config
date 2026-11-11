return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local harpoon = require("harpoon")

    -- REQUIRED
    harpoon:setup()
    -- REQUIRED
    vim.keymap.set("n", "<leader>hh", function()
      harpoon:list():append()
    end)
    vim.keymap.set("n", "<leader>hm", function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end)

    vim.keymap.set("n", "<leader>hq", function()
      harpoon:list():select(1)
    end)
    vim.keymap.set("n", "<leader>hw", function()
      harpoon:list():select(2)
    end)
    vim.keymap.set("n", "<leader>he", function()
      harpoon:list():select(3)
    end)
    vim.keymap.set("n", "<leader>hr", function()
      harpoon:list():select(4)
    end)

    -- Toggle previous & next buffers stored within Harpoon list
    vim.keymap.set("n", "<leader>hp", function()
      harpoon:list():prev()
    end)
    vim.keymap.set("n", "<leader>hn", function()
      harpoon:list():next()
    end)
  end,
}

