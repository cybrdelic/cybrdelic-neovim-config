vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

-- Function to open or create a notes file
function open_notes()
  local notes_dir = vim.fn.expand '~/notes'
  if vim.fn.isdirectory(notes_dir) == 0 then
    vim.fn.mkdir(notes_dir, 'p')
  end

  vim.ui.select({ 'Search existing notes', 'Create new note' }, {
    prompt = 'Choose an action:',
  }, function(choice)
    if choice == 'Search existing notes' then
      require('telescope.builtin').find_files {
        prompt_title = '< Notes >',
        cwd = notes_dir,
        find_command = { 'rg', '--files', '--hidden', '--glob', '!.git/*' },
        attach_mappings = function(_, map)
          map('i', '<CR>', function(prompt_bufnr)
            local selection = require('telescope.actions.state').get_selected_entry()
            require('telescope.actions').close(prompt_bufnr)
            if selection then
              edit_note(notes_dir .. '/' .. selection.value)
            end
          end)
          return true
        end,
      }
    elseif choice == 'Create new note' then
      create_new_note(notes_dir)
    end
  end)
end

-- Function to edit an existing note
function edit_note(file_path)
  -- Open the file in a new buffer
  vim.cmd('edit ' .. vim.fn.fnameescape(file_path))

  -- Set buffer-local options for Markdown editing
  vim.api.nvim_buf_set_option(0, 'filetype', 'markdown')
  vim.api.nvim_buf_set_option(0, 'textwidth', 80)
  vim.api.nvim_buf_set_option(0, 'wrap', true)
  vim.api.nvim_buf_set_option(0, 'linebreak', true)

  -- Set up Markdown-specific keybindings
  vim.api.nvim_buf_set_keymap(0, 'n', '<leader>mp', ':MarkdownPreviewToggle<CR>', { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(0, 'n', '<leader>mt', 'yypVr=', { noremap = true, desc = 'Create Markdown h1 title' })
  vim.api.nvim_buf_set_keymap(0, 'n', '<leader>ms', 'yypVr-', { noremap = true, desc = 'Create Markdown h2 title' })
  vim.api.nvim_buf_set_keymap(0, 'n', '<leader>mb', 'ciw**<C-r>"**<Esc>', { noremap = true, desc = 'Make word bold' })
  vim.api.nvim_buf_set_keymap(0, 'n', '<leader>mi', 'ciw*<C-r>"*<Esc>', { noremap = true, desc = 'Make word italic' })
  vim.api.nvim_buf_set_keymap(0, 'n', '<leader>nt', ':lua add_tag()<CR>', { noremap = true, desc = 'Add tag to note' })

  -- Set up autocommand to save the file on buffer leave
  vim.api.nvim_create_autocmd('BufLeave', {
    pattern = file_path,
    callback = function()
      if vim.bo.modified then
        vim.cmd 'write'
        print('Note updated: ' .. vim.fn.fnamemodify(file_path, ':t'))
      end
    end,
  })
end

-- Function to create a new note
function create_new_note(notes_dir)
  vim.ui.input({ prompt = 'Enter note name (without extension): ' }, function(input)
    if input then
      local filename = input .. '.md'
      local file_path = notes_dir .. '/' .. filename

      -- Create the file
      vim.fn.writefile({}, file_path)

      -- Open the new file for editing
      edit_note(file_path)

      print('Created new note: ' .. filename)
    end
  end)
end

-- Function to view recent notes
function view_recent_notes(notes_dir)
  require('telescope.builtin').find_files {
    prompt_title = '< Recent Notes >',
    cwd = notes_dir,
    find_command = { 'rg', '--files', '--hidden', '--glob', '!.git/*', '--sort', 'modified' },
    attach_mappings = function(_, map)
      map('i', '<CR>', function(prompt_bufnr)
        local selection = require('telescope.actions.state').get_selected_entry()
        require('telescope.actions').close(prompt_bufnr)
        if selection then
          edit_note(notes_dir .. '/' .. selection.value)
        end
      end)
      return true
    end,
  }
end

-- Function to search notes by tag
function search_notes_by_tag(notes_dir)
  vim.ui.input({ prompt = 'Enter tag to search for: ' }, function(input)
    if input then
      require('telescope.builtin').grep_string {
        prompt_title = '< Notes with tag: ' .. input .. ' >',
        cwd = notes_dir,
        search = '#' .. input,
        attach_mappings = function(_, map)
          map('i', '<CR>', function(prompt_bufnr)
            local selection = require('telescope.actions.state').get_selected_entry()
            require('telescope.actions').close(prompt_bufnr)
            if selection then
              edit_note(selection.filename)
            end
          end)
          return true
        end,
      }
    end
  end)
end

-- Function to add a tag to a note
function add_tag()
  vim.ui.input({ prompt = 'Enter tag (without #): ' }, function(input)
    if input then
      local tag = '#' .. input
      local line = vim.api.nvim_get_current_line()
      local new_line = line .. ' ' .. tag
      vim.api.nvim_set_current_line(new_line)
      print('Added tag: ' .. tag)
    end
  end)
end

-- Function to create a new note
function create_new_note(notes_dir)
  vim.ui.input({ prompt = 'Enter note name (without extension): ' }, function(input)
    if input then
      local filename = input .. '.md'
      local file_path = notes_dir .. '/' .. filename

      -- Create the file
      vim.fn.writefile({}, file_path)

      -- Open the new file for editing
      edit_note(file_path)

      print('Created new note: ' .. filename)
    end
  end)
end

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.colorcolumn = '80'
vim.opt.signcolumn = 'yes'
vim.opt.cmdheight = 0
vim.opt.pumheight = 10
vim.opt.laststatus = 3
vim.opt.showmode = false
vim.opt.showcmd = false
vim.opt.ruler = false
vim.opt.list = true
vim.opt.listchars = { tab = '>> ', trail = '.', nbsp = 'x', extends = '>', precedes = '<' }
vim.opt.fillchars = { eob = ' ' }
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.conceallevel = 2
vim.opt.concealcursor = 'n'

-- Mouse and clipboard
vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'

-- Indentation and tabs
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.smartindent = true
vim.opt.shiftround = true

-- Folding
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldlevelstart = 99

-- Search settings
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.infercase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.inccommand = 'split'

-- Performance settings
vim.opt.lazyredraw = false
vim.opt.synmaxcol = 240

-- Title and status
vim.opt.title = true
vim.opt.titlestring = '%<%F%=%l/%L - nvim'

-- Wildmenu and completion
vim.opt.wildignorecase = true
vim.opt.wildignore:append { '*/node_modules/*', '*/vendor/*', '*.o', '*.obj', '*.dll', '*.exe' }
vim.opt.wildmode = 'longest:full,full'
vim.opt.completeopt = 'menu,menuone,noselect'

-- Backup and swap files
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
-- Undo settings
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath 'data' .. '/undodir'
vim.opt.undolevels = 10000
vim.opt.undoreload = 10000

-- Create undo directory if it doesn't exist
local undodir = vim.fn.stdpath 'data' .. '/undodir'
if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir, 'p')
end

-- Scrolling
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 8
vim.opt.virtualedit = 'block'

-- Spelling
vim.opt.spelllang = { 'en_us' }
vim.opt.whichwrap:append '<,>,[,],h,l'

-- Colors and themes
vim.o.termguicolors = true
vim.o.background = 'dark'
vim.cmd 'syntax enable'
vim.cmd 'syntax on'

-- Neovide settings (if using Neovide)
if vim.g.neovide then
  vim.g.neovide_refresh_rate = 120
  vim.g.neovide_transparency = 0.85
  vim.g.neovide_floating_blur_amount_x = 10.0
  vim.g.neovide_floating_blur_amount_y = 10.0
  vim.g.neovide_remember_window_size = true
  vim.g.neovide_cursor_vfx_mode = 'railgun'
end

-- Install and set up lazy.nvim plugin manager
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  -- Clone lazy.nvim if it's not installed
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- Latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- Plugin setup using lazy.nvim
require('lazy').setup {
  -- File explorer
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons', -- For file icons
      'MunifTanjim/nui.nvim',
    },
    config = function()
      require('neo-tree').setup {
        close_if_last_window = true,
        popup_border_style = 'rounded',
        enable_git_status = true,
        enable_diagnostics = true,
        sort_case_insensitive = true,
        default_component_configs = {
          indent = {
            indent_size = 2,
            padding = 1,
            with_markers = true,
            indent_marker = '│',
            last_indent_marker = '└',
            highlight = 'NeoTreeIndentMarker',
          },
          icon = {
            folder_closed = '',
            folder_open = '',
            folder_empty = '',
            default = '*',
            highlight = 'NeoTreeFileIcon',
          },
          modified = {
            symbol = '[+]',
            highlight = 'NeoTreeModified',
          },
          name = {
            trailing_slash = false,
            use_git_status_colors = true,
            highlight = 'NeoTreeFileName',
          },
          git_status = {
            symbols = {
              added = '',
              modified = '',
              deleted = '✖',
              renamed = '',
              untracked = '',
              ignored = '',
              unstaged = '',
              staged = '',
              conflict = '',
            },
          },
        },
        window = {
          position = 'left',
          width = 40,
          mapping_options = {
            noremap = true,
            nowait = true,
          },
          mappings = {
            ['<space>'] = {
              'toggle_node',
              nowait = false, -- disable 'nowait' if you have existing combos starting with this char that you want to use
            },
            ['<2-LeftMouse>'] = 'open',
            ['<cr>'] = 'open',
            ['S'] = 'open_split',
            ['s'] = 'open_vsplit',
            ['t'] = 'open_tabnew',
            ['w'] = 'open_with_window_picker',
            ['C'] = 'close_node',
            ['a'] = 'add',
            ['A'] = 'add_directory',
            ['d'] = 'delete',
            ['r'] = 'rename',
            ['y'] = 'copy_to_clipboard',
            ['x'] = 'cut_to_clipboard',
            ['p'] = 'paste_from_clipboard',
            ['c'] = 'copy',
            ['m'] = 'move',
            ['q'] = 'close_window',
          },
        },
        filesystem = {
          filtered_items = {
            visible = true, -- This will show hidden files
            hide_dotfiles = false,
            hide_gitignored = false,
          },
          follow_current_file = true,
          use_libuv_file_watcher = true,
        },
        buffers = {
          follow_current_file = true,
          group_empty_dirs = true,
          show_unloaded = true,
        },
        git_status = {
          window = {
            position = 'float',
          },
        },
        event_handlers = {
          {
            event = 'neo_tree_buffer_enter',
            handler = function()
              vim.cmd [[
                if exists('b:neo_tree_source') && b:neo_tree_source == "filesystem"
                  silent! NvimTreeClose
                endif
              ]]
            end,
          },
        },
      }
    end,
  },

  -- Color schemes
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
  },
  {
    'nyoom-engineering/oxocarbon.nvim',
    lazy = false,
    priority = 1000,
  },
  {
    'ellisonleao/gruvbox.nvim',
    lazy = false,
    priority = 1000,
  },
  {
    'shaunsingh/nord.nvim',
    lazy = false,
    priority = 1000,
  },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false,
    priority = 1000,
  },
  {
    'navarasu/onedark.nvim',
    lazy = false,
    priority = 1000,
  },
  {
    'rebelot/kanagawa.nvim',
    lazy = false,
    priority = 1000,
  },
  {
    'EdenEast/nightfox.nvim',
    lazy = false,
    priority = 1000,
  },
  {
    'sainnhe/everforest',
    lazy = false,
    priority = 1000,
  },
  {
    'sainnhe/sonokai',
    lazy = false,
    priority = 1000,
  },
  {
    'folke/lsp-colors.nvim',
    lazy = false,
    priority = 1000,
  },
  {
    'EdenEast/nightfox.nvim',
    lazy = false,
    priority = 1000,
  },
  {
    'sainnhe/everforest',
    lazy = false,
    priority = 1000,
  },
  {
    'sainnhe/sonokai',
    lazy = false,
    priority = 1000,
  },
  {
    'sainnhe/edge',
    lazy = false,
    priority = 1000,
  },
  {
    'projekt0n/github-nvim-theme',
    lazy = false,
    priority = 1000,
  },
  {
    'marko-cerovac/material.nvim',
    lazy = false,
    priority = 1000,
  },
  {
    'Mofiqul/dracula.nvim',
    lazy = false,
    priority = 1000,
  },
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    lazy = false,
    priority = 1000,
  },
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
  },
  {
    'bluz71/vim-moonfly-colors',
    name = 'moonfly',
    lazy = false,
    priority = 1000,
  },
  {
    'bluz71/vim-nightfly-colors',
    name = 'nightfly',
    lazy = false,
    priority = 1000,
  },

  -- Status line
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup {
        options = {
          theme = 'tokyonight',
          component_separators = '|',
          section_separators = { left = '', right = '' },
        },
        sections = {
          lualine_c = {
            {
              'filename',
              file_status = true,
              path = 1,
            },
            {
              function()
                local msg = 'No Active Lsp'
                local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
                local clients = vim.lsp.get_active_clients()
                if next(clients) == nil then
                  return msg
                end
                for _, client in ipairs(clients) do
                  local filetypes = client.config.filetypes
                  if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                    return client.name
                  end
                end
                return msg
              end,
              icon = ' LSP:',
              color = { fg = '#ffffff', gui = 'bold' },
            },
          },
        },
      }
    end,
  },

  -- Telescope FZF native extension
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build',
    dependencies = { 'nvim-telescope/telescope.nvim' },
  },

  -- fzf-lua for fuzzy finding
  {
    'ibhagwan/fzf-lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('fzf-lua').setup {}
    end,
  },

  -- Telescope (fuzzy finder)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'BurntSushi/ripgrep',
    },
  },
  -- nui.nvim for better UI components
  {
    'MunifTanjim/nui.nvim',
    config = function()
      local telescope = require 'telescope'
      telescope.setup {
        defaults = {
          vimgrep_arguments = {
            'rg',
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case',
            '--hidden',
          },
          file_ignore_patterns = { 'node_modules', '.git' },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = 'smart_case',
          },
        },
      }
      pcall(telescope.load_extension, 'fzf')
    end,
  },

  -- LSP configurations
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim', -- LSP installer
      'williamboman/mason-lspconfig.nvim',
      'folke/trouble.nvim',      -- Better diagnostic display
    },
  },

  -- null-ls for formatting and linting
  {
    'jose-elias-alvarez/null-ls.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
  },

  -- Treesitter for syntax highlighting and code parsing
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { 'bash', 'c', 'lua', 'rust', 'python', 'javascript', 'html', 'css', 'json', 'yaml' },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
      }
    end,
  },
  -- Treesitter playground for inspecting syntax trees
  {
    'nvim-treesitter/playground',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },

  -- Hop (Easy motion)
  {
    'phaazon/hop.nvim',
    branch = 'v2', -- optional but strongly recommended
    config = function()
      require('hop').setup()
    end,
  },

  -- Better code folding
  {
    'kevinhwang91/nvim-ufo',
    dependencies = 'kevinhwang91/promise-async',
    config = function()
      require('ufo').setup {
        provider_selector = function(bufnr, filetype, buftype)
          return { 'treesitter', 'indent' }
        end,
      }
    end,
  },

  -- Symbol outline
  {
    'simrat39/symbols-outline.nvim',
    config = function()
      require('symbols-outline').setup()
    end,
  },

  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'L3MON4D3/LuaSnip',             -- Snippet engine
      'saadparwaiz1/cmp_luasnip',     -- Snippet completions
      'hrsh7th/cmp-nvim-lsp',         -- LSP completions
      'rafamadriz/friendly-snippets', -- Predefined snippets
    },
  },

  -- Terminal integration
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    config = function()
      require('toggleterm').setup {
        size = function(term)
          if term.direction == 'horizontal' then
            return 15
          elseif term.direction == 'vertical' then
            return vim.o.columns * 0.4
          else
            return 20
          end
        end,
        open_mapping = [[<C-\>]],
        direction = 'float',
        float_opts = {
          border = 'curved',
          width = math.floor(vim.o.columns * 0.8),
          height = math.floor(vim.o.lines * 0.8),
          winblend = 25,
        },
      }
    end,
  },

  -- Which-key for keybinding hints
  {
    'folke/which-key.nvim',
    config = function()
      require('which-key').setup {}
    end,
  },

  -- Autopairs for automatic closing of brackets and quotes
  {
    'windwp/nvim-autopairs',
    config = function()
      require('nvim-autopairs').setup {}
    end,
  },

  -- Indent guides
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {},
  },

  -- Multi-cursor editing
  {
    'mg979/vim-visual-multi',
    branch = 'master',
  },

  -- Better comment management
  {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup()
    end,
  },

  -- Enhanced command-line completion
  {
    'gelguy/wilder.nvim',
    config = function()
      local wilder = require 'wilder'
      wilder.setup { modes = { ':', '/', '?' } }

      -- Use a more advanced renderer
      wilder.set_option(
        'renderer',
        wilder.popupmenu_renderer(wilder.popupmenu_border_theme {
          border = 'rounded',
          highlights = {
            border = 'Normal',
          },
          highlighter = wilder.basic_highlighter(),
          left = { ' ', wilder.popupmenu_devicons() },
          right = { ' ', wilder.popupmenu_scrollbar() },
        })
      )
    end,
  },

  -- Git signs in the gutter
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup()
    end,
  },

  -- Diffview for git diffs
  {
    'sindrets/diffview.nvim',
    dependencies = 'nvim-lua/plenary.nvim',
    config = function()
      local actions = require 'diffview.actions'

      require('diffview').setup {
        diff_binaries = false,   -- Show diffs for binaries
        enhanced_diff_hl = true, -- Use enhanced highlighting for diffs
        use_icons = true,        -- Requires nvim-web-devicons
        keymaps = {
          view = {
            ['<leader>dq'] = actions.close, -- Close the diffview
          },
          file_panel = {
            ['<leader>dr'] = actions.restore_entry, -- Restore entry in the file panel
          },
          file_history_panel = {
            ['<leader>dr'] = actions.restore_entry, -- Restore entry in the file history panel
          },
        },
      }
    end,
  },

  -- GitHub Copilot integration
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    config = function()
      require('copilot').setup {
        suggestion = { enabled = false },
        panel = { enabled = false },
      }
    end,
  },

  -- Project-wide search and replace
  {
    'nvim-pack/nvim-spectre',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
  },
  {
    'zbirenbaum/copilot-cmp',
    after = { 'copilot.lua' },
    config = function()
      require('copilot_cmp').setup()
    end,
  },

  -- Startup screen
  {
    'goolord/alpha-nvim',
    config = function()
      require('alpha').setup(require('alpha.themes.dashboard').config)
    end,
  },

  -- Markdown preview
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    build = 'cd app && yarn install',
    init = function()
      vim.g.mkdp_filetypes = { 'markdown' }
    end,
    ft = { 'markdown' },
  },

  -- Session management
  {
    'rmagatti/auto-session',
    config = function()
      require('auto-session').setup {
        log_level = 'error',
        auto_session_suppress_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
        auto_session_enable_last_session = false,
        auto_session_root_dir = vim.fn.stdpath 'data' .. '/sessions/',
        auto_session_enabled = true,
        auto_save_enabled = nil,
        auto_restore_enabled = nil,
        auto_session_use_git_branch = nil,
        -- the configs below are lua only
        bypass_session_save_file_types = nil,
      }
    end,
  },

  -- SJ (Search and Jump)
  {
    'woosaaahh/sj.nvim',
    config = function()
      local sj = require 'sj'
      sj.setup {
        prompt_prefix = '/',
        highlights = {
          SjFocusedLabel = { bold = false, italic = false, fg = '#FFFFFF', bg = '#C000C0' },
          SjLabel = { bold = true, italic = false, fg = '#000000', bg = '#5AA5DE' },
          SjLimitReached = { bold = true, italic = false, fg = '#000000', bg = '#DE945A' },
          SjMatches = { bold = false, italic = false, fg = '#DDDDDD', bg = '#005080' },
          SjNoMatches = { bold = false, italic = false, fg = '#DE945A' },
          SjOverlay = { bold = false, italic = false, fg = '#345576' },
        },
        keymaps = {
          send_to_qflist = '<C-q>', --- send search result to the quickfix list
        },
      }
    end,
  },

  -- Themery for theme management
  {
    'zaldih/themery.nvim',
    config = function()
      require('themery').setup {
        themes = {
          {
            name = 'TokyoNight',
            colorscheme = 'tokyonight-night',
          },
          {
            name = 'Oxocarbon',
            colorscheme = 'oxocarbon',
          },
          {
            name = 'Gruvbox',
            colorscheme = 'gruvbox',
          },
          {
            name = 'Nord',
            colorscheme = 'nord',
          },
          {
            name = 'Catppuccin',
            colorscheme = 'catppuccin',
          },
          {
            name = 'OneDark',
            colorscheme = 'onedark',
          },
          {
            name = 'Kanagawa',
            colorscheme = 'kanagawa',
          },
          {
            name = 'Nightfox',
            colorscheme = 'nightfox',
          },
          {
            name = 'Everforest',
            colorscheme = 'everforest',
          },
          {
            name = 'Sonokai',
            colorscheme = 'sonokai',
          },
          {
            name = 'Edge',
            colorscheme = 'edge',
          },
          {
            name = 'Github',
            colorscheme = 'github',
          },
          {
            name = 'Material',
            colorscheme = 'material',
          },
          {
            name = 'Dracula',
            colorscheme = 'dracula',
          },
          {
            name = 'RosePine',
            colorscheme = 'rose-pine',
          },
          {
            name = 'Moonfly',
            colorscheme = 'moonfly',
          },
          {
            name = 'Nightfly',
            'nightfly',
          },
        },
        livePreview = true,
      }
    end,
  },

  -- Transparent background
  {
    'xiyaowong/transparent.nvim',
    lazy = false,
    config = function()
      require('transparent').setup {
        extra_groups = {
          'NormalFloat',
          'NvimTreeNormal',
          'NeoTreeNormal',
        },
        exclude_groups = {},
      }

      -- Clear specific plugin prefixes
      require('transparent').clear_prefix 'BufferLine'
      require('transparent').clear_prefix 'lualine'

      -- Add additional groups if needed
      -- vim.g.transparent_groups = vim.list_extend(
      --   vim.g.transparent_groups or {},
      --   { "YourAdditionalGroup1", "YourAdditionalGroup2" }
      -- )
    end,
  },
  -- Markdown preview
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    build = 'cd app && yarn install',
    init = function()
      vim.g.mkdp_filetypes = { 'markdown' }
    end,
    ft = { 'markdown' },
    config = function()
      -- Keybinding for toggling markdown preview
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'markdown',
        callback = function()
          vim.api.nvim_buf_set_keymap(0, 'n', '<leader>mp', ':MarkdownPreviewToggle<CR>',
            { noremap = true, silent = true })
        end,
      })
    end,
  },

  -- GitHub integration
  {
    'pwntester/octo.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require('octo').setup {
        default_remote = { 'upstream', 'origin' }, -- order to try remotes
        ssh_aliases = {},                          -- SSH aliases. e.g. `ssh_aliases = {["github.com-work"] = "github.com"}`
        reaction_viewer_hint_icon = '',            -- marker for user reactions
        user_icon = ' ',                           -- user icon
        timeline_marker = '',                      -- timeline marker
        timeline_indent = '2',                     -- timeline indentation
        right_bubble_delimiter = '',               -- bubble delimiter
        left_bubble_delimiter = '',                -- bubble delimiter
        github_hostname = '',                      -- GitHub Enterprise host
        snippet_context_lines = 4,                 -- number or lines around commented lines
        file_panel = {
          size = 10,                               -- changed files panel rows
          use_icons = true,                        -- use web-devicons in file panel
        },
        mappings = {
          issue = {
            close_issue = '<space>ic',       -- close issue
            reopen_issue = '<space>io',      -- reopen issue
            list_issues = '<space>il',       -- list open issues on same repo
            reload = '<C-r>',                -- reload issue
            open_in_browser = '<C-b>',       -- open issue in browser
            copy_url = '<C-y>',              -- copy url to system clipboard
            add_assignee = '<space>aa',      -- add assignee
            remove_assignee = '<space>ad',   -- remove assignee
            create_label = '<space>lc',      -- create label
            add_label = '<space>la',         -- add label
            remove_label = '<space>ld',      -- remove label
            goto_issue = '<space>gi',        -- navigate to a local repo issue
            add_comment = '<space>ca',       -- add comment
            delete_comment = '<space>cd',    -- delete comment
            next_comment = ']c',             -- go to next comment
            prev_comment = '[c',             -- go to previous comment
            react_hooray = '<space>rp',      -- add/remove 🎉 reaction
            react_heart = '<space>rh',       -- add/remove ❤️ reaction
            react_eyes = '<space>re',        -- add/remove 👀 reaction
            react_thumbs_up = '<space>r+',   -- add/remove 👍 reaction
            react_thumbs_down = '<space>r-', -- add/remove 👎 reaction
            react_rocket = '<space>rr',      -- add/remove 🚀 reaction
            react_laugh = '<space>rl',       -- add/remove 😄 reaction
            react_confused = '<space>rc',    -- add/remove 😕 reaction
          },
          pull_request = {
            checkout_pr = '<space>po',        -- checkout PR
            merge_pr = '<space>pm',           -- merge PR
            list_commits = '<space>pc',       -- list PR commits
            list_changed_files = '<space>pf', -- list PR changed files
            show_pr_diff = '<space>pd',       -- show PR diff
            add_reviewer = '<space>va',       -- add reviewer
            remove_reviewer = '<space>vd',    -- remove reviewer request
            close_issue = '<space>ic',        -- close PR
            reopen_issue = '<space>io',       -- reopen PR
            list_issues = '<space>il',        -- list open issues on same repo
            reload = '<C-r>',                 -- reload PR
            open_in_browser = '<C-b>',        -- open PR in browser
            copy_url = '<C-y>',               -- copy url to system clipboard
            add_assignee = '<space>aa',       -- add assignee
            remove_assignee = '<space>ad',    -- remove assignee
            create_label = '<space>lc',       -- create label
            add_label = '<space>la',          -- add label
            remove_label = '<space>ld',       -- remove label
            goto_issue = '<space>gi',         -- navigate to a local repo issue
            add_comment = '<space>ca',        -- add comment
            delete_comment = '<space>cd',     -- delete comment
            next_comment = ']c',              -- go to next comment
            prev_comment = '[c',              -- go to previous comment
            react_hooray = '<space>rp',       -- add/remove 🎉 reaction
            react_heart = '<space>rh',        -- add/remove ❤️ reaction
            react_eyes = '<space>re',         -- add/remove 👀 reaction
            react_thumbs_up = '<space>r+',    -- add/remove 👍 reaction
            react_thumbs_down = '<space>r-',  -- add/remove 👎 reaction
            react_rocket = '<space>rr',       -- add/remove 🚀 reaction
            react_laugh = '<space>rl',        -- add/remove 😄 reaction
            react_confused = '<space>rc',     -- add/remove 😕 reaction
          },
          review_thread = {
            goto_issue = '<space>gi',        -- navigate to a local repo issue
            add_comment = '<space>ca',       -- add comment
            add_suggestion = '<space>sa',    -- add suggestion
            delete_comment = '<space>cd',    -- delete comment
            next_comment = ']c',             -- go to next comment
            prev_comment = '[c',             -- go to previous comment
            select_next_entry = ']q',        -- move to previous changed file
            select_prev_entry = '[q',        -- move to next changed file
            close_review_tab = '<C-c>',      -- close review tab
            react_hooray = '<space>rp',      -- add/remove 🎉 reaction
            react_heart = '<space>rh',       -- add/remove ❤️ reaction
            react_eyes = '<space>re',        -- add/remove 👀 reaction
            react_thumbs_up = '<space>r+',   -- add/remove 👍 reaction
            react_thumbs_down = '<space>r-', -- add/remove 👎 reaction
            react_rocket = '<space>rr',      -- add/remove 🚀 reaction
            react_laugh = '<space>rl',       -- add/remove 😄 reaction
            react_confused = '<space>rc',    -- add/remove 😕 reaction
          },
          submit_win = {
            approve_review = '<C-a>',   -- approve review
            comment_review = '<C-m>',   -- comment review
            request_changes = '<C-r>',  -- request changes review
            close_review_tab = '<C-c>', -- close review tab
          },
          review_diff = {
            add_review_comment = '<space>ca',    -- add a new review comment
            add_review_suggestion = '<space>sa', -- add a new review suggestion
            focus_files = '<leader>e',           -- move focus to changed file panel
            toggle_files = '<leader>b',          -- hide/show changed files panel
            next_thread = ']t',                  -- move to next thread
            prev_thread = '[t',                  -- move to previous thread
            select_next_entry = ']q',            -- move to previous changed file
            select_prev_entry = '[q',            -- move to next changed file
            close_review_tab = '<C-c>',          -- close review tab
            toggle_viewed = '<leader><space>',   -- toggle viewer viewed state
          },
          file_panel = {
            next_entry = 'j',                  -- move to next changed file
            prev_entry = 'k',                  -- move to previous changed file
            select_entry = '<cr>',             -- show selected changed file diffs
            refresh_files = 'R',               -- refresh changed files panel
            focus_files = '<leader>e',         -- move focus to changed file panel
            toggle_files = '<leader>b',        -- hide/show changed files panel
            select_next_entry = ']q',          -- move to previous changed file
            select_prev_entry = '[q',          -- move to next changed file
            close_review_tab = '<C-c>',        -- close review tab
            toggle_viewed = '<leader><space>', -- toggle viewer viewed state
          },
        },
      }
    end,
  },

  -- Go development plugins
  {
    'ray-x/go.nvim',
    dependencies = {
      'ray-x/guihua.lua',
      'neovim/nvim-lspconfig',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      require('go').setup()
    end,
    event = { 'CmdlineEnter' },
    ft = { 'go', 'gomod' },
    build = ':lua require("go.install").update_all_sync()',
  },
  {
    'leoluz/nvim-dap-go',
    dependencies = { 'mfussenegger/nvim-dap' },
    config = function()
      require('dap-go').setup()
    end,
  },
  {
    'olexsmir/gopher.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      require('gopher').setup()
    end,
  },
  {
    'fatih/vim-go',
    ft = { 'go' },
    config = function()
      vim.g.go_highlight_functions = 1
      vim.g.go_highlight_methods = 1
      vim.g.go_highlight_structs = 1
      vim.g.go_highlight_operators = 1
      vim.g.go_highlight_build_constraints = 1
      vim.g.go_fmt_command = 'goimports'
    end,
  },

  -- Smart-open for fast file-finding
  {
    'danielfalk/smart-open.nvim',
    branch = '0.2.x',
    config = function()
      require('telescope').load_extension 'smart_open'
    end,
    dependencies = {
      'kkharji/sqlite.lua',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      { 'nvim-telescope/telescope-fzy-native.nvim' },
    },
  },
  -- Git integration
  {
    'tpope/vim-fugitive',
    cmd = { 'Git', 'G' },
    config = function()
      vim.keymap.set('n', '<leader>gs', ':Git<CR>', { desc = 'Git status' })
      vim.keymap.set('n', '<leader>gd', ':Gvdiffsplit<CR>', { desc = 'Git diff' })
    end,
  },
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup {
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map('n', ']c', function()
            if vim.wo.diff then
              return ']c'
            end
            vim.schedule(function()
              gs.next_hunk()
            end)
            return '<Ignore>'
          end, { expr = true })

          map('n', '[c', function()
            if vim.wo.diff then
              return '[c'
            end
            vim.schedule(function()
              gs.prev_hunk()
            end)
            return '<Ignore>'
          end, { expr = true })

          -- Actions
          map('n', '<leader>hs', gs.stage_hunk)
          map('n', '<leader>hr', gs.reset_hunk)
          map('v', '<leader>hs', function()
            gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
          end)
          map('v', '<leader>hr', function()
            gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
          end)
          map('n', '<leader>hS', gs.stage_buffer)
          map('n', '<leader>hu', gs.undo_stage_hunk)
          map('n', '<leader>hR', gs.reset_buffer)
          map('n', '<leader>hp', gs.preview_hunk)
          map('n', '<leader>hb', function()
            gs.blame_line { full = true }
          end)
          map('n', '<leader>tb', gs.toggle_current_line_blame)
          map('n', '<leader>hd', gs.diffthis)
          map('n', '<leader>hD', function()
            gs.diffthis '~'
          end)
          map('n', '<leader>td', gs.toggle_deleted)
        end,
      }
    end,
  },

  -- Undotree for visualizing undo history
  {
    'mbbill/undotree',
    cmd = 'UndotreeToggle',
    config = function()
      vim.g.undotree_SetFocusWhenToggle = 1
    end,
  },

  -- Minimap for code overview
  {
    'wfxr/minimap.vim',
    build = 'cargo install --locked code-minimap',
    cmd = { 'Minimap', 'MinimapClose', 'MinimapToggle', 'MinimapRefresh', 'MinimapUpdateHighlight' },
    config = function()
      vim.g.minimap_width = 10
      vim.g.minimap_auto_start = 1
      vim.g.minimap_auto_start_win_enter = 1

      -- Keybinding for toggling minimap
      vim.api.nvim_set_keymap('n', '<leader>mm', ':MinimapToggle<CR>', { noremap = true, silent = true })
    end,
  },

  -- Debugging
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'nvim-neotest/nvim-nio',
      { 'rcarriga/nvim-dap-ui', dependencies = { 'nvim-neotest/nvim-nio' } },
      'theHamsta/nvim-dap-virtual-text',
      'nvim-telescope/telescope-dap.nvim',
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'

      dap.adapters.python = {
        type = 'executable',
        command = '/usr/bin/python3',
        args = { '-m', 'debugpy.adapter' },
      }
      dap.configurations.python = {
        {
          type = 'python',
          request = 'launch',
          name = 'Launch file',
          program = '${file}',
          pythonPath = function()
            return '/usr/bin/python3'
          end,
        },
      }

      dapui.setup()
      require('nvim-dap-virtual-text').setup()
      require('telescope').load_extension 'dap'

      -- Debugging keymaps
      vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
      vim.keymap.set('n', '<F10>', dap.step_over, { desc = 'Debug: Step Over' })
      vim.keymap.set('n', '<F11>', dap.step_into, { desc = 'Debug: Step Into' })
      vim.keymap.set('n', '<F12>', dap.step_out, { desc = 'Debug: Step Out' })
      vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
      vim.keymap.set('n', '<leader>B', function()
        dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end, { desc = 'Debug: Set Breakpoint' })

      -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
      vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })

      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close
    end,
  },

  -- **Avante.nvim Integration**
  {
    'yetone/avante.nvim',
    lazy = false,
    version = false, -- Always pull the latest changes
    build = 'make',  -- Build command for avante.nvim
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'stevearc/dressing.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'nvim-tree/nvim-web-devicons',
      'zbirenbaum/copilot.lua',
      -- Optional dependencies
      {
        'HakonHarnes/img-clip.nvim',
        event = 'VeryLazy',
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            use_absolute_path = true,
          },
        },
      },
      {
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { 'markdown', 'Avante' },
        },
        ft = { 'markdown', 'Avante' },
      },
    },
    opts = {
      -- Add any avante.nvim specific options here
      provider = 'claude', -- Use Claude AI
      auto_suggestions_provider = 'claude',
      behaviour = {
        auto_suggestions = false,
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = false,
      },
    },
    config = function()
      require('avante').setup {
        -- Add any avante.nvim specific options here
      }
    end,
  },
}

-- Keybindings
local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

-- Which-key setup
local wk = require 'which-key'
wk.setup {
  icons = {
    breadcrumb = '»', -- symbol used in the command line area that shows your active key combo
    separator = '➜', -- symbol used between a key and it's label
    group = '+', -- symbol prepended to a group
  },
  window = {
    border = 'single',   -- none, single, double, shadow
    position = 'bottom', -- bottom, top
  },
}

-- Register which-key groups
wk.register {
  ['<leader>'] = {
    f = { name = ' Find' },
    g = { name = ' Git' },
    l = { name = ' LSP' },
    t = { name = '󰙨 Toggle' },
    x = { name = ' Trouble' },
    a = { name = ' Avante' },
    d = { name = ' Debug' },
    h = { name = ' Git Hunks' },
    m = { name = ' Markdown' },
    n = {
      name = ' Notes',
      o = { open_notes, 'Open Notes Menu' },
      n = {
        function()
          create_new_note(vim.fn.expand '~/notes')
        end,
        'Create New Note',
      },
      r = {
        function()
          view_recent_notes(vim.fn.expand '~/notes')
        end,
        'View Recent Notes',
      },
      s = {
        function()
          search_notes_by_tag(vim.fn.expand '~/notes')
        end,
        'Search Notes by Tag',
      },
      t = { add_tag, 'Add Tag to Note' },
    },
    ['<leader>'] = { name = ' Smart Open' },
    o = { name = ' Octo (GitHub)' },
  },
}

-- Register Octo-specific keybindings
wk.register {
  ['<leader>o'] = {
    name = ' Octo (GitHub)',
    l = { '<cmd>Octo repo list<cr>', 'List Repositories' },
    i = { '<cmd>Octo issue list<cr>', 'List Issues' },
    p = { '<cmd>Octo pr list<cr>', 'List Pull Requests' },
    r = { '<cmd>Octo review start<cr>', 'Start Review' },
    c = { '<cmd>Octo comment add<cr>', 'Add Comment' },
  },
}

-- Register individual keybindings
wk.register {
  ['<leader>th'] = { ':Themery<CR>', 'Open Themery theme selector' },
  ['<leader>ts'] = { 'Toggle color scheme' },
  ['<leader>tc'] = { 'Copy user flows to clipboard' },
  ['<leader>tu'] = { 'Analyze user flows' },
  ['<leader>mp'] = { ':MarkdownPreviewToggle<CR>', 'Toggle Markdown Preview' },
  ['<leader><leader>'] = { 'Smart Open (Telescope)' },
}

-- File explorer keybinding
map('n', '<leader>e', '<cmd>Neotree toggle<CR>', { desc = 'Toggle file explorer' })

-- Trouble setup
require('trouble').setup {
  position = 'bottom',
  height = 10,
  width = 50,
  icons = true,
  mode = 'workspace_diagnostics',
  fold_open = '',
  fold_closed = '',
  group = true,
  padding = true,
  action_keys = {
    close = 'q',
    cancel = '<esc>',
    refresh = 'r',
    jump = { '<cr>', '<tab>' },
    open_split = { '<c-x>' },
    open_vsplit = { '<c-v>' },
    open_tab = { '<c-t>' },
    jump_close = { 'o' },
    toggle_mode = 'm',
    toggle_preview = 'P',
    hover = 'K',
    preview = 'p',
    close_folds = { 'zM', 'zm' },
    open_folds = { 'zR', 'zr' },
    toggle_fold = { 'zA', 'za' },
    previous = 'k',
    next = 'j',
  },
}

-- Keybinding groups
local wk = require 'which-key'

-- General keybindings
wk.register {
  ['<leader>'] = {
    w = { '<cmd>w<CR>', 'Save file' },
    q = { '<cmd>q<CR>', 'Quit' },
    e = { '<cmd>Neotree toggle<CR>', 'Toggle file explorer' },
    ['<Tab>'] = { '<cmd>lua change_focus()<CR>', 'Change focus globally' },
    u = { '<cmd>UndotreeToggle<CR>', 'Toggle Undotree' },
    f = { vim.lsp.buf.format, 'Format code' },
    t = {
      name = '󰙨 Toggle',
      n = {
        function()
          open_notes()
        end,
        'Toggle Notes',
      },
    },
  },
}

-- Find keybindings
wk.register {
  ['<leader>f'] = {
    name = ' Find',
    f = { require('telescope.builtin').find_files, 'Find files' },
    g = { require('telescope.builtin').live_grep, 'Live grep' },
    b = { require('telescope.builtin').buffers, 'Find buffers' },
    h = { require('telescope.builtin').help_tags, 'Help tags' },
    s = { require('telescope.builtin').grep_string, 'Search for word under cursor' },
    c = { require('telescope.builtin').current_buffer_fuzzy_find, 'Fuzzy search in current buffer' },
    p = { require('telescope.builtin').git_files, 'Search Git files' },
    o = { require('telescope.builtin').oldfiles, 'Search recently opened files' },
    a = {
      function()
        require('fzf-lua').grep()
      end,
      'Search with Grep (fzf-lua)',
    },
    r = {
      function()
        require('fzf-lua').live_grep()
      end,
      'Search with Live Grep (fzf-lua)',
    },
    m = { vim.lsp.buf.format, 'Format code' },
    R = {
      function()
        require('spectre').open()
      end,
      'Find and Replace (Spectre)',
    },
  },
}

-- Trouble keybindings
wk.register {
  ['<leader>x'] = {
    name = ' Trouble',
    x = { '<cmd>TroubleToggle<cr>', 'Toggle Trouble' },
    w = { '<cmd>TroubleToggle workspace_diagnostics<cr>', 'Workspace Diagnostics' },
    d = { '<cmd>TroubleToggle document_diagnostics<cr>', 'Document Diagnostics' },
    l = { '<cmd>TroubleToggle loclist<cr>', 'Location List' },
    q = { '<cmd>TroubleToggle quickfix<cr>', 'Quickfix List' },
  },
  g = {
    R = { '<cmd>TroubleToggle lsp_references<cr>', 'Trouble: LSP References' },
  },
}

-- Git keybindings
wk.register {
  ['<leader>g'] = {
    name = ' Git',
    d = {
      name = ' Diffview',
      v = { '<cmd>DiffviewOpen<CR>', 'Open' },
      x = { '<cmd>DiffviewClose<CR>', 'Close' },
      h = { '<cmd>DiffviewFileHistory<CR>', 'File History' },
    },
  },
}

-- LSP keybindings
wk.register {
  ['<leader>l'] = {
    name = ' LSP',
    d = { vim.lsp.buf.definition, 'Go to definition' },
    D = { vim.lsp.buf.declaration, 'Go to declaration' },
    h = { vim.lsp.buf.hover, 'Show hover information' },
    i = { vim.lsp.buf.implementation, 'Go to implementation' },
    r = { vim.lsp.buf.references, 'Find references' },
    s = { vim.lsp.buf.signature_help, 'Show signature help' },
    n = { vim.lsp.buf.rename, 'Rename symbol' },
    a = { vim.lsp.buf.code_action, 'Code action' },
    f = { vim.lsp.buf.formatting, 'Format code' },
    e = { vim.diagnostic.open_float, 'Show line diagnostics' },
    q = { vim.diagnostic.setloclist, 'Set location list' },
  },
  ['[d'] = { vim.diagnostic.goto_prev, 'Previous diagnostic' },
  [']d'] = { vim.diagnostic.goto_next, 'Next diagnostic' },
}

-- Toggle keybindings
wk.register {
  ['<leader>t'] = {
    name = '󰙨 Toggle',
    u = { '<cmd>UndotreeToggle<CR>', 'Undotree' },
    s = { '<cmd>SymbolsOutline<CR>', 'Symbol Outline' },
    m = { '<cmd>MinimapToggle<CR>', 'Minimap' },
  },
}

-- Avante keybindings
wk.register {
  ['<leader>a'] = {
    name = ' Avante',
    a = { '<cmd>AvanteToggle<CR>', 'Toggle Sidebar' },
    r = { '<cmd>AvanteRefresh<CR>', 'Refresh Sidebar' },
    e = { '<cmd>AvanteEdit<CR>', 'Edit Selected Blocks' },
  },
}

-- Conflict resolution keybindings
wk.register {
  c = {
    o = { '<cmd>AvanteConflictChooseOurs<CR>', 'Choose Ours in conflict' },
    t = { '<cmd>AvanteConflictChooseTheirs<CR>', 'Choose Theirs in conflict' },
    a = { '<cmd>AvanteConflictChooseAllTheirs<CR>', 'Choose All Theirs in conflicts' },
    ['0'] = { '<cmd>AvanteConflictChooseNone<CR>', 'Choose None in conflict' },
    b = { '<cmd>AvanteConflictChooseBoth<CR>', 'Choose Both in conflict' },
    c = { '<cmd>AvanteConflictChooseCursor<CR>', 'Choose at Cursor in conflict' },
  },
  [']x'] = { '<cmd>AvanteConflictNext<CR>', 'Go to Next Conflict' },
  ['[x'] = { '<cmd>AvanteConflictPrev<CR>', 'Go to Previous Conflict' },
  [']]'] = { '<cmd>AvanteJumpNext<CR>', 'Jump to Next Codeblock' },
  ['[['] = { '<cmd>AvanteJumpPrev<CR>', 'Jump to Previous Codeblock' },
}

-- Window navigation
wk.register {
  ['<C-h>'] = { '<C-w>h', 'Move to left window' },
  ['<C-j>'] = { '<C-w>j', 'Move to window below' },
  ['<C-k>'] = { '<C-w>k', 'Move to window above' },
  ['<C-l>'] = { '<C-w>l', 'Move to right window' },
}

-- Buffer navigation and management
wk.register {
  ['<leader>b'] = {
    name = ' Buffer',
    n = { ':bnext<CR>', 'Next buffer' },
    p = { ':bprevious<CR>', 'Previous buffer' },
    d = { ':bdelete<CR>', 'Delete buffer' },
    D = { ':bdelete!<CR>', 'Force delete buffer' },
  },
}

-- Direct buffer navigation
for i = 1, 9 do
  wk.register {
    ['<leader>' .. i] = { ':' .. i .. 'b<CR>', 'Go to buffer ' .. i },
  }
end

-- Hop keybindings
-- Commented out until the plugin is properly installed
-- local hop = require 'hop'
-- local directions = require('hop.hint').HintDirection
-- wk.register {
--   f = {
--     function()
--       hop.hint_char1 { direction = directions.AFTER_CURSOR, current_line_only = true }
--     end,
--     'Hop forward to char',
--   },
--   F = {
--     function()
--       hop.hint_char1 { direction = directions.BEFORE_CURSOR, current_line_only = true }
--     end,
--     'Hop backward to char',
--   },
--   t = {
--     function()
--       hop.hint_char1 { direction = directions.AFTER_CURSOR, current_line_only = true }
--     end,
--     'Hop forward to before char',
--   },
--   T = {
--     function()
--       hop.hint_char1 { direction = directions.BEFORE_CURSOR, current_line_only = true }
--     end,
--     'Hop backward to before char',
--   },
--   ['<leader>h'] = {
--     w = { '<cmd>HopWord<cr>', 'Hop to word' },
--   },
-- }

-- Smart search
vim.keymap.set('n', '<C-f>', function()
  local opts = {
    prompt_title = 'Smart Search',
    path_display = { 'smart' },
    word_match = '-w',
    only_sort_text = true,
    search = '',
  }

  if vim.fn.expand '%:p' ~= '' then
    opts.cwd = vim.fn.expand '%:p:h'
  end

  require('telescope.builtin').grep_string(opts)
end, { desc = 'Smart search (Ctrl+F)' })

-- Markdown preview toggle (only in markdown files)
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  callback = function()
    vim.keymap.set('n', '<leader>mp', ':MarkdownPreviewToggle<CR>', { buffer = true, desc = 'Toggle Markdown Preview' })
  end,
})

-- Global focus change function
function _G.change_focus()
  if vim.fn.winnr '$' > 1 then
    vim.cmd 'wincmd w'
  elseif vim.fn.tabpagenr '$' > 1 then
    vim.cmd 'tabnext'
  else
    vim.cmd 'bnext'
  end
end

-- Custom autocommands
local augroup = vim.api.nvim_create_augroup('CustomAutocommands', { clear = true })

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  group = augroup,
  callback = function()
    vim.highlight.on_yank { higroup = 'IncSearch', timeout = 150 }
  end,
})

-- LSP and Mason setup
require('mason').setup()
require('mason-lspconfig').setup()

local lspconfig = require 'lspconfig'
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Enhanced on_attach function for LSP
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...)
    vim.api.nvim_buf_set_keymap(bufnr, ...)
  end
  local opts = { noremap = true, silent = true }

  -- LSP keybindings
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

  -- Set some keybinds conditional on server capabilities
  if client.server_capabilities.documentFormattingProvider then
    buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
  end

  -- Set autocommands conditional on server_capabilities
  if client.server_capabilities.documentHighlightProvider then
    vim.api.nvim_exec(
      [[
      hi LspReferenceRead cterm=bold ctermbg=red guibg=LightYellow
      hi LspReferenceText cterm=bold ctermbg=red guibg=LightYellow
      hi LspReferenceWrite cterm=bold ctermbg=red guibg=LightYellow
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]],
      false
    )
  end
end

-- Lua LSP
lspconfig.lua_ls.setup {
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    Lua = {
      format = {
        enable = true,
      },
      diagnostics = {
        globals = { 'vim' },
      },
    },
  },
}

-- Rust Analyzer
lspconfig.rust_analyzer.setup {
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    ['rust-analyzer'] = {
      cargo = {
        allFeatures = true,
      },
      checkOnSave = {
        command = 'clippy',
      },
    },
  },
}

-- Pyright (Python LSP)
lspconfig.pyright.setup {
  capabilities = capabilities,
  on_attach = on_attach,
  cmd = { 'pyright-langserver', '--stdio' },
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = 'workspace',
      },
    },
  },
}

-- Configure LSP hover and signature help
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = 'rounded',
})

vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = 'rounded',
})

-- Diagnostic configuration
vim.diagnostic.config {
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = false,
}

-- Add icons to the sign column
local signs = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' }
for type, icon in pairs(signs) do
  local hl = 'DiagnosticSign' .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- null-ls setup for formatting and linting
local null_ls = require 'null-ls'
null_ls.setup {
  sources = {
    -- Formatting sources
    null_ls.builtins.formatting.prettier, -- For JavaScript, TypeScript, HTML, CSS, etc.
    null_ls.builtins.formatting.stylua,   -- For Lua
    null_ls.builtins.formatting.black,    -- For Python

    -- Diagnostics (Linting) sources
    null_ls.builtins.diagnostics.eslint_d, -- For JavaScript, TypeScript
    null_ls.builtins.diagnostics.flake8,   -- For Python
  },
}

-- nvim-cmp setup
local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm { select = true },
    -- Adjusted <Tab> mapping
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = cmp.config.sources({
    { name = 'copilot', group_index = 2 },
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
  }),
}

-- Integration with nvim-autopairs
local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())

-- Function to set transparency
local function set_transparency()
  local groups = {
    'Normal',
    'NormalFloat',
    'NormalNC',
    'SignColumn',
    'EndOfBuffer',
    'LineNr',
    'CursorLineNr',
    'VertSplit',
    'Folded',
    'NonText',
    'SpecialKey',
    'Pmenu',
    'PmenuSbar',
    'PmenuThumb',
  }
  for _, group in ipairs(groups) do
    vim.api.nvim_set_hl(0, group, { bg = 'NONE', ctermbg = 'NONE' })
  end

  -- Additional transparency settings
  vim.opt.pumblend = 10
  vim.opt.winblend = 10

  -- Force transparency for specific colorschemes that might override it
  vim.cmd [[
    hi Normal guibg=NONE ctermbg=NONE
    hi NormalNC guibg=NONE ctermbg=NONE
    hi EndOfBuffer guibg=NONE ctermbg=NONE
    hi SignColumn guibg=NONE ctermbg=NONE
  ]]
end

-- ColorScheme adjustments for transparency
vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = '*',
  callback = function()
    vim.schedule(function()
      set_transparency()
    end)
  end,
})

-- Set transparency immediately
set_transparency()

-- Autoformat on save
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*',
  callback = function()
    vim.lsp.buf.format()
  end,
})

-- **Load ANTHROPIC_API_KEY from ~/.zshrc**
local function load_anthropic_api_key()
  local zshrc = os.getenv 'HOME' .. '/.zshrc'
  local file = io.open(zshrc, 'r')
  if file then
    for line in file:lines() do
      local key = line:match '^%s*export%s+ANTHROPIC_API_KEY%s*=%s*"(.-)"%s*$'
      if not key then
        key = line:match "^%s*export%s+ANTHROPIC_API_KEY%s*=%s*'(.-)'%s*$"
      end
      if not key then
        key = line:match '^%s*export%s+ANTHROPIC_API_KEY%s*=%s*(%S+)%s*$'
      end
      if key then
        vim.env.ANTHROPIC_API_KEY = key
        break
      end
    end
    file:close()
  end
end
load_anthropic_api_key()

-- **Load avante_lib**
require('avante_lib').load()

-- Theme switcher function
local themes = {
  'tokyonight-night',
  'oxocarbon',
  'gruvbox',
  'nord',
  'catppuccin',
  'onedark',
  'kanagawa',
  'nightfox',
  'everforest',
  'sonokai',
  'edge',
  'github_dark',
  'material',
  'dracula',
  'rose-pine',
  'tokyonight-storm',
  'moonfly',
  'nightfly',
}
local current_theme_index = 1

local function toggle_theme()
  current_theme_index = (current_theme_index % #themes) + 1
  local new_theme = themes[current_theme_index]
  vim.cmd.colorscheme(new_theme)
  vim.o.background = 'dark'

  if new_theme == 'tokyonight-night' then
    require('tokyonight').setup {
      style = 'night',
      transparent = true,
      styles = {
        sidebars = 'transparent',
        floats = 'transparent',
      },
    }
  elseif new_theme == 'oxocarbon' then
    -- Oxocarbon doesn't have a setup function, so we just set the colorscheme
  elseif new_theme == 'gruvbox' then
    require('gruvbox').setup {
      transparent_mode = true,
    }
  elseif new_theme == 'nord' then
    -- Nord doesn't have a setup function, so we just set the colorscheme
  elseif new_theme == 'catppuccin' then
    require('catppuccin').setup {
      transparent_background = true,
    }
  elseif new_theme == 'onedark' then
    require('onedark').setup {
      style = 'dark',
      transparent = true,
    }
  elseif new_theme == 'kanagawa' then
    require('kanagawa').setup {
      transparent = true,
    }
  elseif new_theme == 'nightfox' then
    require('nightfox').setup {
      transparent = true,
    }
  elseif new_theme == 'everforest' then
    vim.g.everforest_transparent_background = 1
  elseif new_theme == 'sonokai' then
    vim.g.sonokai_transparent_background = 1
  elseif new_theme == 'edge' then
    vim.g.edge_transparent_background = 1
  elseif new_theme == 'github_dark' then
    require('github-theme').setup {
      transparent = true,
    }
  elseif new_theme == 'material' then
    require('material').setup {
      contrast = {
        terminal = false,
        sidebars = false,
        floating_windows = false,
        cursor_line = false,
        non_current_windows = false,
        filetypes = {},
      },
    }
    vim.g.material_style = 'deep ocean'
  elseif new_theme == 'dracula' then
    require('dracula').setup {
      transparent_bg = true,
    }
  elseif new_theme == 'rose-pine' then
    require('rose-pine').setup {
      disable_background = true,
    }
  elseif new_theme == 'tokyonight-storm' then
    require('tokyonight').setup {
      style = 'storm',
      transparent = true,
    }
  elseif new_theme == 'moonfly' then
    vim.g.moonflyCursorColor = true
    vim.g.moonflyTransparent = true
  elseif new_theme == 'nightfly' then
    vim.g.nightflyCursorColor = true
    vim.g.nightflyTransparent = true
  end

  print('Switched to ' .. new_theme .. ' theme')
end

-- Keybinding for theme switching
vim.keymap.set('n', '<leader>ts', toggle_theme, { desc = 'Toggle color scheme' })

-- Keybinding for opening Themery
vim.keymap.set('n', '<leader>th', ':Themery<CR>', { desc = 'Open Themery theme selector' })

-- Keybinding for smart-open
vim.keymap.set('n', '<leader><leader>', function()
  require('telescope').extensions.smart_open.smart_open()
end, { noremap = true, silent = true, desc = 'Smart Open (Telescope)' })

-- Keybinding for toggling transparency
vim.keymap.set('n', '<leader>tt', ':TransparentToggle<CR>',
  { noremap = true, silent = true, desc = 'Toggle transparency' })

-- Set initial colorscheme
vim.cmd.colorscheme 'tokyonight-night'
require('tokyonight').setup {
  style = 'night',
  transparent = true,
  styles = {
    sidebars = 'transparent',
    floats = 'transparent',
  },
  on_colors = function(colors)
    colors.bg = 'NONE'
    colors.bg_dark = 'NONE'
    colors.bg_float = 'NONE'
    colors.bg_highlight = 'NONE'
    colors.bg_popup = 'NONE'
    colors.bg_sidebar = 'NONE'
    colors.bg_statusline = 'NONE'
  end,
}
-- Ensure transparency is set after colorscheme
vim.schedule(function()
  set_transparency()
end)
local function trace_causal_chain()
  local ts_utils = require 'nvim-treesitter.ts_utils'
  local node = ts_utils.get_node_at_cursor()
  if not node then
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)

  local function get_node_text(n)
    return vim.treesitter.get_node_text(n, bufnr)
  end

  local variable_dependencies = {}
  local function_calls = {}
  local causal_chain = {}

  local function add_to_chain(item)
    table.insert(causal_chain, item)
  end

  local function trace_variable(var_name, node)
    if not variable_dependencies[var_name] then
      variable_dependencies[var_name] = {}
    end
    local deps = variable_dependencies[var_name]
    local parent = node:parent()
    if parent and parent:type() == 'assignment_expression' then
      local rhs = parent:child(2)
      deps[#deps + 1] = {
        type = 'assignment',
        node = rhs,
        text = get_node_text(rhs),
      }
    elseif parent and parent:type() == 'variable_declaration' then
      local init = parent:field('declarator')[1]:field('value')[1]
      if init then
        deps[#deps + 1] = {
          type = 'declaration',
          node = init,
          text = get_node_text(init),
        }
      end
    end
  end

  local function trace_function_call(func_name, node)
    if not function_calls[func_name] then
      function_calls[func_name] = {}
    end
    local calls = function_calls[func_name]
    calls[#calls + 1] = {
      node = node,
      arguments = {},
    }
    for arg in node:iter_children() do
      if arg:type() == 'argument_list' then
        for arg_expr in arg:iter_children() do
          if arg_expr:type() ~= ',' then
            table.insert(calls[#calls].arguments, {
              node = arg_expr,
              text = get_node_text(arg_expr),
            })
          end
        end
        break
      end
    end
  end

  local function analyze_node(node, depth)
    local node_type = node:type()
    local item = {
      type = node_type,
      text = get_node_text(node),
      depth = depth,
      start = { node:start() },
      end_ = { node:end_() },
    }

    if node_type == 'identifier' then
      trace_variable(item.text, node)
    elseif node_type == 'call_expression' then
      local func_name = get_node_text(node:child(0))
      trace_function_call(func_name, node)
      item.func_name = func_name
    elseif node_type == 'function_definition' then
      item.func_name = get_node_text(node:field('name')[1])
    elseif node_type == 'if_statement' or node_type == 'for_statement' or node_type == 'while_statement' then
      item.condition = get_node_text(node:field('condition')[1])
    elseif node_type == 'return_statement' then
      item.return_value = get_node_text(node:child(1))
    end

    add_to_chain(item)

    for child in node:iter_children() do
      analyze_node(child, depth + 1)
    end
  end

  analyze_node(node, 0)

  local function resolve_dependencies()
    for var, deps in pairs(variable_dependencies) do
      for _, dep in ipairs(deps) do
        local resolved = {}
        for _, item in ipairs(causal_chain) do
          if item.start[1] == dep.node:start() and item.end_[1] == dep.node:end_() then
            table.insert(resolved, item)
          end
        end
        dep.resolved = resolved
      end
    end

    for func, calls in pairs(function_calls) do
      for _, call in ipairs(calls) do
        for _, arg in ipairs(call.arguments) do
          local resolved = {}
          for _, item in ipairs(causal_chain) do
            if item.start[1] == arg.node:start() and item.end_[1] == arg.node:end_() then
              table.insert(resolved, item)
            end
          end
          arg.resolved = resolved
        end
      end
    end
  end

  resolve_dependencies()

  local function display_chain()
    local lines = {}
    local function add_line(text, level)
      table.insert(lines, { text = string.rep('  ', level) .. text, level = level })
    end

    for i, item in ipairs(causal_chain) do
      local line = string.format('%d. %s: %s', i, item.type, item.text)
      add_line(line, item.depth)

      if item.type == 'identifier' then
        local deps = variable_dependencies[item.text]
        if deps and #deps > 0 then
          add_line('Dependencies:', item.depth + 1)
          for _, dep in ipairs(deps) do
            add_line(string.format('%s: %s', dep.type, dep.text), item.depth + 2)
          end
        end
      elseif item.type == 'call_expression' then
        local calls = function_calls[item.func_name]
        if calls and #calls > 0 then
          add_line('Arguments:', item.depth + 1)
          for _, arg in ipairs(calls[#calls].arguments) do
            add_line(arg.text, item.depth + 2)
          end
        end
      end
    end

    local function show_details(index)
      local item = causal_chain[index]
      local details =
          string.format('File: %s\nLine: %d\nColumn: %d\nType: %s\nText: %s\n', filename, item.start[1] + 1,
            item.start[2] + 1, item.type, item.text)

      if item.type == 'identifier' then
        local deps = variable_dependencies[item.text]
        if deps and #deps > 0 then
          details = details .. 'Dependencies:\n'
          for _, dep in ipairs(deps) do
            details = details .. string.format('  %s: %s\n', dep.type, dep.text)
          end
        end
      elseif item.type == 'call_expression' then
        local calls = function_calls[item.func_name]
        if calls and #calls > 0 then
          details = details .. 'Arguments:\n'
          for _, arg in ipairs(calls[#calls].arguments) do
            details = details .. string.format('  %s\n', arg.text)
          end
        end
      end

      vim.api.nvim_echo({ { details, 'Normal' } }, false, {})
    end

    vim.ui.select(lines, {
      prompt = 'Causal Chain (Select an item for details):',
      format_item = function(item)
        return item.text
      end,
    }, function(choice, idx)
      if choice then
        local index = tonumber(choice.text:match '^(%d+)%.')
        if index then
          local item = causal_chain[index]
          vim.api.nvim_win_set_cursor(0, { item.start[1] + 1, item.start[2] })
          show_details(index)
        end
      end
    end)
  end

  display_chain()
end

-- Keybinding for tracing causal chain
vim.keymap.set('n', '<leader>tc', trace_causal_chain, { desc = 'Trace causal chain' })

-- Helper function to trace causal chain for a specific node
local function trace_causal_chain_for_node(node)
  if not node then
    print 'Error: Received nil node in trace_causal_chain_for_node'
    return {}
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)

  local function get_node_text(n)
    if not n then
      return ''
    end
    local ok, text = pcall(vim.treesitter.get_node_text, n, bufnr)
    if not ok then
      print('Error getting node text: ' .. text)
      return ''
    end
    return text
  end

  local variable_dependencies = {}
  local function_calls = {}
  local causal_chain = {}

  local function add_to_chain(item)
    table.insert(causal_chain, item)
  end

  local function trace_variable(var_name, node)
    if not variable_dependencies[var_name] then
      variable_dependencies[var_name] = {}
    end
    local deps = variable_dependencies[var_name]
    local parent = node:parent()
    if parent and parent:type() == 'assignment_expression' then
      local rhs = parent:child(2)
      if rhs then
        deps[#deps + 1] = {
          type = 'assignment',
          node = rhs,
          text = get_node_text(rhs),
        }
      end
    elseif parent and parent:type() == 'variable_declaration' then
      local declarator = parent:field('declarator')[1]
      if declarator then
        local init = declarator:field('value')[1]
        if init then
          deps[#deps + 1] = {
            type = 'declaration',
            node = init,
            text = get_node_text(init),
          }
        end
      end
    end
  end

  local function trace_function_call(func_name, node)
    if not function_calls[func_name] then
      function_calls[func_name] = {}
    end
    local calls = function_calls[func_name]
    calls[#calls + 1] = {
      node = node,
      arguments = {},
    }
    for arg in node:iter_children() do
      if arg:type() == 'argument_list' then
        for arg_expr in arg:iter_children() do
          if arg_expr:type() ~= ',' then
            table.insert(calls[#calls].arguments, {
              node = arg_expr,
              text = get_node_text(arg_expr),
            })
          end
        end
        break
      end
    end
  end

  local function analyze_node(node, depth)
    if not node then
      return
    end

    local ok, result = pcall(function()
      local node_type = node:type()
      local item = {
        type = node_type,
        text = get_node_text(node),
        depth = depth,
        start = { node:start() },
        end_ = { node:end_() },
      }

      if node_type == 'identifier' then
        trace_variable(item.text, node)
      elseif node_type == 'call_expression' then
        local func_node = node:child(0)
        if func_node then
          local func_name = get_node_text(func_node)
          trace_function_call(func_name, node)
          item.func_name = func_name
        end
      elseif node_type == 'function_definition' then
        local name_field = node:field 'name'
        if name_field and name_field[1] then
          item.func_name = get_node_text(name_field[1])
        end
      elseif node_type == 'if_statement' or node_type == 'for_statement' or node_type == 'while_statement' then
        local condition_field = node:field 'condition'
        if condition_field and condition_field[1] then
          item.condition = get_node_text(condition_field[1])
        end
      elseif node_type == 'return_statement' then
        local return_value = node:child(1)
        if return_value then
          item.return_value = get_node_text(return_value)
        end
      end

      add_to_chain(item)

      for child in node:iter_children() do
        analyze_node(child, depth + 1)
      end
    end)

    if not ok then
      print('Error analyzing node: ' .. result)
    end
  end

  analyze_node(node, 0)

  local function resolve_dependencies()
    for var, deps in pairs(variable_dependencies) do
      for _, dep in ipairs(deps) do
        local resolved = {}
        for _, item in ipairs(causal_chain) do
          if item.start[1] == dep.node:start() and item.end_[1] == dep.node:end_() then
            table.insert(resolved, item)
          end
        end
        dep.resolved = resolved
      end
    end

    for func, calls in pairs(function_calls) do
      for _, call in ipairs(calls) do
        for _, arg in ipairs(call.arguments) do
          local resolved = {}
          for _, item in ipairs(causal_chain) do
            if item.start[1] == arg.node:start() and item.end_[1] == arg.node:end_() then
              table.insert(resolved, item)
            end
          end
          arg.resolved = resolved
        end
      end
    end
  end

  resolve_dependencies()

  return causal_chain
end

local parsers = require 'nvim-treesitter.parsers'
local bufnr = vim.api.nvim_get_current_buf()
local root = parsers.get_parser(bufnr):parse()[1]:root()

local all_chains = {}
local user_flows = {}

local function analyze_node(node)
  local start_row, _, end_row, _ = node:range()
  local chain = trace_causal_chain_for_node(node)
  if #chain > 0 then
    table.insert(all_chains, {
      range = { start_row + 1, end_row + 1 },
      chain = chain,
    })
  end

  for child in node:iter_children() do
    analyze_node(child)
  end
end

analyze_node(root)

-- Identify user flows from causal chains
for _, chain in ipairs(all_chains) do
  local flow = {
    entry_point = nil,
    user_interactions = {},
    data_flow = {},
    exit_points = {},
  }

  for _, item in ipairs(chain.chain) do
    if item.type == 'function_definition' and (item.text:match 'handle' or item.text:match 'route') then
      flow.entry_point = item.text
    elseif item.type == 'call_expression' and (item.text:match 'input' or item.text:match 'get' or item.text:match 'post') then
      table.insert(flow.user_interactions, item.text)
    elseif item.type == 'assignment_expression' or item.type == 'variable_declaration' then
      table.insert(flow.data_flow, item.text)
    elseif item.type == 'return_statement' or item.text:match 'render' or item.text:match 'redirect' then
      table.insert(flow.exit_points, item.text)
    end
  end

  if flow.entry_point then
    table.insert(user_flows, flow)
  end
end

-- Display user flows
if #user_flows == 0 then
  print 'No user flows identified in the current buffer.'
  return
end

local lines = {}
for i, flow in ipairs(user_flows) do
  table.insert(lines, string.format('User Flow %d:', i))
  table.insert(lines, string.format('  Entry Point: %s', flow.entry_point))
  table.insert(lines, '  User Interactions:')
  for _, interaction in ipairs(flow.user_interactions) do
    table.insert(lines, string.format('    - %s', interaction))
  end
  table.insert(lines, '  Data Flow:')
  for _, data in ipairs(flow.data_flow) do
    table.insert(lines, string.format('    - %s', data))
  end
  table.insert(lines, '  Exit Points:')
  for _, exit in ipairs(flow.exit_points) do
    table.insert(lines, string.format('    - %s', exit))
  end
  table.insert(lines, '')
end

vim.ui.select(lines, {
  prompt = 'Identified User Flows:',
  format_item = function(item)
    return item
  end,
}, function(choice)
  if choice then
    local flow_num = tonumber(choice:match 'User Flow (%d+):')
    if flow_num then
      local selected_flow = user_flows[flow_num]
      local details = {
        string.format('User Flow %d Details:', flow_num),
        string.format('Entry Point: %s', selected_flow.entry_point),
        'User Interactions:',
      }
      for _, interaction in ipairs(selected_flow.user_interactions) do
        table.insert(details, string.format('  - %s', interaction))
      end
      table.insert(details, 'Data Flow:')
      for _, data in ipairs(selected_flow.data_flow) do
        table.insert(details, string.format('  - %s', data))
      end
      table.insert(details, 'Exit Points:')
      for _, exit in ipairs(selected_flow.exit_points) do
        table.insert(details, string.format('  - %s', exit))
      end

      vim.api.nvim_echo(
        vim.tbl_map(function(line)
          return { line, 'Normal' }
        end, details),
        false,
        {}
      )
    end
  end
end)

-- Keybinding for analyzing user flows
vim.keymap.set('n', '<leader>tu', function()
  analyze_user_flows()
end, { desc = 'Analyze user flows' })

-- Function to analyze user flows
local function analyze_user_flows()
  local parsers = require 'nvim-treesitter.parsers'
  local bufnr = vim.api.nvim_get_current_buf()
  local root = parsers.get_parser(bufnr):parse()[1]:root()

  local all_chains = {}
  local user_flows = {}

  local function analyze_node(node)
    local start_row, _, end_row, _ = node:range()
    local chain = trace_causal_chain_for_node(node)
    if #chain > 0 then
      table.insert(all_chains, {
        range = { start_row + 1, end_row + 1 },
        chain = chain,
      })
    end

    for child in node:iter_children() do
      analyze_node(child)
    end
  end

  analyze_node(root)

  -- Identify user flows from causal chains
  for _, chain in ipairs(all_chains) do
    local flow = {
      entry_point = nil,
      user_interactions = {},
      data_flow = {},
      exit_points = {},
    }

    for _, item in ipairs(chain.chain) do
      if item.type == 'function_definition' and (item.text:match 'handle' or item.text:match 'route') then
        flow.entry_point = item.text
      elseif item.type == 'call_expression' and (item.text:match 'input' or item.text:match 'get' or item.text:match 'post') then
        table.insert(flow.user_interactions, item.text)
      elseif item.type == 'assignment_expression' or item.type == 'variable_declaration' then
        table.insert(flow.data_flow, item.text)
      elseif item.type == 'return_statement' or item.text:match 'render' or item.text:match 'redirect' then
        table.insert(flow.exit_points, item.text)
      end
    end

    if flow.entry_point then
      table.insert(user_flows, flow)
    end
  end

  -- Display user flows
  if #user_flows == 0 then
    print 'No user flows identified in the current buffer.'
    return user_flows
  end

  local lines = {}
  for i, flow in ipairs(user_flows) do
    table.insert(lines, string.format('User Flow %d:', i))
    table.insert(lines, string.format('  Entry Point: %s', flow.entry_point))
    table.insert(lines, '  User Interactions:')
    for _, interaction in ipairs(flow.user_interactions) do
      table.insert(lines, string.format('    - %s', interaction))
    end
    table.insert(lines, '  Data Flow:')
    for _, data in ipairs(flow.data_flow) do
      table.insert(lines, string.format('    - %s', data))
    end
    table.insert(lines, '  Exit Points:')
    for _, exit in ipairs(flow.exit_points) do
      table.insert(lines, string.format('    - %s', exit))
    end
    table.insert(lines, '')
  end

  vim.ui.select(lines, {
    prompt = 'Identified User Flows:',
    format_item = function(item)
      return item
    end,
  }, function(choice)
    if choice then
      local flow_num = tonumber(choice:match 'User Flow (%d+):')
      if flow_num then
        local selected_flow = user_flows[flow_num]
        local details = {
          string.format('User Flow %d Details:', flow_num),
          string.format('Entry Point: %s', selected_flow.entry_point),
          'User Interactions:',
        }
        for _, interaction in ipairs(selected_flow.user_interactions) do
          table.insert(details, string.format('  - %s', interaction))
        end
        table.insert(details, 'Data Flow:')
        for _, data in ipairs(selected_flow.data_flow) do
          table.insert(details, string.format('  - %s', data))
        end
        table.insert(details, 'Exit Points:')
        for _, exit in ipairs(selected_flow.exit_points) do
          table.insert(details, string.format('  - %s', exit))
        end

        vim.api.nvim_echo(
          vim.tbl_map(function(line)
            return { line, 'Normal' }
          end, details),
          false,
          {}
        )
      end
    end
  end)

  return user_flows
end

-- Function to copy user flows to clipboard
local function copy_user_flows_to_clipboard()
  local flows = analyze_user_flows(true) -- We'll modify analyze_user_flows to return the flows
  if #flows == 0 then
    print 'No user flows to copy.'
    return
  end

  local clipboard_text = ''
  for i, flow in ipairs(flows) do
    clipboard_text = clipboard_text .. string.format('User Flow %d:\n', i)
    clipboard_text = clipboard_text .. string.format('  Entry Point: %s\n', flow.entry_point)
    clipboard_text = clipboard_text .. '  User Interactions:\n'
    for _, interaction in ipairs(flow.user_interactions) do
      clipboard_text = clipboard_text .. string.format('    - %s\n', interaction)
    end
    clipboard_text = clipboard_text .. '  Data Flow:\n'
    for _, data in ipairs(flow.data_flow) do
      clipboard_text = clipboard_text .. string.format('    - %s\n', data)
    end
    clipboard_text = clipboard_text .. '  Exit Points:\n'
    for _, exit in ipairs(flow.exit_points) do
      clipboard_text = clipboard_text .. string.format('    - %s\n', exit)
    end
    clipboard_text = clipboard_text .. '\n'
  end

  vim.fn.setreg('+', clipboard_text)
  print 'User flows copied to clipboard.'
end

-- Keybinding for copying user flows to clipboard
vim.keymap.set('n', '<leader>tc', copy_user_flows_to_clipboard, { desc = 'Copy user flows to clipboard' })

-- Function to open or create a notes file
function open_notes()
  local notes_dir = vim.fn.expand '~/notes'
  if vim.fn.isdirectory(notes_dir) == 0 then
    vim.fn.mkdir(notes_dir, 'p')
  end

  vim.ui.select({ 'Search existing notes', 'Create new note', 'View recent notes', 'Search by tag' }, {
    prompt = 'Choose an action:',
  }, function(choice)
    if choice == 'Search existing notes' then
      require('telescope.builtin').find_files {
        prompt_title = '< Notes >',
        cwd = notes_dir,
        find_command = { 'rg', '--files', '--hidden', '--glob', '!.git/*' },
        attach_mappings = function(_, map)
          map('i', '<CR>', function(prompt_bufnr)
            local selection = require('telescope.actions.state').get_selected_entry()
            require('telescope.actions').close(prompt_bufnr)
            if selection then
              edit_note(notes_dir .. '/' .. selection.value)
            end
          end)
          return true
        end,
      }
    elseif choice == 'Create new note' then
      create_new_note(notes_dir)
    elseif choice == 'View recent notes' then
      view_recent_notes(notes_dir)
    elseif choice == 'Search by tag' then
      search_notes_by_tag(notes_dir)
    end
  end)
end

-- Ensure this block is placed after all plugin configurations
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    -- Command to open notes
    vim.api.nvim_create_user_command('Notes', open_notes, {})

    -- Refresh which-key to ensure all mappings are up-to-date
    require('which-key').reset()
  end,
})

-- Ensure Telescope is properly set up
require('telescope').setup {
  defaults = {
    -- Add any Telescope-specific settings here
  },
  pickers = {
    find_files = {
      theme = 'dropdown',
    },
  },
}

-- Go development configuration
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'go',
  callback = function()
    -- Go specific keybindings
    vim.keymap.set('n', '<leader>gr', '<cmd>GoRun<CR>', { buffer = true, desc = 'Go Run' })
    vim.keymap.set('n', '<leader>gt', '<cmd>GoTest<CR>', { buffer = true, desc = 'Go Test' })
    vim.keymap.set('n', '<leader>gi', '<cmd>GoImpl<CR>', { buffer = true, desc = 'Go Implement' })
    vim.keymap.set('n', '<leader>gd', '<cmd>GoDef<CR>', { buffer = true, desc = 'Go to Definition' })
    vim.keymap.set('n', '<leader>gD', '<cmd>GoDoc<CR>', { buffer = true, desc = 'Go Documentation' })
    vim.keymap.set('n', '<leader>gf', '<cmd>GoFillStruct<CR>', { buffer = true, desc = 'Go Fill Struct' })
    vim.keymap.set('n', '<leader>ge', '<cmd>GoIfErr<CR>', { buffer = true, desc = 'Go If Err' })
  end,
})

-- Configure go.nvim
require('go').setup {
  -- Add any specific configuration here
  goimport = 'gopls', -- use gopls for auto import
  gofmt = 'gofumpt',  -- use gofumpt for better formatting
  max_line_len = 120,
  tag_transform = false,
  test_dir = '',
  comment_placeholder = '   ',
  lsp_cfg = true,       -- false: use your own lspconfig
  lsp_gofumpt = true,   -- true: set default gofmt in gopls format to gofumpt
  lsp_on_attach = true, -- use on_attach from go.nvim
  dap_debug = true,
}

-- Configure gopher.nvim
require('gopher').setup {
  commands = {
    go = 'go',
    gomodifytags = 'gomodifytags',
    gotests = 'gotests',
    impl = 'impl',
    iferr = 'iferr',
  },
}

print 'Neovim configuration loaded successfully!'
