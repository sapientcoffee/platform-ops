-- Suckless NeoVim Config
vim.cmd.colorscheme("habamax")
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.wrap = false
vim.opt.scrolloff = 10
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = "100"
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand("~/.vim/undodir")
vim.opt.updatetime = 300
vim.opt.mouse = "a"
vim.opt.clipboard:append("unnamedplus")
vim.opt.splitbelow = true
vim.opt.splitright = true

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set("n", "<leader>e", ":Explore<CR>", { desc = "Open file explorer" })
vim.keymap.set("n", "<leader>c", ":nohlsearch<CR>", { desc = "Clear search highlights" })
vim.keymap.set("n", "Y", "y$", { desc = "Yank to end of line" })
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<leader>bn", ":bnext<CR>")
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<leader>sv", ":vsplit<CR>")
vim.keymap.set("n", "<leader>sh", ":split<CR>")
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("n", "<leader>tn", ":tabnew<CR>")
vim.keymap.set("n", "<leader>tx", ":tabclose<CR>")

local term_state = { buf = nil, win = nil, is_open = false }
local function FloatingTerminal()
  if term_state.is_open and vim.api.nvim_win_is_valid(term_state.win) then
    vim.api.nvim_win_close(term_state.win, false)
    term_state.is_open = false
    return
  end
  if not term_state.buf or not vim.api.nvim_buf_is_valid(term_state.buf) then
    term_state.buf = vim.api.nvim_create_buf(false, true)
  end
  local w = math.floor(vim.o.columns * 0.8)
  local h = math.floor(vim.o.lines * 0.8)
  term_state.win = vim.api.nvim_open_win(term_state.buf, true, {
    relative = "editor", width = w, height = h,
    row = math.floor((vim.o.lines - h) / 2),
    col = math.floor((vim.o.columns - w) / 2),
    style = "minimal", border = "rounded",
  })
  local lines = vim.api.nvim_buf_get_lines(term_state.buf, 0, -1, false)
  local has_term = false
  for _, l in ipairs(lines) do if l ~= "" then has_term = true break end end
  if not has_term then vim.fn.termopen(os.getenv("SHELL")) end
  term_state.is_open = true
  vim.cmd("startinsert")
end
vim.keymap.set("n", "<leader>t", FloatingTerminal)
vim.keymap.set("t", "<Esc>", function()
  if term_state.is_open then vim.api.nvim_win_close(term_state.win, false) term_state.is_open = false end
end)

vim.api.nvim_create_autocmd("TextYankPost", { callback = function() vim.highlight.on_yank() end })
vim.api.nvim_create_autocmd("FileType", { pattern = {"lua","python"}, callback = function() vim.opt_local.tabstop = 4 vim.opt_local.shiftwidth = 4 end })

local undodir = vim.fn.expand("~/.vim/undodir")
if vim.fn.isdirectory(undodir) == 0 then vim.fn.mkdir(undodir, "p") end
