local present, lazy = pcall(require, "lazy")

if not present then
  return
end

local event = {"BufRead", "BufWinEnter", "BufNewFile"}

lazy.setup {
  "lewis6991/impatient.nvim",
  "nvim-lua/plenary.nvim",
  {
    "folke/todo-comments.nvim",
    config = function()
      require("todo-comments").setup {}
    end
  },
  {
    "phaazon/hop.nvim",
    config = function()
      require("hop").setup {}
    end
  },
  {
    "williamboman/mason.nvim",
    cmd = {
      "Mason",
      "MasonInstall",
      "MasonInstallAll",
      "MasonUninstall",
      "MasonUninstallAll",
      "MasonLog"
    },
    config = function()
      options = {
        ensure_installed = {
          -- lua stuff
          "lua-language-server",
          "stylua",
          -- web dev
          "css-lsp",
          "html-lsp",
          "typescript-language-server",
          "rescript-lsp",
          "json-lsp",
          "yaml-language-server",
          -- shell
          "shfmt",
          "shellcheck",
          "solargraph",
          "clangd"
        },
        PATH = "skip",
        ui = {
          icons = {
            package_pending = " ",
            package_installed = " ",
            package_uninstalled = " ﮊ"
          },
          keymaps = {
            toggle_server_expand = "<CR>",
            install_server = "i",
            update_server = "u",
            check_server_version = "c",
            update_all_servers = "U",
            check_outdated_servers = "C",
            uninstall_server = "X",
            cancel_installation = "<C-c>"
          }
        },
        max_concurrent_installers = 10
      }
      require("mason").setup(options)

      vim.api.nvim_create_user_command(
        "MasonInstallAll",
        function()
          vim.cmd("MasonInstall " .. table.concat(options.ensure_installed, " "))
        end,
        {}
      )
    end
  },
  {
    "goolord/alpha-nvim",
    config = function()
      -- local header = {
      --   [[                                       .::.                                  ]],
      --   [[                                     .;:**'            AMC                   ]],
      --   [[                                     `                  0                    ]],
      --   [[         .:XHHHHk.              db.   .;;.     dH  MX   0                    ]],
      --   [[       oMMMMMMMMMMM       ~MM  dMMP :MMMMMR   MMM  MR      ~MRMN             ]],
      --   [[       QMMMMMb  "MMX       MMMMMMP !MX' :M~   MMM MMM  .oo. XMMM 'MMM        ]],
      --   [[         `MMMM.  )M> :X!Hk. MMMM   XMM.o"  .  MMMMMMM X?XMMM MMM>!MMP        ]],
      --   [[          'MMMb.dM! XM M'?M MMMMMX.`MMMMMMMM~ MM MMM XM `" MX MMXXMM         ]],
      --   [[           ~MMMMM~ XMM. .XM XM`"MMMb.~*?**~ .MMX M t MMbooMM XMMMMMP         ]],
      --   [[            ?MMM>  YMMMMMM! MM   `?MMRb.    `"""   !L"MMMMM XM IMMM          ]],
      --   [[             MMMX   "MMMM"  MM       ~%:           !Mh.""" dMI IMMP          ]],
      --   [[             'MMM.                                             IMX           ]],
      --   [[              ~M!M                                             IMP           ]],
      --   [[                                                                             ]],
      --   [[                                                                             ]],
      --   [[                    ."-,.__                                                  ]],
      --   [[                    `.     `.  ,                                             ]],
      --   [[                 .--'  .._,'"-' `.                                           ]],
      --   [[                .    .'         `'                                           ]],
      --   [[                `.   /          ,'                                           ]],
      --   [[                  `  '--.   ,-"'                                             ]],
      --   [[                   `"`   |  \                                                ]],
      --   [[                      -. \, |                                                ]],
      --   [[                       `--Y.'      ___.                                      ]],
      --   [[                            \     L._, \                                     ]],
      --   [[                  _.,        `.   <  <\                _                     ]],
      --   [[                ,' '           `, `.   | \            ( `                    ]],
      --   [[             ../, `.            `  |    .\`.           \ \_                  ]],
      --   [[            ,' ,..  .           _.,'    ||\l            )  '".               ]],
      --   [[           , ,'   \           ,'.-.`-._,'  |           .  _._`.              ]],
      --   [[         ,' /      \ \        `' ' `--/   | \          / /   ..\             ]],
      --   [[       .'  /        \ .         |\__ - _ ,'` `        / /     `.`.           ]],
      --   [[       |  '          ..         `-...-"  |  `-'      / /        . `.         ]],
      --   [[       | /           |L__           |    |          / /          `. `.       ]],
      --   [[      , /            .   .          |    |         / /             ` `       ]],
      --   [[     / /          ,. ,`._ `-_       |    |  _   ,-' /               ` \      ]],
      --   [[    / .           \"`_/. `-_ \_,.  ,'    +-' `-'  _,        ..,-.    \`.     ]],
      --   [[   .  '         .-f    ,'   `    '.       \__.---'     _   .'   '     \ \    ]],
      --   [[   ' /          `.'    l     .' /          \..      ,_|/   `.  ,'`     L`    ]],
      --   [[   |'      _.-""` `.    \ _,'  `            \ `.___`.'"`-.  , |   |    | \   ]],
      --   [[   ||    ,'      `. `.   '       _,...._        `  |    `/ '  |   '     .|   ]],
      --   [[   ||  ,'          `. ;.,.---' ,'       `.   `.. `-'  .-' /_ .'    ;_   ||   ]],
      --   [[   || '              V      / /           `   | `   ,'   ,' '.    !  `. ||   ]],
      --   [[   ||/            _,-------7 '              . |  `-'    l         /    `||   ]],
      --   [[   . |          ,' .-   ,' ||               | .-.        `.      .'     ||   ]],
      --   [[    `'        ,'    `".'    |               |    `.        '. -.'       `'   ]],
      --   [[             /      ,'      |               |,'    \-.._,.'/'                ]],
      --   [[             .     /        .               .       \    .''                 ]],
      --   [[           .`.    |         `.             /         :_,'.'                  ]],
      --   [[             \ `...\   _     ,'-.        .'         /_.-'                    ]],
      --   [[              `-.__ `,  `'   .  _.>----''.  _  __  /                         ]],
      --   [[                   .'        /"'          |  "'   '_                         ]],
      --   [[                  /_|.-'\ ,".             '.'`__'-( \                        ]],
      --   [[                    / ,"'"\,'               `/  `-.|"                        ]],
      --   [[ ]]
      -- }

      -- local header = {
      --   [[                                   .::.                               ]],
      --   [[                                 .;:**'            AMC                ]],
      --   [[                                 `                  0                 ]],
      --   [[     .:XHHHHk.              db.   .;;.     dH  MX   0                 ]],
      --   [[   oMMMMMMMMMMM       ~MM  dMMP :MMMMMR   MMM  MR      ~MRMN          ]],
      --   [[   QMMMMMb  "MMX       MMMMMMP !MX' :M~   MMM MMM  .oo. XMMM 'MMM     ]],
      --   [[     `MMMM.  )M> :X!Hk. MMMM   XMM.o"  .  MMMMMMM X?XMMM MMM>!MMP     ]],
      --   [[      'MMMb.dM! XM M'?M MMMMMX.`MMMMMMMM~ MM MMM XM `" MX MMXXMM      ]],
      --   [[       ~MMMMM~ XMM. .XM XM`"MMMb.~*?**~ .MMX M t MMbooMM XMMMMMP      ]],
      --   [[        ?MMM>  YMMMMMM! MM   `?MMRb.    `"""   !L"MMMMM XM IMMM       ]],
      --   [[         MMMX   "MMMM"  MM       ~%:           !Mh.""" dMI IMMP       ]],
      --   [[         'MMM.                                             IMX        ]],
      --   [[          ~M!M                                             IMP        ]],
      --   [[                                                                      ]],
      --   [[                                                                      ]],
      --   [[                                                   /                  ]],
      --   [[                              _,.------....___,.' ',.-.               ]],
      --   [[                           ,-'          _,.--"        |               ]],
      --   [[                         ,'         _.-'              .               ]],
      --   [[                        /   ,     ,'                   `              ]],
      --   [[                       .   /     /                     ``.            ]],
      --   [[                       |  |     .                       \.\           ]],
      --   [[             ____      |___._.  |       __               \ `.         ]],
      --   [[           .'    `---""       ``"-.--"'`  \               .  \        ]],
      --   [[          .  ,            __               `              |   .       ]],
      --   [[          `,'         ,-"'  .               \             |    L      ]],
      --   [[         ,'          '    _.'                -._          /    |      ]],
      --   [[        ,`-.    ,".   `--'                      >.      ,'     |      ]],
      --   [[       . .'\'   `-'       __    ,  ,-.         /  `.__.-      ,'      ]],
      --   [[       ||:, .           ,'  ;  /  / \ `        `.    .      .'/       ]],
      --   [[       j|:D  \          `--'  ' ,'_  . .         `.__, \   , /        ]],
      --   [[      / L:_  |                 .  "' :_;                `.'.'         ]],
      --   [[      .    ""'                  """""'                    V           ]],
      --   [[       `.                                 .    `.   _,..  `           ]],
      --   [[         `,_   .    .                _,-'/    .. `,'   __  `          ]],
      --   [[          ) \`._        ___....----"'  ,'   .'  \ |   '  \  .         ]],
      --   [[         /   `. "`-.--"'         _,' ,'     `---' |    `./  |         ]],
      --   [[        .   _  `""'--.._____..--"   ,             '         |         ]],
      --   [[        | ." `. `-.                /-.           /          ,         ]],
      --   [[        | `._.'    `,_            ;  /         ,'          .          ]],
      --   [[       .'          /| `-.        . ,'         ,           ,           ]],
      --   [[       '-.__ __ _,','    '`-..___;-...__   ,.'\ ____.___.'            ]],
      --   [[       `"^--'..'   '-`-^-'"--    `-^-'`.''"""""`.,^.`.--'             ]],
      --   [[ ]]
      -- }

      local header = {
        [[                                                                              ]],
        [[                                    ██████                                    ]],
        [[                                ████▒▒▒▒▒▒████                                ]],
        [[                              ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒██                              ]],
        [[                            ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██                            ]],
        [[                          ██▒▒▒▒▒▒▒▒    ▒▒▒▒▒▒▒▒                              ]],
        [[                          ██▒▒▒▒▒▒  ▒▒▓▓▒▒▒▒▒▒  ▓▓▓▓                          ]],
        [[                          ██▒▒▒▒▒▒  ▒▒▓▓▒▒▒▒▒▒  ▒▒▓▓                          ]],
        [[                        ██▒▒▒▒▒▒▒▒▒▒    ▒▒▒▒▒▒▒▒    ██                        ]],
        [[                        ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██                        ]],
        [[                        ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██                        ]],
        [[                        ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██                        ]],
        [[                        ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██                        ]],
        [[                        ██▒▒██▒▒▒▒▒▒██▒▒▒▒▒▒▒▒██▒▒▒▒██                        ]],
        [[                        ████  ██▒▒██  ██▒▒▒▒██  ██▒▒██                        ]],
        [[                        ██      ██      ████      ████                        ]],
        [[                                                                              ]],
        [[                                                                              ]]
      }

      local make_header = function()
        local lines = {}
        for i, line_chars in pairs(header) do
          local hi = i > 15 and "Bulbasaur" .. (i - 15) or "PokemonLogo" .. i
          local line = {
            type = "text",
            val = line_chars,
            opts = {
              hl = "AlphaSpecialKey" .. i,
              shrink_margin = false,
              position = "center"
            }
          }
          table.insert(lines, line)
        end

        local output = {
          type = "group",
          val = lines,
          opts = {position = "center"}
        }

        return output
      end

      local margin_fix = vim.fn.floor(vim.fn.winwidth(0) / 2 - 46 / 2)

      local button = function(sc, txt, keybind, padding)
        local sc_ = sc:gsub("%s", ""):gsub("SPC", "<leader>")
        local text = padding and (" "):rep(padding) .. txt or txt

        local offset = padding and padding + 3 or 3

        local opts = {
          width = 46,
          shortcut = sc,
          cursor = -1,
          align_shortcut = "right",
          hl_shortcut = "AlphaButtonShortcut",
          hl = {
            {"AlphaButtonIcon", 0, margin_fix + offset},
            {
              "AlphaButton",
              offset,
              #text
            }
          }
        }

        if keybind then
          opts.keymap = {"n", sc_, keybind, {noremap = true, silent = true}}
        end

        return {
          type = "button",
          val = text,
          on_press = function()
            local key = vim.api.nvim_replace_termcodes(sc_, true, false, true)
            vim.api.nvim_feedkeys(key, "normal", false)
          end,
          opts = opts
        }
      end

      local thingy = io.popen('echo "$(date +%a) $(date +%d) $(date +%b)" | tr -d "\n"')
      local date = thingy:read("*a")
      thingy:close()

      local heading = {
        type = "text",
        val = "· Today is " .. date .. " ·",
        opts = {
          position = "center",
          hl = "Folded"
        }
      }

      local alpha = require("alpha")
      require("alpha.term")

      local terminal = {
        type = "terminal",
        command = " /Users/mobily/.config/nvim/lua/lazy/thisisfine.sh",
        width = 46,
        height = 25,
        opts = {
          redraw = true,
          window_config = {}
        }
      }

      local section = {
        header = make_header(),
        heading = heading,
        terminal = terminal,
        buttons = {
          type = "group",
          val = {
            button("p", "ﱮ  Restore Session", ":WorkspacesOpen<CR>"),
            -- button("1", "﬌  Blocks", ":WorkspacesOpen blocks<CR>", 3),
            -- button("2", "﬌  Localized", ":WorkspacesOpen localized<CR>", 3),
            -- button("3", "﬌  ts-belt", ":WorkspacesOpen ts-belt<CR>", 3),
            -- button("4", "﬌  stacks", ":WorkspacesOpen stacks<CR>", 3),
            -- button("5", "﬌  Archeeve", ":WorkspacesOpen archeeve<CR>", 3),
            -- button("גּ b", "  File Browser", ":Telescope file_browser<CR>"),
            -- button("גּ p", "  Find File", ":Telescope find_files<CR>"),
            button("f", "  Recent Files", ":Telescope oldfiles<CR>"),
            button("u", "  Update Plugins", ":Lazy update<CR>"),
            button("q", "  Quit", ":qa<CR>")
          },
          opts = {
            spacing = 1
          }
        }
      }

      local marginTopPercent = 0.225
      local headerPadding = vim.fn.max {4, vim.fn.floor(vim.fn.winheight(0) * marginTopPercent)}

      local padding = function(value)
        return {type = "padding", val = value}
      end

      local config = {
        layout = {
          padding(headerPadding),
          section.terminal,
          padding(4),
          section.heading,
          padding(2),
          section.buttons
        },
        opts = {
          margin = margin_fix
        }
      }

      alpha.setup(config)

      -- vim.api.nvim_create_autocmd(
      --   "WinResized",
      --   {
      --     group = "alpha",
      --     callback = function()
      --       alpha.redraw()
      --     end
      --   }
      -- )

      -- disable statusline in dashboard
      vim.api.nvim_create_autocmd(
        "FileType",
        {
          pattern = "alpha",
          callback = function()
            local old_laststatus = vim.opt.laststatus

            vim.api.nvim_create_autocmd(
              "BufUnload",
              {
                buffer = 0,
                callback = function()
                  vim.opt.laststatus = old_laststatus
                end
              }
            )

            vim.opt.laststatus = 0
          end
        }
      )
    end
  },
  {
    "dnlhc/glance.nvim",
    cmd = {"Glance"},
    config = function()
      local actions = require("glance").actions

      require("glance").setup {
        height = 20,
        border = {
          enable = true,
          top_char = "─",
          bottom_char = "─"
        },
        list = {
          position = "right", -- Position of the list window 'left'|'right'
          width = 0.33 -- 33% width relative to the active window, min 0.1, max 0.5
        },
        theme = {
          enable = true, -- Will generate colors for the plugin based on your current colorscheme
          mode = "auto" -- 'brighten'|'darken'|'auto', 'auto' will set mode based on the brightness of your colorscheme
        },
        mappings = {
          list = {
            ["j"] = actions.next,
            ["k"] = actions.previous,
            ["<Down>"] = actions.next,
            ["<Up>"] = actions.previous,
            ["<Tab>"] = actions.next_location,
            ["<S-Tab>"] = actions.previous_location,
            ["<C-u>"] = actions.preview_scroll_win(5),
            ["<C-d>"] = actions.preview_scroll_win(-5),
            ["v"] = actions.jump_vsplit,
            ["s"] = actions.jump_split,
            ["t"] = actions.jump_tab,
            ["<CR>"] = actions.jump,
            ["o"] = actions.jump,
            ["<D-Left>"] = actions.enter_win("preview"),
            ["q"] = actions.close,
            ["Q"] = actions.close,
            ["<Esc>"] = actions.close
          },
          preview = {
            ["Q"] = actions.close,
            ["<Tab>"] = actions.next_location,
            ["<S-Tab>"] = actions.previous_location,
            ["<D-Right>"] = actions.enter_win("list")
          }
        },
        hooks = {},
        folds = {
          -- fold_closed = "",
          -- fold_open = "",
          fold_closed = "·",
          fold_open = "+",
          folded = false
        },
        indent_lines = {
          enable = true,
          icon = "│"
        },
        winbar = {
          enable = true
        }
      }
    end
  },
  {
    "chentoast/marks.nvim",
    event = event,
    lazy = true,
    config = function()
      require("marks").setup {
        default_mappings = true,
        builtin_marks = {},
        cyclic = true,
        force_write_shada = true,
        refresh_interval = 250,
        sign_priority = {lower = 10, upper = 15, builtin = 8, bookmark = 20},
        excluded_filetypes = {},
        bookmark_1 = {
          sign = "", -- bookmark
          virt_text = "",
          annotate = false
        },
        bookmark_2 = {
          sign = "", -- heart
          virt_text = "",
          annotate = false
        },
        mappings = {
          set = "m",
          set_next = "m,",
          toggle = "mm",
          next = "<M-]>",
          prev = "<M-[>",
          preview = "m:",
          next_bookmark = "<C-]>",
          prev_bookmark = "<C-[>",
          delete = "dm",
          delete_line = "dm-",
          delete_bookmark = "d<BS>",
          delete_buf = "<leader>d"
        }
      }
    end
  },
  {
    "kyazdani42/nvim-tree.lua",
    cmd = {
      "NvimTreeToggle",
      "NvimTreeOpen",
      "NvimTreeFocus"
    },
    config = function()
      local utils = require "utils"
      local map = utils.keymap_factory("n")

      require("nvim-tree").setup {
        filters = {
          dotfiles = false,
          custom = {"^.git$", "^.DS_store$"}
        },
        live_filter = {
          always_show_folders = false
        },
        disable_netrw = true,
        hijack_netrw = true,
        -- INFO: deprecated
        -- open_on_setup = false,
        -- ignore_ft_on_setup = {"alpha"},
        hijack_cursor = true,
        hijack_unnamed_buffer_when_opening = false,
        update_cwd = true,
        update_focused_file = {
          enable = true,
          update_root = false
        },
        view = {
          adaptive_size = false,
          centralize_selection = false,
          preserve_window_proportions = true,
          side = "right",
          width = 38
        },
        git = {
          enable = true,
          ignore = false,
          show_on_dirs = true,
          timeout = 400
        },
        filesystem_watchers = {
          enable = true,
          ignore_dirs = {
            "node_modules",
            ".git"
          }
        },
        actions = {
          open_file = {
            resize_window = true
          },
          expand_all = {
            exclude = {
              ".mind",
              ".git",
              "node_modules",
              "dist",
              "build",
              ".png-cache",
              ".cache",
              "assets"
            }
          }
        },
        renderer = {
          highlight_git = true,
          root_folder_label = false,
          highlight_opened_files = "name",
          indent_markers = {
            enable = true
          },
          special_files = {"package.json", "README.md", "readme.md"},
          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = false
            },
            glyphs = {
              default = "",
              symlink = "",
              folder = {
                default = "",
                empty = "",
                empty_open = "",
                open = "",
                symlink = "",
                symlink_open = "",
                arrow_open = "+",
                arrow_closed = "·"
              },
              git = {
                unstaged = "✗",
                staged = "✓",
                unmerged = "",
                renamed = "➜",
                untracked = "★",
                deleted = "",
                ignored = "◌"
              }
            }
          }
        },
        on_attach = function(tree_buffer)
          local api = require "nvim-tree.api"
          local actions = require("pickers.nvim-tree").actions
          local inject = require("nvim-tree.utils").inject_node

          api.config.mappings.default_on_attach(tree_buffer)

          for _, action in pairs(actions) do
            if action.plugin_keymap then
              map(action.plugin_keymap, inject(action.handler), nil, {buffer = tree_buffer})
            end
          end
        end
      }
    end
  },
  {
    "natecraddock/workspaces.nvim",
    cmd = {"WorkspacesOpen", "WorkspacesAdd"},
    config = function()
      require("workspaces").setup {
        path = vim.fn.stdpath("data") .. "/workspaces",
        hooks = {
          open = {
            "BWipeout all",
            "SessionRestore"
          }
        }
      }
    end
  },
  {
    "rmagatti/auto-session",
    cmd = {"SessionRestore", "SessionSave"},
    config = function()
      require("auto-session").setup {
        log_level = "error",
        auto_session_allowed_dirs = {"~/Projects/*"},
        auto_session_suppress_dirs = {"/", "~/", "~/Projects"},
        pre_save_cmds = {"NvimTreeClose", "MindClose"},
        post_save_cmds = {"NvimTreeOpen"},
        post_restore_cmds = {"NvimTreeOpen"},
        auto_session_create_enabled = false
      }
    end
  },
  {
    "kazhala/close-buffers.nvim",
    cmd = {"BWipeout"}
  },
  {
    "stevearc/dressing.nvim",
    -- event = "VeryLazy",
    config = function()
      require("dressing").setup {
        input = {
          enabled = true,
          relative = "cursor",
          start_in_insert = true,
          insert_only = true,
          win_options = {
            winblend = 0
          }
        },
        select = {
          enabled = true,
          backend = {"telescope"},
          get_config = function(opts)
            if opts.kind == "codeaction" then
              return {
                backend = {"telescope"},
                telescope = require("telescope.themes").get_cursor()
              }
            end
          end
          -- require("telescope.themes").get_dropdown({})
          -- telescope = {}
        }
      }
    end
  },
  {
    "nvim-telescope/telescope.nvim",
    -- cmd = {"Telescope"},
    lazy = true,
    event = event,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "debugloop/telescope-undo.nvim"
    },
    config = function()
      vim.g.theme_switcher_loaded = true

      local previewers = require("telescope.previewers")
      local sorters = require("telescope.sorters")
      local actions = require("telescope.actions")

      local extensions_list = {
        "undo",
        "themes",
        "terms",
        "file_browser"
      }

      require("telescope").setup {
        defaults = {
          vimgrep_arguments = {
            "rg",
            "-L",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case"
          },
          prompt_prefix = "   ",
          selection_caret = "  ",
          entry_prefix = "  ",
          initial_mode = "insert",
          selection_strategy = "reset",
          sorting_strategy = "ascending",
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
              results_width = 0.8
            },
            vertical = {
              mirror = false
            },
            width = 0.8,
            height = 0.65,
            preview_cutoff = 120
          },
          file_sorter = sorters.get_fuzzy_file,
          file_ignore_patterns = {
            "node_modules",
            ".git"
          },
          generic_sorter = sorters.get_generic_fuzzy_sorter,
          path_display = {"truncate"},
          winblend = 0,
          border = {},
          borderchars = {"─", "│", "─", "│", "╭", "╮", "╯", "╰"},
          color_devicons = true,
          set_env = {
            ["COLORTERM"] = "truecolor"
          },
          file_previewer = previewers.vim_buffer_cat.new,
          grep_previewer = previewers.vim_buffer_vimgrep.new,
          qflist_previewer = previewers.vim_buffer_qflist.new,
          buffer_previewer_maker = previewers.buffer_previewer_maker,
          mappings = {
            n = {
              ["q"] = actions.close
            }
          },
          cache_picker = {
            num_pickers = 50
          },
          extensions = {
            undo = {
              side_by_side = true,
              use_delta = false
            }
          }
        }
      }

      pcall(
        function()
          for _, ext in ipairs(extensions_list) do
            telescope.load_extension(ext)
          end
        end
      )
    end
  },
  {
    "NvChad/nvim-colorizer.lua",
    lazy = true,
    event = event,
    config = function()
      require("colorizer").setup {
        filetypes = {
          "*"
        },
        user_default_options = {
          RGB = true, -- #RGB hex codes
          RRGGBB = true, -- #RRGGBB hex codes
          names = true, -- "Name" codes like Blue
          RRGGBBAA = true, -- #RRGGBBAA hex codes
          rgb_fn = true, -- CSS rgb() and rgba() functions
          hsl_fn = true, -- CSS hsl() and hsla() functions
          css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
          css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
          mode = "background" -- Set the display mode.
        }
      }

      -- execute colorizer as soon as possible
      vim.defer_fn(
        function()
          require("colorizer").attach_to_buffer(0)
        end,
        0
      )
    end
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    lazy = true,
    config = function()
      require("indent_blankline").setup {
        indentLine_enabled = 1,
        filetype_exclude = {
          "help",
          "terminal",
          "alpha",
          "packer",
          "lspinfo",
          "TelescopePrompt",
          "TelescopeResults",
          "mason",
          ""
        },
        buftype_exclude = {"terminal"},
        show_trailing_blankline_indent = false,
        show_first_indent_level = false,
        show_current_context = true,
        show_current_context_start = true
      }
    end
  },
  {
    "kyazdani42/nvim-web-devicons",
    config = function()
      local icons = require("ui.icons")

      require("nvim-web-devicons").setup {
        override = icons.dev
      }
    end
  },
  -- {
  --   "utilyre/barbecue.nvim",
  --   dependencies = {
  --     -- "neovim/nvim-lspconfig",
  --     "smiteshp/nvim-navic"
  --     -- "kyazdani42/nvim-web-devicons"
  --   },
  --   config = function()
  --     local colors = require "ui.colors"

  --     require("barbecue").setup {
  --       symbols = {
  --         modified = "●",
  --         ellipsis = "…",
  --         separator = "·"
  --       },
  --       theme = {
  --         separator = {
  --           fg = colors.dark["300"]
  --         },
  --         dirname = {
  --           fg = colors.dark["300"]
  --         },
  --         context = {
  --           fg = colors.primary["300"]
  --         },
  --         basename = {
  --           fg = colors.dark["300"]
  --         }
  --       }
  --     }
  --   end
  -- },
  {
    "akinsho/bufferline.nvim",
    version = "v3.*",
    event = event,
    lazy = true,
    -- dependencies = {"nvim-tree/nvim-web-devicons"},
    config = function()
      local icons = require("ui.icons")
      local buffers = require("utils.buffers")

      local status = icons.status

      require("bufferline").setup {
        options = {
          diagnostics = "nvim_lsp",
          highlights = {},
          offsets = {
            {filetype = "NvimTree", text = "Explorer", padding = 1}
          },
          show_buffer_close_icons = false,
          modified_icon = "",
          close_command = buffers.close_buffer,
          right_mouse_command = buffers.close_buffer,
          max_name_length = 14,
          max_prefix_length = 13,
          tab_size = 16,
          separator_style = "slant",
          show_close_icon = false,
          diagnostics_indicator = function(count, level, diagnostics_dict, context)
            local s = " "
            for e, n in pairs(diagnostics_dict) do
              local sym =
                e == "error" and status.error .. " " or (e == "warning" and status.warning .. " " or status.info .. " ")
              s = s .. sym
            end
            return s
          end,
          groups = {
            items = {
              require("bufferline.groups").builtin.pinned:with({icon = ""})
            }
          }
        }
      }

      vim.cmd "set showtabline=0"
    end
  },
  {
    "nvim-lualine/lualine.nvim",
    event = event,
    lazy = true,
    config = function()
      local icons = require "ui.icons"
      local status = icons.status

      require("lualine").setup {
        options = {
          icons_enabled = true,
          -- theme = require "hls.lualine",
          component_separators = {left = " ", right = " "},
          section_separators = {left = "", right = ""},
          disabled_filetypes = {
            statusline = {},
            winbar = {}
          },
          ignore_focus = {},
          always_divide_middle = true,
          globalstatus = true,
          refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000
          }
        },
        sections = {
          lualine_a = {"mode"},
          lualine_b = {
            "branch",
            "diff",
            {
              "diagnostics",
              symbols = {
                error = status.error .. " ",
                warn = status.warning .. " ",
                info = status.info .. " ",
                hint = status.info .. " "
              }
            }
          },
          lualine_c = {
            {
              "filename",
              path = 1
            },
            "progress",
            "filetype"
          },
          lualine_x = {},
          lualine_y = {"encoding"},
          lualine_z = {}
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {"filename"},
          lualine_x = {},
          lualine_y = {},
          lualine_z = {}
        },
        tabline = {},
        winbar = {},
        inactive_winbar = {},
        extensions = {
          "nvim-tree"
        }
      }
    end
  },
  {
    "mvllow/modes.nvim",
    event = {"ModeChanged"},
    config = function()
      local colors = require("ui.colors")

      require("modes").setup {
        colors = {
          -- copy = "#FFE156",
          -- delete = "#F2542D",
          -- insert = "#23CE6B",
          -- visual = "#9745BE",
          copy = colors.yellow["700"],
          delete = colors.red["900"],
          insert = colors.green["900"],
          visual = colors.pink["800"]
        },
        line_opacity = 0.3,
        set_cursor = true,
        set_cursorline = true,
        set_number = true,
        ignore_filetypes = {"NvimTree", "TelescopePrompt"}
      }
    end
  },
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = {"ToggleTerm"},
    config = function()
      require("toggleterm").setup {
        highlights = require "hls.toggleterm",
        size = 20,
        shading_factor = 2,
        start_in_insert = true,
        close_on_exit = true,
        auto_scroll = true,
        shell = vim.o.shell,
        direction = "horizontal",
        float_opts = {
          border = "double",
          winblend = 1
        }
      }
    end
  },
  {
    "lewis6991/gitsigns.nvim",
    ft = "gitcommit",
    -- init = function()
    --   vim.api.nvim_create_autocmd(
    --     {"BufRead"},
    --     {
    --       group = vim.api.nvim_create_augroup("GitSignsLazyLoad", {clear = true}),
    --       callback = function()
    --         vim.fn.system("git rev-parse " .. vim.fn.expand "%:p:h")
    --         if vim.v.shell_error == 0 then
    --           vim.api.nvim_del_augroup_by_name "GitSignsLazyLoad"
    --           vim.schedule(
    --             function()
    --               lazy.load("gitsigns.nvim")
    --             end
    --           )
    --         end
    --       end
    --     }
    --   )
    -- end,
    config = function()
      require("gitsigns").setup {
        signs = {
          add = {hl = "DiffAdd", text = "│", numhl = "GitSignsAddNr"},
          change = {hl = "DiffChange", text = "│", numhl = "GitSignsChangeNr"},
          delete = {hl = "DiffDelete", text = "", numhl = "GitSignsDeleteNr"},
          topdelete = {hl = "DiffDelete", text = "‾", numhl = "GitSignsDeleteNr"},
          changedelete = {hl = "DiffChangeDelete", text = "~", numhl = "GitSignsChangeNr"}
        }
      }
    end
  },
  {
    "booperlv/nvim-gomove",
    cmd = {"GoNMLineDown", "GoNMLineUp"},
    config = function()
      require("gomove").setup {
        map_defaults = false,
        reindent = true,
        undojoin = true,
        move_past_end_col = false
      }
    end
  },
  {
    "hrsh7th/nvim-cmp",
    config = function()
      local cmp = require("cmp")

      vim.o.completeopt = "menu,menuone,noselect"

      local function border(hl_name)
        return {
          {"╭", hl_name},
          {"─", hl_name},
          {"╮", hl_name},
          {"│", hl_name},
          {"╯", hl_name},
          {"─", hl_name},
          {"╰", hl_name},
          {"│", hl_name}
        }
      end

      local cmp_window = require "cmp.utils.window"

      cmp_window.info_ = cmp_window.info
      cmp_window.info = function(self)
        local info = self:info_()
        info.scrollable = false
        return info
      end

      local options = {
        window = {
          completion = {
            border = border "CmpBorder",
            winhighlight = "Normal:CmpPmenu,CursorLine:PmenuSel,Search:None"
          },
          documentation = {
            border = border "CmpDocBorder"
          }
        },
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end
        },
        formatting = {
          format = function(_, vim_item)
            local icons = require("ui.icons").lsp
            vim_item.kind = string.format("%s %s", icons[vim_item.kind], vim_item.kind)
            return vim_item
          end
        },
        mapping = {
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.close(),
          ["<CR>"] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = false
          },
          ["<Tab>"] = cmp.mapping(
            function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              elseif require("luasnip").expand_or_jumpable() then
                vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true), "")
              else
                -- fallback()
                vim.api.nvim_input("<C-T>")
              end
            end,
            {
              "i",
              "s"
            }
          ),
          ["<S-Tab>"] = cmp.mapping(
            function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              elseif require("luasnip").jumpable(-1) then
                vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-prev", true, true, true), "")
              else
                fallback()
              end
            end,
            {
              "i",
              "s"
            }
          )
        },
        sources = {
          {name = "luasnip"},
          {name = "nvim_lsp"},
          {name = "buffer"},
          {name = "nvim_lua"},
          {name = "path"}
        }
      }

      cmp.setup(options)
    end,
    event = "InsertEnter",
    dependencies = {
      "rafamadriz/friendly-snippets",
      {
        "L3MON4D3/LuaSnip",
        config = function()
          local luasnip = require("luasnip")

          luasnip.config.set_config {
            history = true,
            updateevents = "TextChanged,TextChangedI"
          }

          require("luasnip.loaders.from_vscode").lazy_load {paths = vim.g.luasnippets_path or ""}
          -- require("luasnip.loaders.from_vscode").lazy_load()

          vim.api.nvim_create_autocmd(
            "InsertLeave",
            {
              callback = function()
                if
                  require("luasnip").session.current_nodes[vim.api.nvim_get_current_buf()] and
                    not require("luasnip").session.jump_active
                 then
                  require("luasnip").unlink_current()
                end
              end
            }
          )
        end
      },
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      {
        "windwp/nvim-autopairs",
        config = function()
          local cmp = require("cmp")

          require("nvim-autopairs").setup {
            fast_wrap = {},
            disable_filetype = {
              "TelescopePrompt",
              "vim"
            }
          }

          local cmp_autopairs = require("nvim-autopairs.completion.cmp")
          cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end
      }
    }
  },
  {
    "nvim-treesitter/nvim-treesitter",
    -- cmd = {"TSInstall", "TSBufEnable", "TSBufDisable", "TSEnable", "TSDisable", "TSModuleInfo"},
    build = ":TSUpdate",
    config = function()
      local rainbow_delimiters = require("rainbow-delimiters")
      local hlargs = require("hlargs")
      local colors = require("ui.colors")

      hlargs.setup {
        color = colors.yellow["200"]
      }

      vim.api.nvim_create_autocmd(
        {"BufRead", "BufNewFile"},
        {
          pattern = {
            "Scanfile",
            "Snapfile",
            "Matchfile",
            "Gemfile",
            "Fastfile",
            "Deliverfile",
            "Appfile",
            "Pluginfile",
            "Podfile",
            "*.podspec"
          },
          command = "set filetype=ruby"
        }
      )

      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow_delimiters.strategy["global"],
          vim = rainbow_delimiters.strategy["local"]
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks"
        },
        highlight = {
          "RainbowDelimiterBlue",
          "RainbowDelimiterYellow",
          "RainbowDelimiterRed"
          -- "RainbowDelimiterOrange",
          -- "RainbowDelimiterGreen",
          -- "RainbowDelimiterViolet",
          -- "RainbowDelimiterCyan"
        }
      }

      require("nvim-treesitter.configs").setup {
        ensure_installed = {
          "bash",
          "c",
          "cmake",
          "comment",
          "cpp",
          "css",
          "dart",
          "elixir",
          "go",
          "graphql",
          "html",
          "java",
          "javascript",
          "json",
          "lua",
          "make",
          "markdown",
          "proto",
          "python",
          "regex",
          "rescript",
          "ruby",
          "tsx",
          "typescript",
          "vim",
          "yaml"
          -- "fsharp"
        },
        highlight = {
          enable = true,
          use_languagetree = true
        },
        endwise = {
          enable = true
        },
        autotag = {
          enable = true
        },
        context_commentstring = {
          enable = true,
          enable_autocmd = false,
          config = {
            typescriptreact = {
              __default = "// %s",
              jsx_element = "{/* %s */}",
              jsx_fragment = "{/* %s */}",
              jsx_attribute = "// %s",
              comment = "// %s"
            }
          }
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<D-l>",
            node_incremental = "<D-l>",
            scope_incremental = "<D-;>",
            node_decremental = "<D-k>"
          }
        },
        refactor = {
          highlight_definitions = {
            enable = true
          },
          smart_rename = {
            enable = true,
            keymaps = {
              smart_rename = "<D-e>"
            }
          }
        }
        -- TODO: problem with dart files
        -- indent = {
        --   enable = true
        -- },
      }
    end,
    -- lazy = false,
    -- event = event,
    dependencies = {
      -- "Dkendal/nvim-treeclimber",
      "nvim-treesitter/nvim-treesitter-refactor",
      "m-demare/hlargs.nvim",
      "JoosepAlviste/nvim-ts-context-commentstring",
      "nkrkv/nvim-treesitter-rescript",
      "HiPhish/rainbow-delimiters.nvim",
      -- "UserNobody14/tree-sitter-dart",
      {
        "windwp/nvim-ts-autotag",
        event = "InsertEnter"
      },
      {
        "RRethy/nvim-treesitter-endwise",
        event = "InsertEnter"
      },
      {
        "terrortylor/nvim-comment",
        config = function()
          vim.opt_local.comments = [[sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,:///,://]]
          vim.opt_local.commentstring = [[//%s]]

          require("nvim_comment").setup {
            create_mappings = true,
            hook = function()
              require("ts_context_commentstring.internal").update_commentstring()
            end
          }
        end
      }
    }
  },
  {
    "monaqa/dial.nvim",
    config = function()
      local augend = require("dial.augend")
      local dial = require("dial.config")

      dial.augends:register_group {
        -- default augends used when no group name is specified
        default = {
          augend.constant.alias.bool,
          augend.constant.alias.alpha,
          augend.constant.alias.Alpha,
          augend.integer.alias.decimal_int, -- nonnegative decimal number (0, 1, 2, 3, ...)
          augend.date.alias["%d.%m.%Y"], -- date (2022/02/19, etc.)
          augend.constant.new {
            elements = {"&&", "||"},
            word = false,
            cyclic = true
          },
          augend.constant.new {
            elements = {">", "<", "<=", ">=", "===", "=="},
            word = false,
            cyclic = true
          },
          augend.constant.new {
            elements = {
              "number",
              "string",
              "boolean",
              "unknown",
              "any",
              "void",
              "null",
              "undefined",
              "never",
              "bigint"
            },
            word = false,
            cyclic = true
          },
          augend.constant.new {
            elements = {
              "🞏",
              "🞪",
              "🞶",
              "⏺",
              "⏸"
            },
            word = false,
            cyclic = true
          }
        }
      }
    end
  },
  -- {
  --   "jesseleite/nvim-noirbuddy",
  --   dependencies = {
  --     {"tjdevries/colorbuddy.nvim", branch = "dev"}
  --   },
  --   config = load "noirbuddy"
  -- },
  {
    "Selyss/mind.nvim",
    branch = "v2.2",
    cmd = {
      "MindOpenMain",
      "MindOpenProject",
      "MindClose",
      "MindFindNotes",
      "MindGrepNotes"
    },
    dependencies = {"nvim-lua/plenary.nvim"},
    config = function()
      local mind = require("mind")

      mind.setup {
        persistence = {
          state_path = vim.fn.stdpath("data") .. "/mind.json",
          data_dir = vim.fn.stdpath("data") .. "/mind"
        },
        ui = {
          width = 40
        },
        keymaps = {
          normal = {
            ["<cr>"] = "open_data",
            f = function()
              vim.cmd "MindFindNotes"
            end,
            ["<tab>"] = "toggle_node",
            ["<S-tab>"] = "toggle_node",
            ["/"] = "select_path",
            ["$"] = "change_icon_menu",
            c = "add_inside_end_index",
            A = "add_inside_start",
            a = "add_inside_end",
            l = "copy_node_link",
            L = "copy_node_link_index",
            d = "delete",
            D = "delete_file",
            O = "add_above",
            o = "add_below",
            q = function()
              vim.cmd "MindClose"
            end,
            r = "rename",
            R = "change_icon",
            u = "make_url",
            x = "select"
          },
          selection = {
            ["<cr>"] = "open_data",
            ["<s-tab>"] = "toggle_node",
            ["/"] = "select_path",
            I = "move_inside_start",
            i = "move_inside_end",
            O = "move_above",
            o = "move_below",
            q = function()
              vim.cmd "MindClose"
            end,
            x = "select"
          }
        }
      }

      vim.api.nvim_create_user_command(
        "MindOpenProject",
        function()
          if not vim.g.mind_is_visible then
            vim.g.mind_is_visible = true
            mind.open_project()
            vim.cmd("keepalt file mind")
          else
            vim.cmd("MindClose")
          end
        end,
        {}
      )

      vim.api.nvim_create_user_command(
        "MindOpenMain",
        function()
          if not vim.g.mind_is_visible then
            vim.g.mind_is_visible = true
            mind.open_main()
            vim.cmd("keepalt file mind")
          else
            vim.cmd("MindClose")
          end
        end,
        {}
      )

      vim.api.nvim_create_user_command(
        "MindClose",
        function()
          mind.close()
          vim.g.mind_is_visible = false
        end,
        {}
      )

      vim.api.nvim_create_user_command(
        "MindFindNotes",
        function()
          require("telescope.builtin").find_files {
            prompt_title = "Mind: Browse Notes",
            cwd = "./.mind/data"
          }
        end,
        {}
      )

      vim.api.nvim_create_user_command(
        "MindGrepNotes",
        function()
          require("telescope.builtin").grep_string {
            prompt_title = "Mind: Search Notes",
            cwd = "./.mind/data"
          }
        end,
        {}
      )
    end
  },
  -- {
  --   "akinsho/flutter-tools.nvim",
  --   dependencies = {"nvim-lua/plenary.nvim"}
  -- },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = {"nvim-lua/plenary.nvim"},
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()
    end
  },
  -- {
  --   "shadowofseaice/yabs.nvim",
  --   dependencies = {
  --     "kyazdani42/nvim-web-devicons"
  --   },
  --   config = function()
  --     require("yabs").setup {
  --       position = {"C"},
  --       rnu = true, -- show relative line number, comes handy to quickly jump around buffers with usual #j or #k keys
  --       border = "rounded", -- none, single, double, rounded, solid, shadow, (or an array or chars). Default shadow
  --       offset = {
  --         -- window position offset
  --         top = 2, -- default 0
  --         bottom = 2, -- default 0
  --         left = 2, -- default 0
  --         right = 2 -- default 0
  --       },
  --       settings = {
  --         {"name", "icon", "bufnr"},
  --         {"icon", "bufnr", "bufname", "lnum", "line"},
  --         {"path", "name", "bufid"}
  --       },
  --       keymap = {
  --         close = "<D-d>", -- Close buffer. Default D
  --         jump = "<CR>", -- Jump to buffer. Default <cr>
  --         h_split = "h", -- Horizontally split buffer. Default s
  --         v_split = "v", -- Vertically split buffer. Default v
  --         pinning = "p", -- Open buffer preview. Default p
  --         cycset = "]", -- Cycle through settings, Default ]
  --         rcycset = "[", -- Reverse cycle through settings, Default [
  --         cycpos = ".", -- Cycle through settings, Default >
  --         rcycpos = ",", -- Reverse cycle through panel placement, Default <
  --         cycname = "}", -- Cycle through file name type, Default }
  --         rcycname = "{", -- Reverse cycle through file name type, Default {
  --         cychdr = "H", -- Cycle through group header options, Default H
  --         sortpath = "P", -- Sort by file path. Default P
  --         sortext = "e", -- Sort by file extension (type), Default t
  --         sortused = "l", -- Sort by last used, Default u
  --         sortbuf = "c", -- Sort clear = sort by buffer #, default c
  --         sortbase = "b", -- Sort by file base name #, default f
  --         sortfull = "f", -- Sort by full file name #, default F
  --         sortinit = "i" -- Sort by file name initial #, default i
  --       },
  --       highlight = {
  --         current = "Title", -- default WarningMsg
  --         edited = "Comment", -- default ModeMsg
  --         split = "Comment", -- default Normal
  --         alter = "Comment", -- default Normal
  --         grphead = "Comment", -- default Fold
  --         unloaded = "Comment" -- default Comment
  --       }
  --     }
  --   end
  -- },
  {
    "HampusHauffman/block.nvim",
    config = function()
      require("block").setup {
        percent = 0.8,
        depth = 4,
        colors = nil,
        automatic = false
        --        colors = {
        --            "#ff0000"
        --            "#00ff00"
        --            "#0000ff"
        --        }
      }
    end
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "ray-x/lsp_signature.nvim",
      {
        "jose-elias-alvarez/null-ls.nvim",
        config = function()
          local null_ls = require("null-ls")

          local b = null_ls.builtins
          local command_resolver = require("null-ls.helpers.command_resolver")

          local lsp_formatting = function(bufnr)
            vim.lsp.buf.format(
              {
                filter = function(client)
                  return client.name == "null-ls"
                end,
                bufnr = bufnr
              }
            )
          end

          vim.api.nvim_create_user_command(
            "FormatFile",
            function()
              lsp_formatting(0)
            end,
            {}
          )

          -- if you want to set up formatting on save, you can use this as a callback
          local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

          -- vim.api.nvim_create_autocmd(
          --   "FileType",
          --   {
          --     pattern = "ruby",
          --     group = vim.api.nvim_create_augroup("RubyLSP", {clear = true}),
          --     callback = function()
          --       vim.lsp.start {
          --         name = "standard",
          --         cmd = {
          --           "standardrb",
          --           "--lsp"
          --         }
          --       }
          --     end
          --   }
          -- )

          null_ls.setup {
            debug = false,
            sources = {
              b.diagnostics.eslint_d.with(
                {
                  diagnostics_format = "[#{c}] #{m} (#{s})"
                }
              ),
              b.code_actions.eslint_d,
              b.formatting.rescript,
              b.formatting.prettierd.with {
                filetypes = {"html", "css", "typescript", "typescriptreact", "javascript", "javascriptreact"}
              },
              b.formatting.dart_format,
              b.formatting.clang_format,
              b.diagnostics.rubocop.with(
                {
                  command = {"bundle", "exec", "rubocop"}
                }
              ),
              b.formatting.rubocop.with(
                {
                  command = {"bundle", "exec", "rubocop"}
                }
              )
            },
            on_attach = function(client, bufnr)
              if client.supports_method("textDocument/formatting") then
                vim.api.nvim_clear_autocmds(
                  {
                    group = augroup,
                    buffer = bufnr
                  }
                )

                vim.api.nvim_create_autocmd(
                  "BufWritePre",
                  {
                    group = augroup,
                    buffer = bufnr,
                    callback = function()
                      lsp_formatting(bufnr)
                    end
                  }
                )
              end
            end
          }
        end
      }
    },
    -- lazy = true,
    -- event = event,
    config = function()
      local lspconfig = require("lspconfig")

      local symbol = function(name, icon)
        local hl = "DiagnosticSign" .. name
        vim.fn.sign_define(hl, {text = icon, numhl = hl, texthl = hl})
      end

      local icons = require("ui.icons").status

      symbol("Error", icons.error)
      symbol("Info", icons.info)
      symbol("Hint", icons.info)
      symbol("Warn", icons.warning)

      vim.diagnostic.config {
        virtual_text = {
          prefix = "" -- triangle
        },
        signs = true,
        underline = true,
        update_in_insert = false
      }

      -- vim.cmd [[
      --   autocmd! CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false, scope="cursor", border="rounded"})
      -- ]]

      vim.lsp.handlers["textDocument/hover"] =
        vim.lsp.with(
        vim.lsp.handlers.hover,
        {
          border = "rounded"
        }
      )
      vim.lsp.handlers["textDocument/signatureHelp"] =
        vim.lsp.with(
        vim.lsp.handlers.signature_help,
        {
          border = "rounded",
          focusable = false,
          relative = "cursor"
        }
      )

      vim.lsp.handlers["textDocument/publishDiagnostics"] =
        vim.lsp.with(
        vim.lsp.diagnostic.on_publish_diagnostics,
        {
          underline = true,
          virtual_text = {
            spacing = 4,
            prefix = "", -- dot
            severity_limit = "Warning"
          },
          severity_sort = true,
          update_in_insert = true
        }
      )

      -- suppress error messages from lang servers
      vim.notify = function(msg, log_level)
        if msg:match "exit code" then
          return
        end
        if log_level == vim.log.levels.ERROR then
          vim.api.nvim_err_writeln(msg)
        else
          vim.api.nvim_echo({{msg}}, true, {})
        end
      end

      -- Borders for LspInfo window
      local win = require("lspconfig.ui.windows")
      local _default_opts = win.default_opts

      win.default_opts = function(options)
        local opts = _default_opts(options)
        opts.border = "rounded"
        return opts
      end

      local servers = {"tsserver", "dartls", "clangd"}

      local on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false

        if client.server_capabilities.signatureHelpProvider then
          require("ui.signature").setup(client)
        end

        -- require "lsp_signature".on_attach(
        --   {
        --     bind = true,
        --     max_height = 5,
        --     handler_opts = {
        --       border = "rounded"
        --     },
        --     floating_window_off_y = -1,
        --     floating_window_off_x = 1,
        --     hint_enable = false,
        --     auto_close_after = 1,
        --     toggle_key = "<D-1>"
        --     -- hint_prefix = "👻 ",
        --     -- hint_scheme = "LspSignatureHint"
        --   },
        --   bufnr
        -- )
      end

      local capabilities = vim.lsp.protocol.make_client_capabilities()

      capabilities.textDocument.completion.completionItem = {
        documentationFormat = {"markdown", "plaintext"},
        snippetSupport = true,
        preselectSupport = true,
        insertReplaceSupport = true,
        labelDetailsSupport = true,
        deprecatedSupport = true,
        commitCharactersSupport = true,
        tagSupport = {
          valueSet = {1}
        },
        resolveSupport = {
          properties = {
            "documentation",
            "detail",
            "additionalTextEdits"
          }
        }
      }

      for _, lsp in ipairs(servers) do
        if lsp == "dartls" then
          -- require("plugins.flutter-tools").setup(on_attach, capabilities)
        else
          lspconfig[lsp].setup {
            on_attach = on_attach,
            capabilities = capabilities
          }
        end
      end

      lspconfig.lua_ls.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = {
              globals = {"vim"}
            },
            workspace = {
              library = {
                [vim.fn.expand "$VIMRUNTIME/lua"] = true,
                [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true
              },
              maxPreload = 100000,
              preloadFileSize = 10000
            }
          }
        }
      }

      lspconfig.solargraph.setup(
        {
          cmd = {"bundle", "exec", "solargraph", "stdio"}
        }
      )

      lspconfig.rescriptls.setup {
        cmd = {
          "/usr/local/bin/node",
          "/Users/mobily/.local/share/nvim/mason/packages/rescript-lsp/extension/server/out/server.js",
          "--stdio"
        },
        on_attach = on_attach,
        capabilities = capabilities
      }
    end
  },
  {
    "David-Kunz/gen.nvim",
    cmd = {"Gen"},
    config = function()
      local gen = require("gen")
      gen.setup {
        model = "zephyr", -- The default model to use.
        display_mode = "split", -- The display mode. Can be "float" or "split".
        show_prompt = false, -- Shows the Prompt submitted to Ollama.
        show_model = false, -- Displays which model you are using at the beginning of your chat session.
        no_auto_close = false, -- Never closes the window automatically.
        init = function(options)
          pcall(io.popen, "ollama serve > /dev/null 2>&1 &")
        end,
        -- Function to initialize Ollama
        command = "curl --silent --no-buffer -X POST http://localhost:11434/api/generate -d $body",
        -- The command for the Ollama service. You can use placeholders $prompt, $model and $body (shellescaped).
        -- This can also be a lua function returning a command string, with options as the input parameter.
        -- The executed command must return a JSON object with { response, context }
        -- (context property is optional).
        debug = false
      }

      gen.prompts["X_Generate_Simple_Description"] = {
        prompt = "Provide a simple and concise description of the following code:\n$register",
        replace = false
      }

      gen.prompts["X_Generate_Description"] = {
        prompt = "Provide a detailed description of the following code:\n$register",
        replace = false
      }

      gen.prompts["X_Suggest_Better_Naming"] = {
        prompt = "Take all variable and function names, and provide only a list with suggestions with improved naming:\n$register",
        replace = false
      }

      gen.prompts["X_Enhance_Grammar_Spelling"] = {
        prompt = "Modify the following text to improve grammar and spelling, just output the final text in English without additional quotes around it:\n$register",
        replace = false
      }

      gen.prompts["X_Enhance_Wording"] = {
        prompt = "Modify the following text to use better wording, just output the final text without additional quotes around it:\n$register",
        replace = false
      }

      gen.prompts["X_Make_Concise"] = {
        prompt = "Modify the following text to make it as simple and concise as possible, just output the final text without additional quotes around it:\n$register",
        replace = false
      }

      gen.prompts["X_Review_Code"] = {
        prompt = "Review the following code and make concise suggestions:\n```$filetype\n$register\n```"
      }

      gen.prompts["X_Enhance_Code"] = {
        prompt = "Enhance the following code, only output the result in format ```$filetype\n...\n```:\n```$filetype\n$register\n```",
        replace = false,
        extract = "```$filetype\n(.-)```"
      }

      gen.prompts["X_Simplify_Code"] = {
        prompt = "Simplify the following code, only output the result in format ```$filetype\n...\n```:\n```$filetype\n$register\n```",
        replace = false,
        extract = "```$filetype\n(.-)```"
      }

      gen.prompts["X_Ask"] = {prompt = "Regarding the following text, $input:\n$register"}
    end
  },
  {
    "echasnovski/mini.surround",
    version = "*",
    config = function()
      require("mini.surround").setup()
    end
  },
  {
    "nvim-pack/nvim-spectre"
  },
  {
    "chrisgrieser/nvim-early-retirement",
    config = true,
    event = "VeryLazy"
  },
  {
    "chrisgrieser/nvim-scissors",
    dependencies = "nvim-telescope/telescope.nvim", -- optional
    config = function()
      require("scissors").setup(
        {
          snippetDir = "/Users/mobily/.config/nvim/lua/snippets"
        }
      )
    end
  },
  {
    "folke/trouble.nvim",
    dependencies = {"nvim-tree/nvim-web-devicons"},
    opts = {
      use_diagnostic_signs = true,
      height = 20
    }
  },
  {
    "j-hui/fidget.nvim",
    opts = {
      integration = {
        ["nvim-tree"] = {
          enable = true -- Integrate with nvim-tree/nvim-tree.lua (if installed)
        }
      }
    }
  },
  {
    "0xAdk/full_visual_line.nvim",
    keys = "V",
    opts = {}
  }
}
