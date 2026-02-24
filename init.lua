local current_theme = "zoomer"
themes = {
    boomer = {
        colorscheme = "neodarcula",
        font = "LiterationMono Nerd Font:b",
        default_font_size = 9.5,
        number = false,
        relativenumber = false,
        lualine = false,

        colorscheme_lazy_fetch = {
            "pmouraguedes/neodarcula.nvim",
            lazy = false,
            priority = 1000,
            opts = {
                transparent = false, -- Enable transparent background
                dim = false,         -- Dim inactive windows with a black background
            },
        },
    },

    zoomer = {
        colorscheme = "kanagawa",
        font = "JetBrains Mono",
        default_font_size = 20,
        number = true,
        relativenumber = true,
        lualine = true,

        colorscheme_lazy_fetch = { "rebelot/kanagawa.nvim" },
    },

    tsoding = {
        colorscheme = "gruber-darker",
        font = "Iosevka Nerd Font Mono",
        default_font_size = 21.5,
        number = true,
        relativenumber = true,
        lualine = false,

        colorscheme_lazy_fetch = { "blazkowolf/gruber-darker.nvim" }
    },
    
    vscode = {
        colorscheme = "vscode",
        font = "Cascadia Code",
        default_font_size = 19,
        number = true,
        relativenumber = false,
        lualine = true,

        colorscheme_lazy_fetch = { 'Mofiqul/vscode.nvim' }
    },

    fallback = {
        colorscheme = "default",
        font = "Consolas",
        default_font_size = 11,
        number = false,
        relativenumber = false,
        lualine = false,
    },
}

local colorscheme = themes[current_theme].colorscheme
local font = themes[current_theme].font
local default_font_size = themes[current_theme].default_font_size
local number = themes[current_theme].number
local relativenumber = themes[current_theme].relativenumber
local enable_lualine = themes[current_theme].lualine

local is_windows = vim.fn.has('win32') == 1
local dirdelim = is_windows and '\\' or '/'
local configdir = vim.fn.stdpath('config')

local scratchpad_path = configdir .. dirdelim .. 'scratchpad'
local open_scratchpad = function()
    vim.cmd("edit! " .. scratchpad_path)
end

local todo_path = configdir .. dirdelim .. 'todo'
local open_todo = function()
    vim.cmd("edit! " .. todo_path)
end

local font_size = nil
local font_size_delta = 0.5

local set_font_size = function(value)
    font_size = value
    vim.o.guifont = font .. ':h' .. font_size
end

local load_theme = function(theme)
    if themes[theme] ~= nil then
        current_theme = theme
        colorscheme = themes[current_theme].colorscheme
        font = themes[current_theme].font
        default_font_size = themes[current_theme].default_font_size
        number = themes[current_theme].number
        relativenumber = themes[current_theme].relativenumber

        vim.o.number         = number
        vim.o.relativenumber = relativenumber
        set_font_size(default_font_size)
        vim.cmd("colorscheme " .. colorscheme)
    else
        print("Theme '" .. theme .. "' is not present.")
    end
end

-- 'bdelete!' command kills not only the buffer, but current split too. So I had to override this.
-- God I hate vim runtime.
local kill_current_buffer = function()
    local buflist = vim.api.nvim_list_bufs()
    local count_buffers = 0
    for _, bufnr in ipairs(buflist) do
        if vim.fn.buflisted(bufnr) == 1 then
            count_buffers = count_buffers + 1
        end
    end

    local bufnr = vim.api.nvim_get_current_buf()
    if count_buffers > 1 then
        -- If there are buffers just go anywhere else
        vim.cmd("bprev")
        vim.api.nvim_buf_delete(bufnr, { force = true })
    elseif vim.api.nvim_buf_get_name(bufnr) ~= scratchpad_path then
        open_scratchpad()
        vim.api.nvim_buf_delete(bufnr, { force = true })
        vim.cmd("bprev")
    end
end

local get_current_window_size = function()
    local win_id = vim.api.nvim_get_current_win()
    local rows = vim.api.nvim_win_get_height(win_id)
    local cols = vim.api.nvim_win_get_width(win_id)
    return {
        win_id = win_id,
        rows = rows,
        cols = cols
    }
end

directory_stack = {}
local pushd = function(directory)
    if vim.fn.isdirectory(directory) then
        table.insert(directory_stack, vim.fn.getcwd())
        vim.api.nvim_set_current_dir(directory)
    else
        print("'" .. directory .. "' is not a directory.")
    end
end

local popd = function()
    if #directory_stack == 0 then
        print("Directory stack is empty.")
        return
    end

    local directory = table.remove(directory_stack)
    if vim.fn.isdirectory(directory) then
        vim.api.nvim_set_current_dir(directory)
    else
        print("Popped element '" .. directory .. "' is not a directory.")
    end
end

local jump_to_compile_buf = function()
    local compile_bufname = vim.fn.getcwd() .. dirdelim .. "compilation"

    local winlist = vim.api.nvim_list_wins()
    for _, winid in ipairs(winlist) do
        local winbufnr = vim.api.nvim_win_get_buf(winid)
        local bufname  = vim.api.nvim_buf_get_name(winbufnr)
        if bufname == compile_bufname then
            vim.api.nvim_set_current_win(winid)
            return true
        end
    end

    local buflist = vim.api.nvim_list_bufs()
    for _, bufnr in ipairs(buflist) do
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        if bufname == compile_bufname then
            local winid = vim.api.nvim_get_current_win()
            vim.api.nvim_win_set_buf(winid, bufnr)
            return true
        end
    end

    return false
end

local vsplit_column_lower_bound = 110
local internal_compile = function(compile_command)
    local wincount          = #vim.api.nvim_list_wins()
    local size              = get_current_window_size()
    local had_compile_buf   = jump_to_compile_buf()

    if not had_compile_buf and size.cols > vsplit_column_lower_bound then
        vim.cmd("vert botright " .. compile_command)
    else
        vim.cmd(compile_command)
    end

    -- Kill current window if compile creates a split, when there are already more than two
    if not had_compile_buf and wincount >= 2 then
        vim.api.nvim_win_close(size.win_id, true)
        jump_to_compile_buf()
    end
end

local compile = function()
    internal_compile("Compile")
end

local recompile = function()
    internal_compile("Recompile")
end

local compile_prev_error = function()
    if jump_to_compile_buf() then
        vim.cmd("CompilePrevError")
    end
end

local compile_next_error = function()
    if jump_to_compile_buf() then
        vim.cmd("CompileNextError")
    end
end

local compile_interrupt = function()
    if jump_to_compile_buf() then
        vim.cmd("CompileInterrupt")
    end
end

local split = function()
    local size = get_current_window_size()
    if size.cols > vsplit_column_lower_bound then
        vim.cmd("vsplit")
    end
end

local generate_title_string = function()
    if vim.fn.executable 'fortune' then
        return vim.fn.system("fortune -n 100")
    else
        return "Text Editor"
    end
end

local setup_gui_client = function()
    set_font_size(default_font_size)
    vim.o.guicursor = "a:blinkon0-block-Cursor/lCursor"

    vim.api.nvim_set_keymap('', '<C-=>', '', {
        noremap = true,
        callback = function()
            set_font_size(font_size + font_size_delta)
        end
    })

    vim.api.nvim_set_keymap('', '<C-->', '', {
        noremap = true,
        callback = function()
            set_font_size(font_size - font_size_delta)
        end
    })

    vim.api.nvim_set_keymap('', '<C-0>', '', {
        noremap = true,
        callback = function()
            set_font_size(default_font_size)
        end
    })

    if vim.g.neovide then
        vim.g.neovide_window_blurred = true
        vim.g.neovide_theme = "bg_color"
        vim.g.neovide_position_animation_length = 0.0
        vim.g.neovide_scroll_animation_length = 0.0
        vim.g.neovide_cursor_animation_length = 0.0
        vim.g.neovide_cursor_short_animation_length = 0.0
        vim.g.neovide_cursor_trail_size = 0.0
        vim.g.neovide_fullscreen = false
        vim.g.neovide_opacity = 1.0
        vim.g.neovide_normal_opacity = 1.0

        vim.api.nvim_set_keymap('', '<F11>', '', {
            noremap = true,
            callback = function()
                vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
            end
        })
    end
end

local create_user_commands = function()
    function theme_loader(opts)
        load_theme(opts.args)
    end

    function pushd_handler(opts)
        pushd(opts.args)
    end

    vim.api.nvim_create_user_command('MyConfig',    'e! ' .. vim.env.MYVIMRC,  {})
    vim.api.nvim_create_user_command('MyScratch',   'e! ' .. scratchpad_path,  {})
    vim.api.nvim_create_user_command('MyTodo',      'e! ' .. todo_path,        {})
    vim.api.nvim_create_user_command('MyCompile',   'lua compile()',           {})
    vim.api.nvim_create_user_command('MyRecompile', 'lua recompile()',         {})
    vim.api.nvim_create_user_command('MyLoadTheme', theme_loader,   { nargs = 1 })
    vim.api.nvim_create_user_command('Pushd',       pushd_handler,  { nargs = 1, complete = "dir" })
    vim.api.nvim_create_user_command('Popd',        popd,           { nargs = 0 })
end

local create_auto_commands = function()
    vim.api.nvim_create_autocmd('TextYankPost', {
        desc = 'Highlight yanked text.',
        group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
        callback = function()
            vim.hl.on_yank()
        end
    })
end

local set_basic_keymaps = function()
    vim.api.nvim_set_keymap('', '<C-,>',      '<cmd>bp<CR>', { noremap = true })
    vim.api.nvim_set_keymap('', '<C-.>',      '<cmd>bn<CR>', { noremap = true })
    vim.api.nvim_set_keymap('', '<C-k>',      '',            { noremap = true, callback = kill_current_buffer })
end

local setup_telescope = function()
    local telescope = require('telescope.builtin')
    vim.keymap.set('n', '<leader>sf', telescope.find_files,                 { desc = '[S]earch [F]iles'          })
    vim.keymap.set('n', '<leader>sg', telescope.live_grep,                  { desc = '[S]earch by [G]rep'        })
    vim.keymap.set('n', '<leader>sb', telescope.buffers,                    { desc = '[S]earch [B]uffer'         })
    vim.keymap.set('n', '<leader>sh', telescope.help_tags,                  { desc = '[S]earch [H]elp'           })
    vim.keymap.set('n', '<leader>sw', telescope.grep_string,                { desc = '[S]earch current [W]ord'   })
    vim.keymap.set('n', '<leader>s/', telescope.current_buffer_fuzzy_find,  { desc = '[S]earch like [/]'         })
    vim.keymap.set('n', '<leader>sd', telescope.diagnostics,                { desc = '[S]earch [D]iagnostics'    })
    vim.keymap.set('n', '<leader>st', telescope.tags,                       { desc = '[S]earch [T]ags'           })
    vim.keymap.set('n', '<leader>sp', telescope.treesitter,                 { desc = '[S]earch [P]arser'         })
    vim.keymap.set('n', '<leader>ss', telescope.builtin,                    { desc = '[S]earch [S]omething'      })
    vim.keymap.set('n', '<leader>sr', telescope.resume,                     { desc = '[S]earch [R]esume'         })
end

local setup_treesitter = function()
    local install = require('nvim-treesitter.install')
    install.prefer_git = false
    install.compilers = { "cl", "clang", "gcc" }

    local configs = require("nvim-treesitter.configs")
    configs.setup({
        ensure_installed = { "c", "cpp", "rust", "lua", "zig", "python", "qmldir", "qmljs", "odin" },
        sync_install = false,
        highlight = { enable = true },
        indent = { enable = true },
    })
end

local attach_lsp = function(event)
    local telescope = require('telescope.builtin')
    local map = function(keys, func, desc)
        vim.keymap.set('n', keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
    end

    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame symbol')
    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
    map('<leader>sr', telescope.lsp_references, '[S]earch [R]eferences')
    map('<leader>si', telescope.lsp_implementations, '[S]earch [I]mplementation')
    map('<leader>gd', telescope.lsp_definitions, '[G]oto [D]efinition')
    map('<leader>gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    map('<leader>sW', telescope.lsp_dynamic_workspace_symbols, '[S]earch [W]orkspace symbols')
    map('<leader>gt', telescope.lsp_type_definitions, '[G]oto [T]ype Definition')

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
        local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
        })

        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
        })

        vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
            callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
            end,
        })
    end

    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
        map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
        end, '[T]oggle Inlay [H]ints')
    end
end

local setup_lspconfig = function()
    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = attach_lsp
    })

    vim.diagnostic.config({
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = false,
        signs = false,
        virtual_text = false,
    })

    local capabilities = require('blink.cmp').get_lsp_capabilities()
    local servers = {
        rust_analyzer = {},
        clangd = {
            capabilities = capabilities,
            cmd = { 'clangd', '--background-index', '--clang-tidy' }, -- Example custom command
            filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto', 'hpp' },
            settings = {
                clangd = {
                    arguments = { '--header-insertion=never' },
                },
            },
        },
        lua_ls = {},
        zls = {},
        ols = {
            init_options = {
                checker_args = "-strict-style",
                collections = {
                    { name = "shared", path = vim.fn.expand('$HOME/odin-lib') }
                },
            },
        },
    }

    local ensure_installed = vim.tbl_keys(servers or {})
    vim.list_extend(ensure_installed, { 'rust_analyzer', 'clangd', 'stylua', 'zls', 'ols' })
    require('mason-tool-installer').setup({ ensure_installed = ensure_installed })
    require('mason-lspconfig').setup({
        ensure_installed = {},
        automatic_installation = false,
        automatic_enable = { "rust_analyzer", "lua_ls", "stylua", "clangd", "zls", "ols" },
        handlers = {
            function(server_name)
                local server = servers[server_name] or {}
                server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
                require('lspconfig')[server_name].setup(server)
            end,
        }
    })
end

local setup_lualine = function()
    require('lualine').setup({
      options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = { left = '', right = ''},
        section_separators = { left = '', right = ''},
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        always_show_tabline = true,
        globalstatus = false,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
          refresh_time = 16, -- ~60fps
          events = {
            'WinEnter',
            'BufEnter',
            'BufWritePost',
            'SessionLoadPost',
            'FileChangedShellPost',
            'VimResized',
            'Filetype',
            'CursorMoved',
            'CursorMovedI',
            'ModeChanged',
          },
        }
      },
      sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch', 'diff', 'diagnostics'},
        lualine_c = {'filename'},
        lualine_x = {'encoding', 'fileformat', 'filetype'},
        lualine_y = {'progress'},
        lualine_z = {'location'}
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {'filename'},
        lualine_x = {'location'},
        lualine_y = {},
        lualine_z = {}
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = {}
    })
end

local setup_compile_mode = function()
    vim.g.compile_mode = {
        default_command = "",
        buffer_name = "compilation",
        baleia_setup = true,
        input_word_completion = true,
        focus_compilation_buffer = true,
    }

    vim.api.nvim_set_keymap('', '<F5>',   '', { noremap = true, callback = compile              })
    vim.api.nvim_set_keymap('', '<C-F5>', '', { noremap = true, callback = compile_interrupt    })
    vim.api.nvim_set_keymap('', '<S-F5>', '', { noremap = true, callback = recompile            })
    vim.api.nvim_set_keymap('', '<C-F6>', '', { noremap = true, callback = jump_to_compile_buf  })
    vim.api.nvim_set_keymap('', '<F6>',   '', { noremap = true, callback = compile_next_error   })
    vim.api.nvim_set_keymap('', '<S-F6>', '', { noremap = true, callback = compile_prev_error   })
end

local setup_package_manager = function()
    local lazy_fetch_table = {
        { 'nvim-telescope/telescope.nvim', dependencies = { 'nvim-lua/plenary.nvim' }, config = setup_telescope },
        { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate', config = setup_treesitter },
        {
            'folke/lazydev.nvim',
            ft = 'lua',
            opts = {
                library = {
                    { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
                },
            },
        },
        {
            'neovim/nvim-lspconfig',
            dependencies = {
                { 'williamboman/mason.nvim', opts = {} },
                'williamboman/mason-lspconfig.nvim',
                'WhoIsSethDaniel/mason-tool-installer.nvim',
                { 'j-hui/fidget.nvim', opts = {} },
                'saghen/blink.cmp'
            },
            config = setup_lspconfig
        },

        { -- Autocompletion
            'saghen/blink.cmp',
            event = 'VimEnter',
            version = '1.*',
            dependencies = {
                -- Snippet Engine
                {
                    'L3MON4D3/LuaSnip',
                    version = '2.*',
                    build = (function()
                        if vim.fn.has 'win32' == 0 and vim.fn.executable 'make' == 1 then
                            return 'make install_jsregexp'
                        end
                    end)(),
                    opts = {},
                },
                'folke/lazydev.nvim',
            },

            --- @module 'blink.cmp'
            --- @type blink.cmp.Config
            opts = {
                keymap = { preset = 'default' },
                appearance = { nerd_font_variant = 'mono' },
                completion = {
                    documentation = { auto_show = false, auto_show_delay_ms = 200 },
                    menu = { auto_show = false }
                },

                sources = {
                    default = { 'lsp', 'path', 'snippets', 'lazydev' },
                    providers = {
                        lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
                    },
                },

                snippets = { preset = 'luasnip' },
                fuzzy = { implementation = 'lua' },
                signature = { enabled = true },
            },
        },

        {
            'ej-shafran/compile-mode.nvim',
            branch = "latest",
            dependencies = {
                'nvim-lua/plenary.nvim',
                { "m00qek/baleia.nvim", tag = "v1.3.0" },
            },
            config = setup_compile_mode
        },

        'tpope/vim-fugitive',
        'rluba/jai.vim',
    }

    if enable_lualine then
        table.insert(lazy_fetch_table,
        {
            'nvim-lualine/lualine.nvim',
            dependencies = { 'nvim-tree/nvim-web-devicons' },
            config = setup_lualine
        })
    end

    for _, theme in pairs(themes) do
        if theme.colorscheme_lazy_fetch ~= nil then
            table.insert(lazy_fetch_table, theme.colorscheme_lazy_fetch)
        end
    end

    require("lazy").setup(lazy_fetch_table)
end

local bootstrap_package_manager = function()
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
            return false
        end
    end
    vim.opt.rtp:prepend(lazypath)
    return true
end

local setup_core_vim = function()
    vim.o.termguicolors  = true
    vim.o.number         = number
    vim.o.relativenumber = relativenumber
    vim.o.backup         = false
    vim.o.writebackup    = false
    vim.o.tabstop        = 4
    vim.o.shiftwidth     = 4
    vim.o.expandtab      = true
    vim.o.autoindent     = true
    vim.o.wildmenu       = true
    vim.o.wildmode       = "list:longest,list:full" 
    vim.o.wildignore     = "*.jpg,*.png,*.pdf,*.exe,*.dll,*.gif,*.so,*.mp3"
    vim.o.showcmd        = true
    vim.g.mapleader      = ' '
    vim.g.maplocalleader = "\\"
    vim.o.scrolloff      = 10
    vim.o.signcolumn     = "yes"
    vim.o.belloff        = "all"
    vim.o.cursorline     = true
    vim.o.title          = true
    vim.o.titlestring    = generate_title_string()
    vim.o.linespace      = 0
    vim.o.wrap           = false
    vim.o.wildignore     = "*/build*/*,*/.*/*"
    if is_windows then
        vim.o.fileformat = "dos"
    else
        vim.g.clipboard = "xclip"
    end
end

setup_core_vim()
setup_gui_client()
create_user_commands()
create_auto_commands()
set_basic_keymaps()
if bootstrap_package_manager() then
    setup_package_manager()
end

vim.cmd("colorscheme " .. colorscheme)
if next(vim.fn.argv()) == nil then
    open_scratchpad()
end
