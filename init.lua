-- Some DIY functionality.
local is_windows = vim.fn.has('win32') == 1
Kmitrich = {
    is_windows = is_windows,
    gui = {
        font = "Liberation Mono",
        font_size = nil,
        opacity = 1.0,

        set_font_size = function(val)
            Kmitrich.gui.font_size = val
            vim.o.guifont = Kmitrich.gui.font .. ':h' .. Kmitrich.gui.font_size
        end,

        set_neovide_opacity = function(val)
            Kmitrich.gui.opacity = val
            vim.g.neovide_opacity = Kmitrich.gui.opacity
            vim.g.neovide_normal_opacity = Kmitrich.gui.opacity
        end
    }
}

-- Basic vim setup.
vim.o.termguicolors  = true
vim.o.number         = true
vim.o.relativenumber = true
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
vim.o.cursorline     = true

if not Kmitrich.is_windows then
    vim.g.clipboard  = "xclip"
    vim.o.fileformat = "dos"
end

vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight yanked text.',
    group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end
})

-- Neovide client settings.
if vim.g.neovide then
    Kmitrich.gui.set_font_size(10)
    Kmitrich.gui.set_neovide_opacity(1.0)

    vim.o.guicursor = "a:blinkon0-block-Cursor/lCursor"
    vim.g.neovide_window_blurred = true
    vim.g.neovide_theme = "dark"
    vim.g.neovide_scroll_animation_length = 0.0
    vim.g.neovide_cursor_animation_length = 0.0

    vim.api.nvim_set_keymap('', '<C-=>', '', {
        noremap = true,
        callback = function()
            Kmitrich.gui.set_font_size(Kmitrich.gui.font_size + 1)
        end
    })

    vim.api.nvim_set_keymap('', '<C-->', '', {
        noremap = true,
        callback = function()
            Kmitrich.gui.set_font_size(Kmitrich.gui.font_size - 1)
        end
    })

    vim.api.nvim_set_keymap('', '<F11>', '', {
        noremap = true,
        callback = function()
            vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
        end
    })

    if Kmitrich.is_windows then
        local cwd = vim.fn.getcwd(-1, -1)
        print(cwd)
        if cwd == "C:\\Program Files\\Neovide" then
            vim.api.nvim_set_current_dir("C:\\")
        end
    end
end

-- Basic keymaps.
vim.api.nvim_set_keymap('', '<C-,>',      '<cmd>bprev<CR>',                            { noremap = true })
vim.api.nvim_set_keymap('', '<C-.>',      '<cmd>bnext<CR>',                            { noremap = true })
vim.api.nvim_set_keymap('', '<C-k>',      '<cmd>bdelete!<CR>',                         { noremap = true })
vim.api.nvim_set_keymap('', '<leader>cd', ':cd ' .. vim.fn.expand('%:p'),              { noremap = true })
vim.api.nvim_set_keymap('', '<leader>hl', '<cmd>set hlsearch!<CR>',                    { noremap = true })
vim.api.nvim_set_keymap('', '<leader>ld', '<cmd>:lua vim.diagnostic.open_float()<CR>', { noremap = true })
vim.api.nvim_set_keymap('', '<leader>fs', '<cmd>:e .<CR>',                             { noremap = true })
vim.api.nvim_set_keymap('', '<A-t>',      '<cmd>:term<CR>',                            { noremap = true })
vim.api.nvim_create_user_command('KmEditConfig', 'e! ' .. vim.env.MYVIMRC, {})

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

-- Setup lazy.nvim
require("lazy").setup({
    {
        -- The most important plugin ever.
        'nvim-telescope/telescope.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
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
    },

    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        config = function()
            local install = require('nvim-treesitter.install')
            install.prefer_git = false
            install.compilers = { "cl", "clang", "gcc" }

            local configs = require("nvim-treesitter.configs")
            configs.setup({
                ensure_installed = { "c", "cpp", "lua", "zig" },
                sync_install = false,
                highlight = { enable = true },
                indent = { enable = true },
            })
        end
    },

    {
        'folke/lazydev.nvim',
        ft = 'lua',
        opts = {
            library = {
                -- Load luvit types when the `vim.uv` word is found
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
        config = function()
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
                callback = function(event)
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
                end,
            })

            vim.diagnostic.config({
                --severity_sort = true,
                float = { border = 'rounded', source = 'if_many' },
                --underline = { severity = vim.diagnostic.severity.ERROR },
                --signs = {},
                --virtual_text = {
                --    source = 'if_many',
                --    spacing = 2,
                --    format = function(diagnostic)
                --        local diagnostic_message = {
                --            [vim.diagnostic.severity.ERROR] = diagnostic.message,
                --            [vim.diagnostic.severity.WARN] = diagnostic.message,
                --            [vim.diagnostic.severity.INFO] = diagnostic.message,
                --            [vim.diagnostic.severity.HINT] = diagnostic.message,
                --        }
                --        return diagnostic_message[diagnostic.severity]
                --    end,
                --},
                severity_sort = false,
                signs = false,
                virtual_text = false
            })

            local capabilities = require('blink.cmp').get_lsp_capabilities()
            local servers = {
                clangd = {},
                lua_ls = {},
                zls = {}
            }

            local ensure_installed = vim.tbl_keys(servers or {})
            vim.list_extend(ensure_installed, { 'clangd', 'stylua', 'zls' })
            require('mason-tool-installer').setup({ ensure_installed = ensure_installed })
            require('mason-lspconfig').setup({
                ensure_installed = {},
                automatic_installation = false,
                automatic_enable = { "lua_ls", "stylua", "zls" },
                handlers = {
                    function(server_name)
                        local server = servers[server_name] or {}
                        server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
                        require('lspconfig')[server_name].setup(server)
                    end,
                }
            })
        end
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
                    -- Build Step is needed for regex support in snippets.
                    -- This step is not supported in many windows environments.
                    -- Remove the below condition to re-enable on windows.
                    if vim.fn.has 'win32' == 0 and vim.fn.executable 'make' == 1 then
                        return 'make install_jsregexp'
                    end
                end)(),
                dependencies = {
                    -- `friendly-snippets` contains a variety of premade snippets.
                    --    See the README about individual language/framework/plugin snippets:
                    --    https://github.com/rafamadriz/friendly-snippets
                    -- {
                    --   'rafamadriz/friendly-snippets',
                    --   config = function()
                    --     require('luasnip.loaders.from_vscode').lazy_load()
                    --   end,
                    -- },
                },
                opts = {},
            },
            'folke/lazydev.nvim',
        },

        --- @module 'blink.cmp'
        --- @type blink.cmp.Config
        opts = {
            keymap = {
                -- 'default' (recommended) for mappings similar to built-in completions
                --   <c-y> to accept ([y]es) the completion.
                --    This will auto-import if your LSP supports it.
                --    This will expand snippets if the LSP sent a snippet.
                -- 'super-tab' for tab to accept
                -- 'enter' for enter to accept
                -- 'none' for no mappings
                --
                -- For an understanding of why the 'default' preset is recommended,
                -- you will need to read `:help ins-completion`
                --
                -- No, but seriously. Please read `:help ins-completion`, it is really good!
                --
                -- All presets have the following mappings:
                -- <tab>/<s-tab>: move to right/left of your snippet expansion
                -- <c-space>: Open menu or open docs if already open
                -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
                -- <c-e>: Hide menu
                -- <c-k>: Toggle signature help
                --
                -- See :h blink-cmp-config-keymap for defining your own keymap
                preset = 'default',

                -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
                --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
            },

            appearance = {
                -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                -- Adjusts spacing to ensure icons are aligned
                nerd_font_variant = 'mono',
            },

            completion = {
                -- By default, you may press `<c-space>` to show the documentation.
                -- Optionally, set `auto_show = true` to show the documentation after a delay.
                documentation = { auto_show = false, auto_show_delay_ms = 200 },
                menu = { auto_show = true }
            },

            sources = {
                default = { 'lsp', 'path', 'snippets', 'lazydev' },
                providers = {
                    lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
                },
            },

            snippets = { preset = 'luasnip' },

            -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
            -- which automatically downloads a prebuilt binary when enabled.
            --
            -- By default, we use the Lua implementation instead, but you may enable
            -- the rust implementation via `'prefer_rust_with_warning'`
            --
            -- See :h blink-cmp-config-fuzzy for more information
            fuzzy = { implementation = 'lua' },

            -- Shows a signature help window while you type arguments for a function
            signature = { enabled = true },
        },
    },

    {
        'ej-shafran/compile-mode.nvim',
        branch = "latest",
        dependencies = {
            'nvim-lua/plenary.nvim'
        },
        config = function()
            vim.g.compile_mode = {
                default_command = "",
                buffer_name = "compilation",
                baleia_setup = true
            }

            vim.api.nvim_set_keymap('', '<F5>',     '<cmd>:vert botright Compile<CR>',      { noremap = true })
            vim.api.nvim_set_keymap('', '<S-F5>',   '<cmd>:vert botright Recompile<CR>',    { noremap = true })
        end
    },

    'tpope/vim-fugitive',
    'tpope/vim-dispatch',
    {
        "skylarmb/torchlight.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            contrast = "hard", -- possible values: soft, medium, hard
        },
    },
})

