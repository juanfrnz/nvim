-- Deps:
--  npm install -g @tailwindcss/language-server
--  npm install -g @astrojs/language-server
--  npm i -g vscode-langservers-extracted
--  npm install -g typescript typescript-language-server
--  brew install ripgrep
-- bindings
-- ctrl-w cycle window
-- yy copy
-- p paste
-- ctrl-r redo
-- u undo
-- K -> hover functions instructions
-- gd -> go to definition
-- gD -> go to implementation
-- C-o -> go back
-- C-i -> go forward

vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set clipboard=unnamedplus")
vim.opt.number = true

vim.api.nvim_set_keymap('i', '<C-a>', '<C-o>^', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-e>', '<C-o>$', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-k>', '<C-o>D', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-a>', '^', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-e>', '$', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<C-a>', '^', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<C-e>', '$', { noremap = true, silent = true })
vim.keymap.set('n', 'grn', vim.lsp.buf.rename)
vim.keymap.set('n', 'gra', vim.lsp.buf.code_action)
vim.keymap.set('n', 'grr', vim.lsp.buf.references)
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation)
vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
vim.keymap.set("n", "gD", function() vim.lsp.buf.declaration() end, opts)
vim.keymap.set("n", "gt", function() vim.lsp.buf.type_definition() end, opts)

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- add your plugins here
    {
      'numToStr/Comment.nvim',
      config = function()
        require('Comment').setup()
      end
    },
    { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  {
      'nvim-telescope/telescope.nvim', tag = '0.1.8',
      dependencies = { 'nvim-lua/plenary.nvim' }
    },
    {"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"},
    {
      'nvim-lualine/lualine.nvim',
      dependencies = { 'nvim-tree/nvim-web-devicons' }
    },
    {
      "neovim/nvim-lspconfig",
      dependencies = {
        {
          "folke/lazydev.nvim",
          ft = "lua", -- only load on lua files
          opts = {
           library = {
             -- See the configuration section for more details
             -- Load luvit types when the `vim.uv` word is found
             { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
          },
        }
      }
    },
    { 'github/copilot.vim' },
    {
      'rmagatti/auto-session',
      config = function()
        require('auto-session').setup()
      end
    },
    {
      'mrcjkb/rustaceanvim',
      version = '^5', -- Recommendedi
      lazy = false, -- This plugin is already lazy
      config = function()
        vim.g.rustfmt_autosave = 1
        vim.g.rustfmt_fail_silently = 1
        vim.g.rustfmt_options = {
          ['allman_style'] = true,
          ['hard_tabs'] = true,
          ['tab_spaces'] = 4,
          ['format_strings'] = true,
          ['format_code_block'] = true,
          ['format_code_block_in_doc_comment'] = true,
          ['format_macros'] = true,
          ['format_match_arm_blocks'] = true,
          ['format_single_line_match_arms'] = true,
          ['format_brace_style'] = 'SameLine',
          ['format_trailing_comma'] = true,
          ['format_struct_lit'] = true,
          ['format_struct_lit_style'] = 'Block',
        }
      end
    },
    {
      "hrsh7th/nvim-cmp",
      dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-nvim-lsp-signature-help",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
      },
      config = function()
        local cmp = require("cmp")
        cmp.setup({
          snippet = {
            expand = function(args)
              require("luasnip").lsp_expand(args.body)
            end,
          },
          mapping = cmp.mapping.preset.insert({
            ["<Tab>"] = cmp.mapping.select_next_item(),
            ["<S-Tab>"] = cmp.mapping.select_prev_item(),
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
          }),
          sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "nvim_lsp_signature_help" },
            { name = "buffer" },
            { name = "path" },
            { name = "luasnip" },
          }),
        })
      end,
    },
    {
      'VonHeikemen/lsp-zero.nvim',
      branch = 'v3.x',
      dependencies = {
        'neovim/nvim-lspconfig'
      },
      config = function()
        local lsp = require("lsp-zero").preset({})
        -- Format on save
        lsp.format_on_save({
          format_opts = {
            async = false,
            timeout_ms = 10000,
          },
          servers = {
            ["rust-analyzer"] = { "rust" },
          }
        })
      end
    }
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

require('lualine').setup({
  options = {
    section_separators = {'', ''},
    component_separators = {'', ''},
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  }
})

require'lspconfig'.lua_ls.setup{}
require'lspconfig'.astro.setup{}
require'lspconfig'.clangd.setup{
  cmd = { "clangd", "--background-index", "--clang-tidy", "--suggest-missing-includes" },
  filetypes = { "c", "cpp", "objc", "objcpp", "h", "hpp" },
  root_dir = require'lspconfig'.util.root_pattern(
    'Makefile',
    'compile_commands.json', -- Common for CMake projects
    'compile_flags.txt',     -- Alternative option
    '.git',                  -- If you want to use Git root as project root
    'CMakeLists.txt'        -- CMake projects
  )
}
local function organize_imports()
  local params = {
    command = "_typescript.organizeImports",
    arguments = {vim.api.nvim_buf_get_name(0)},
    title = ""
  }
  vim.lsp.buf.execute_command(params)
end
require'lspconfig'.ts_ls.setup{
  filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
  root_dir = require'lspconfig'.util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git"),
commands = {
    OrganizeImports = {
      organize_imports,
      description = "Organize Imports"
    }
  },
  on_attach = function(client, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
       vim.lsp.buf.format({ async = false })
      end,
    })
  end,
}
require'lspconfig'.gopls.setup{}
require'lspconfig'.tailwindcss.setup{
  filetypes = { "html", "css", "scss", "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "svelte" },
  classAttributes = { "class", "className", "class:list", "classList", "ngClass" },
  includeLanguages = {
    eelixir = "html-eex",
    eruby = "erb",
    htmlangular = "html",
    templ = "html"
  },
  lint = {
    cssConflict = "warning",
    invalidApply = "error",
    invalidConfigPath = "error",
    invalidScreen = "error",
    invalidTailwindDirective = "error",
    invalidVariant = "error",
    recommendedVariantOrder = "warning"
  },
  validate = true
}
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
require'lspconfig'.html.setup{
  capabilities = capabilities,
}

-- Treesitter
require("nvim-treesitter.configs").setup({
  ensure_installed = { "c", "cpp", "go", "rust", "javascript", "typescript", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline" },
  highlight = { enable = true },
  indent = { enable = true },
})

-- Telescope
local builtin = require("telescope.builtin")
vim.keymap.set('n', 'ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', 'fg', builtin.live_grep, { desc = 'Telescope live grep' }) -- brew install ripgrep
vim.keymap.set('n', 'fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', 'fh', builtin.help_tags, { desc = 'Telescope help tags' })

-- Theme
require("catppuccin").setup({
-- flavour = "latte"
})
vim.cmd.colorscheme "catppuccin"

