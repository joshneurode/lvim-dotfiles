-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny
lvim.format_on_save = true
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  { exe = "isort", filetypes = { "python" }, args = { "--profile", "black" } },
  { exe = "black", filetypes = { "python" } },
}

lvim.keys.normal_mode["|"] = ":vsplit<CR>"
lvim.keys.normal_mode["-"] = ":split<CR>"
lvim.keys.term_mode["<C-`>"] = "<C-\\><C-n>"

lvim.plugins = {
  "ChristianChiarulli/swenv.nvim",
  "stevearc/dressing.nvim",
  "hrsh7th/nvim-cmp",
  { "folke/neodev.nvim", opts = {} },
  "nvim-telescope/telescope-live-grep-args.nvim",
  {
    "supermaven-inc/supermaven-nvim",
    config = function()
      require("supermaven-nvim").setup({})
    end,
  },
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false, -- set this if you want to always pull the latest change
    opts = {
      -- add any opts here
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
  {
    "anuvyklack/hydra.nvim",
    lazy = false,
    config = function()
      local Hydra = require("hydra")
      -- Window navigation
      Hydra({
        name = "Win move",
        mode = "n",
        body = "<leader>W",
        heads = {
          { "h", "<C-w>h" }, { "j", "<C-w>j" }, { "k", "<C-w>k" }, { "l", "<C-w>l" },
          { "q", nil,     { exit = true } },
        }
      })
      -- Window resize: press <leader>R then h/j/k/l to resize, q to exit
      Hydra({
        name = "Win resize",
        mode = "n",
        body = "<leader>R",
        heads = {
          { "h",     "<cmd>vertical resize -2<CR>" },
          { "l",     "<cmd>vertical resize +2<CR>" },
          { "j",     "<cmd>resize -2<CR>" },
          { "k",     "<cmd>resize +2<CR>" },
          { "q",     nil,                          { exit = true } },
          { "<Esc>", nil,                          { exit = true } },
        }
      })
    end,
  },
  {
    "mg979/vim-visual-multi",
    branch = "master",
    init = function()
      -- Optional: make the keys explicit
      vim.g.VM_default_mappings = 0
      vim.g.VM_maps = {
        ["Find Under"]         = "<C-n>",     -- add next occurrence
        ["Find Subword Under"] = "<C-n>",
        ["Select All"]         = "<leader>a", -- select all occurrences
        ["Skip Region"]        = "<C-x>",     -- skip current
        ["Remove Region"]      = "<C-p>",     -- remove current cursor
        ["Add Cursor Down"]    = "<C-Down>",
        ["Add Cursor Up"]      = "<C-Up>",
      }
    end,
  }
}

lvim.builtin.which_key.mappings["C"] = {
  name = "Python",
  c = { "<cmd>lua require('swenv.api').pick_venv()<cr>", "Choose Env" },
}

lvim.builtin.which_key.mappings.s.t = {
  require('telescope').extensions.live_grep_args.live_grep_args, "Live grep args",
}
-- Show previewer when searching git files with default <leader>f
lvim.builtin.which_key.mappings["f"] = {
  require("lvim.core.telescope.custom-finders").find_project_files,
  "Find File"
}
-- Show previewer when searching buffers with <leader>bf
lvim.builtin.which_key.mappings.b.f = {
  "<cmd>Telescope buffers<cr>",
  "Find"
}

lvim.keys.insert_mode["<C-Space>"] = function()
  require('cmp').complete()
end
lvim.lsp.automatic_configuration.skipped_servers = vim.tbl_filter(function(server)
  return server ~= "pyright"
end, lvim.lsp.automatic_configuration.skipped_servers)

-- Enable the taplo LSP server for TOML (provides formatting itself).
-- NOTE: taplo is not a null-ls/none-ls formatter source, so registering it via
-- formatters.setup() throws "Not a valid source: taplo". TOML formatting comes
-- from the taplo LSP below instead. Install the server with `:LspInstall taplo`.
lvim.lsp.automatic_configuration.skipped_servers = vim.tbl_filter(function(server)
  return server ~= "taplo"
end, lvim.lsp.automatic_configuration.skipped_servers)

-- vim.opt.shell = "/opt/homebrew/bin/fish"

vim.keymap.set({ 'n', 't' }, '<C-1>', '<cmd>1ToggleTerm direction=float<CR>', { silent = true })
vim.keymap.set({ 'n', 't' }, '<C-2>', '<cmd>2ToggleTerm direction=horizontal<CR>', { silent = true })

-- :Claude (and :claude via cabbrev) opens a terminal running `claude`
vim.api.nvim_create_user_command("Claude", function()
  vim.cmd("terminal claude --dangerously-skip-permissions")
  vim.cmd("startinsert")
end, {})
vim.cmd([[cnoreabbrev <expr> claude (getcmdtype() == ':' && getcmdline() ==# 'claude') ? 'Claude' : 'claude']])



-- Auto-reload files that change on disk
vim.opt.autoread = true

local grp = vim.api.nvim_create_augroup("AutoReloadOnExternalChange", { clear = true })

-- Re-check timestamps when you come back to Neovim or linger in a buffer
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = grp,
  command = "checktime",
})

-- Friendly notification after a successful auto-reload
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = grp,
  callback = function(ev)
    local msg = "Auto-reloaded: " .. vim.fn.fnamemodify(ev.file or "", ":.")
    local ok, notify = pcall(require, "notify")
    if ok then
      notify(msg, vim.log.levels.INFO, { title = "LunarVim" })
    else
      vim.api.nvim_echo({ { msg, "ModeMsg" } }, false, {})
    end
  end,
})


-- Compat shim for the nvim-treesitter version LunarVim pins (May 2024).
-- Its query predicates/directives assume `match[capture_id]` is a single TSNode,
-- but Neovim 0.11+ always hands them a list of nodes and 0.12 removed the
-- `all = false` opt-out upstream relied on. Markdown is the loudest victim: the
-- `set-lang-from-info-string!` directive used for fenced-code-block injections
-- dies with "attempt to call method 'range' (a nil value)", breaking treesitter
-- highlighting and indent-blankline. Re-register nvim-treesitter's handlers,
-- wrapped so each one sees a single node per capture again.
local function patch_treesitter_predicates()
  local ok, ts_query = pcall(require, "vim.treesitter.query")
  if not ok then
    return
  end

  local function with_single_nodes(handler)
    return function(match, pattern, source, pred, metadata)
      local flattened = {}
      for id, nodes in pairs(match) do
        flattened[id] = type(nodes) == "table" and nodes[#nodes] or nodes
      end
      return handler(flattened, pattern, source, pred, metadata)
    end
  end

  local add_predicate, add_directive = ts_query.add_predicate, ts_query.add_directive
  ts_query.add_predicate = function(name, handler)
    return add_predicate(name, with_single_nodes(handler), { force = true })
  end
  ts_query.add_directive = function(name, handler)
    return add_directive(name, with_single_nodes(handler), { force = true })
  end

  package.loaded["nvim-treesitter.query_predicates"] = nil
  local reloaded, err = pcall(require, "nvim-treesitter.query_predicates")

  ts_query.add_predicate, ts_query.add_directive = add_predicate, add_directive

  if not reloaded then
    vim.notify("Could not patch nvim-treesitter query predicates: " .. tostring(err), vim.log.levels.WARN)
  end
end

if package.loaded["nvim-treesitter.query_predicates"] then
  patch_treesitter_predicates()
end

vim.api.nvim_create_autocmd("User", {
  pattern = "LazyLoad",
  callback = function(ev)
    if ev.data == "nvim-treesitter" then
      patch_treesitter_predicates()
    end
  end,
})


-- lvim.builtin.lualine.sections.lualine_c = {
--   {
--     'filename',
--     path = 1, -- 0 = just filename, 1 = relative path, 2 = absolute path
--     file_status = true,
--     newfile_status = true,
--     shorting_target = 40,
--   }
-- }

-- local fmt_group = vim.api.nvim_create_augroup("LvimFormat", { clear = true })

-- vim.api.nvim_create_autocmd("BufWritePre", {
--   group = fmt_group,
--   callback = function()
--     local buf_name = vim.api.nvim_buf_get_name(0)
--     local dir_to_exclude = vim.fn.expand("~/Code/vllm")

--     if not string.find(buf_name, dir_to_exclude) then
--       if vim.fn.exists(":LspFormatting") == 2 then
--         vim.cmd("LspFormatting")
--       elseif vim.fn.exists(":Format") == 2 then
--         vim.cmd("Format")
--       end
--     end
--   end,
-- })

-- -- Disable LunarVim's built-in format-on-save
-- lvim.format_on_save = false
