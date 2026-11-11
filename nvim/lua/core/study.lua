-- Study system: loads the DSA kit's Neovim integration (keymaps <leader>d*, wikilink
-- navigation in study notes, :Dsa, :DsaBacklinks) when the kit is on disk.
--
-- Kit location: $DSA_HOME, else ~/personal/docx/swe-prep/dsa.
-- Get it with:  install.sh --with-dsa   (clones github.com/skydev-x/DSA-TERMINAL)
local home = vim.env.DSA_HOME or vim.fn.expand("~/personal/docx/swe-prep/dsa")
local entry = home .. "/nvim/dsa.lua"

if vim.fn.filereadable(entry) == 0 then
	return
end

local ok, err = pcall(dofile, entry)
if not ok then
	vim.notify("study: failed to load " .. entry .. "\n" .. tostring(err), vim.log.levels.WARN)
end
