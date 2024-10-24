-- this config followed the guide here: https://elixirforum.com/t/neovim-elixir-setup-configuration-from-scratch-guide/46310

local execute = vim.api.nvim_command
local fn = vim.fn
local fmt = string.format

local pack_path = fn.stdpath("data") .. "/site/pack"

-- ensure a given plugin from github.com/<user>/<repo> is cloned in the pack/packer/start directory
local function ensure (user, repo)
  local install_path = fmt("%s/packer/start/%s", pack_path, repo)
  if fn.empty(fn.glob(install_path)) > 0 then
    execute(fmt("!git clone https://github.com/%s/%s %s", user, repo, install_path))
    execute(fmt("packadd %s", repo))
  end
end

-- ensure the plugin manager is installed
ensure("wbthomason", "packer.nvim")

require('packer').startup(function(use)
  -- install all the plugins you need here

  -- the plugin manager can manage itself
  use {'wbthomason/packer.nvim'}

  -- lsp config for elixir-ls and typescript support
  use {'neovim/nvim-lspconfig'}
  use {'jose-elias-alvarez/nvim-lsp-ts-utils'}

  -- syntax highlighting and more
  use {'elixir-editors/vim-elixir'}

  -- colour scheme
  use {'rebelot/kanagawa.nvim'}

  -- mix format
  use {'mhinz/vim-mix-format'}

  -- fuzzy file search
  use {'junegunn/fzf'}
  use {'junegunn/fzf.vim'}

  -- elm
  use {'elmcast/elm-vim'}

  -- comment helper
  use {'tpope/vim-commentary'}

  -- rust
  use {'rust-lang/rust.vim'}

  -- vim AI
  use {'madox2/vim-ai'}
end)

local status, nvim_lsp = pcall(require, "lspconfig")
if (not status) then return end

local protocol = require('vim.lsp.protocol')

-- `on_attach` callback will be called after a language server
-- instance has been attached to an open buffer with matching filetype
-- here we're setting key mappings for hover documentation, goto definitions, goto references, etc
-- you may set those key mappings based on your own preference
local on_attach = function(client, bufnr)
  -- lsp completion with omnifunc
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  execute('imap <c-k> <c-x><c-o>') -- use <c-k> for omnifunc
  execute('set completeopt-=preview') -- don't show preview when completing

  local opts = { noremap=true, silent=true }

  -- To get LSP working:
  --  mix compile
  --  :LspInfo

  -- gd - go to definition, go back with Ctrl-o
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  -- for the commands below <leader> is \ - and you only have a second to type the rest
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>cr', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>cf', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'ge', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)

  -- -- format on save
  -- if client.server_capabilities.documentFormattingProvider then
  --   vim.api.nvim_create_autocmd("BufWritePre", {
  --     group = vim.api.nvim_create_augroup("Format", { clear = true }),
  --     buffer = bufnr,
  --     callback = function() vim.lsp.buf.formatting_seq_sync() end
  --   })
  -- end
end

-- TypeScript with type checking
nvim_lsp.ts_ls.setup {
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)
    local ts_utils = require("nvim-lsp-ts-utils")
    ts_utils.setup {}
    ts_utils.setup_client(client)
  end,
  filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
  cmd = { "typescript-language-server", "--stdio" }
}

-- setting up the elixir language server
nvim_lsp.elixirls.setup {
  cmd = { "/Users/rob/lib/elixir-ls/language_server.sh" },
  on_attach = on_attach,
  settings = {
    elixirLS = {
      -- I choose to disable dialyzer for personal reasons, but
      -- I would suggest you also disable it unless you are well
      -- aquainted with dialzyer and know how to use it.
      dialyzerEnabled = false,
      -- I also choose to turn off the auto dep fetching feature.
      -- It often get's into a weird state that requires deleting
      -- the .elixir_ls directory and restarting your editor.
      fetchDeps = true
    }
  }
}

-- turn off error window for mix fomat (the LSP warnings will show the issue instead)
vim.g["mix_format_silent_errors"] = 1

-- turn off LSP error column
execute('set signcolumn=no')

-- colour scheme
vim.cmd("colorscheme kanagawa")

-- mix format
vim.g["mix_format_on_save"] = 1

-- Disable continuing comments on a new line
vim.api.nvim_create_autocmd("FileType", { pattern = { "*" }, command = [[set formatoptions-=cro]] })

-- fuzzy file search
vim.env.BASH_ENV = "~/.bash_aliases"
vim.env.FZF_DEFAULT_COMMAND = '(gitls || gitlsdirs | ack "") || ack -g ""'
vim.api.nvim_set_keymap('n', '<C-p>', '<cmd>Files<CR>', {noremap = true}) -- Open file menu

-- go to start of line as well as first line after typing "gg"
execute('set startofline')

-- highlight the screen line of the cursor with CursorLine
execute('set cursorline')

-- show numbers at the start of the line
execute('set number')

-- setup tab as 2 spaces
execute('set expandtab') -- On pressing tab, insert spaces
execute('set softtabstop=2') -- On pressing tab, insert 2 spaces
execute('set shiftwidth=2') -- when indenting with '>', use 2 spaces width

-- set filtetypes based on extension
execute('au BufRead,BufNewFile *.html.*eex set filetype=eelixir')

-- reload the file if it's changed outside of vim
execute('set autoread')

-- when using e sp etc. to open a file, pressing tab to bring up a horizonal menu. see :h wildmode
execute('set wildmode=full:list')
execute('set nowildmenu')

-- include hyphens when selecting (e.g. using *)
execute('set iskeyword+=-')

-- copy all yanks to clipboard (not great as clipboard will get overwritten when you C to change)
-- vim.api.nvim_set_option("clipboard","unnamed")

-- don't use the mouse
vim.opt.mouse = ""
