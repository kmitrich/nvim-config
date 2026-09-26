local use_package_manager   = true
local colorscheme           = "default"
local font                  = "Source_Code_Pro"
local default_font_size     = 11
local font_size             = nil
local font_size_delta       = 0.25
local font_aliasing         = "subpixelantialias"
local font_hinting          = "full"
local linespace             = 0

local set_font_size = function(value)
    font_size = value
    vim.o.guifont = font .. ':h' .. font_size .. ':#e-' .. font_aliasing .. ':#h-' .. font_hinting
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
    vim.cmd("bprev")
    vim.api.nvim_buf_delete(bufnr, { force = true })
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

vim.o.termguicolors  = true
vim.o.number         = false
vim.o.relativenumber = false
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
vim.o.linespace      = 0
vim.o.wrap           = false
vim.o.wildignore     = "*/build*/*,*/.*/*"
vim.o.fileformat     = "dos"
vim.o.guicursor      = "a:blinkon0-block-Cursor/lCursor"
vim.o.background     = "dark"
vim.o.linespace      = linespace
vim.o.showcmd        = false
vim.opt.fillchars    = { eob = " " }
vim.opt.statusline   = " %= -- %t (%l/%L) -- %="

vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function()
    -- Use vim.wo for window-local option
    vim.wo.statusline = " %= -- %t (%l/%L) -- %="
  end,
})

if vim.fn.executable('rg') == 1 then
  vim.opt.grepprg = "rg --vimgrep --smart-case"
  vim.opt.grepformat = "%f:%l:%c:%m"
end

set_font_size(default_font_size)

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
    vim.g.neovide_window_blurred                = false
    vim.g.neovide_theme                         = "bg_color"
    vim.g.neovide_position_animation_length     = 0.1
    vim.g.neovide_scroll_animation_length       = 0.1
    vim.g.neovide_cursor_animation_length       = 0.015
    vim.g.neovide_cursor_short_animation_length = 0.015
    vim.g.neovide_cursor_trail_size             = 0.0
    vim.g.neovide_fullscreen                    = false
    vim.g.neovide_opacity                       = 1.0
    vim.g.neovide_normal_opacity                = 1.0
    vim.g.neovide_scale_factor                  = 1.0
    vim.g.neovide_text_gamma                    = 1.75
    vim.g.neovide_text_contrast                 = 1.0

    vim.g.neovide_title_background_color        = string.format(
        "%x",
        vim.api.nvim_get_hl(0, {id=vim.api.nvim_get_hl_id_by_name("Normal")}).bg
    )

    vim.g.neovide_title_text_color              = string.format(
        "%x",
        vim.api.nvim_get_hl(0, {id=vim.api.nvim_get_hl_id_by_name("Normal")}).fg
    )

    vim.api.nvim_set_keymap('', '<F11>', '', {
        noremap = true,
        callback = function()
            vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
        end
    })
end

vim.api.nvim_create_user_command('Pushd',   function (opts) pushd(opts.args) end,  { nargs = 1, complete = "dir" })
vim.api.nvim_create_user_command('Popd',    popd,           { nargs = 0 })
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight yanked text.',
    group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end
})

vim.api.nvim_set_keymap('', '<C-,>',      '<cmd>bp<CR>', { noremap = true })
vim.api.nvim_set_keymap('', '<C-.>',      '<cmd>bn<CR>', { noremap = true })
vim.api.nvim_set_keymap('', '<C-k>',      '',            { noremap = true, callback = kill_current_buffer })

if use_package_manager then
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
        end
    end
    vim.opt.rtp:prepend(lazypath)

    require("lazy").setup({
        { 
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
            end,
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
                    ensure_installed = { "c", "cpp", "rust", "lua" },
                    sync_install = false,
                    highlight = { enable = true },
                    indent = { enable = true },
                })
            end,
        },

        {
            'ej-shafran/compile-mode.nvim',
            branch = "latest",
            dependencies = {
                'nvim-lua/plenary.nvim',
                { "m00qek/baleia.nvim", tag = "v1.3.0" },
            },
            config = function()
                vim.g.compile_mode = {
                    default_command = "",
                    buffer_name = "compilation",
                    baleia_setup = true,
                    input_word_completion = true,
                    focus_compilation_buffer = true,
                }

                vim.api.nvim_set_keymap('', '<F5>',   ':Compile<CR>',   { noremap = true })
                vim.api.nvim_set_keymap('', '<S-F5>', ':Recompile<CR>', { noremap = true })
            end,
        },
    })
end

vim.cmd("colorscheme " .. colorscheme)
