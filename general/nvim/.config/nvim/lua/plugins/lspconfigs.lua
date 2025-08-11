return {
  -- Workaround for the breaking change for Mason https://github.com/LazyVim/LazyVim/issues/6039#issuecomment-2856227817
  -- This should be removed when things are patched
  { "mason-org/mason.nvim", nvim = "1.11.0" },
  {
    "williamboman/mason-lspconfig.nvim",
    version = "1.32.0", -- Part of the same workaround
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "rustfmt",
          "shfmt",
          "lua_ls",
          "bashls",
          "cssls",
          "denols",
          "prettierd",
          "dockerls",
          "docker_compose_language_service",
          "eslint",
          "html",
          "volar",
          "jsonls",
          "marksman",
          "taplo",
          "vtsls",
          "cssmodules_ls",
          "css_variables",
          "yaml-language-server",
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- make sure mason installs the server
      servers = {
        lua_ls = {},
        bashls = {},
        cssls = {},
        dockerls = {},
        docker_compose_language_service = {},
        eslint = {
          settings = {
            workingDirectories = { mode = "auto" },
          },
          root_dir = require("lspconfig").util.root_pattern(
            ".eslintrc.js",
            ".eslintrc.json",
            ".eslintrc.cjs",
            ".eslintrc.yaml",
            ".eslintrc.yml",
            ".eslintrc",
            "eslint.config.js",
            "eslint.config.mjs"
          ),
        },
        cssmodules_ls = {},
        css_variables = {},
        yamlls = {},
        html = {},
        jsonls = {},
        jqls = {},
        taplo = {},
        volar = {},
        denols = {
          -- Prevents deno from being loaded into node projects
          root_dir = require("lspconfig").util.root_pattern("deno.json", "deno.jsonc"),
          --   local lspconfig = require("lspconfig")
          --   return lspconfig.util.root_pattern("deno.json", "deno.jsonc")
          -- end,
          init_options = {
            enable = true,
            lint = true,
            unstable = true,
            suggest = {
              imports = {
                hosts = {
                  "https://deno.land",
                  "https://jsr.io",
                },
              },
            },
          },
        },
        tsserver = {
          enabled = false,
        },
        ts_ls = {
          enabled = false,
          ts_ls = {
            autoStart = false,
          },
        },
        vtsls = {
          -- Enables vtsls in single file only when there are no main packages found
          single_file_support = not require("lspconfig").util.root_pattern(
            "deno.json",
            "deno.jsonc",
            "package.json",
            "package-lock.json"
          ),
          -- explicitly add default filetypes, so that we can extend
          -- them in related extras
          filetypes = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript",
            "typescriptreact",
            "typescript.tsx",
          },
          -- root_dir = function(filename)
          --   -- NOTE: root_pattern returns a function that needs to be called with the filename
          --   local lspconfig = require("lspconfig")
          --   local denoRootDir = lspconfig.util.root_pattern("deno.json", "deno.jsonc")(filename)
          --   -- prevents tsserver from attaching in deno projects
          --   if denoRootDir then
          --     return nil
          --   end
          --   local jsRoot = lspconfig.util.root_pattern("package.json")(filename)
          --   if jsRoot then
          --     return jsRoot
          --   end
          --   return filename
          -- end,
          settings = {
            complete_function_calls = true,
            vtsls = {
              enableMoveToFileCodeAction = true,
              autoUseWorkspaceTsdk = true,
              experimental = {
                completion = {
                  enableServerSideFuzzyMatch = true,
                },
              },
            },
            typescript = {
              updateImportsOnFileMove = { enabled = "always" },
              suggest = {
                completeFunctionCalls = true,
              },
              inlayHints = {
                enumMemberValues = { enabled = true },
                functionLikeReturnTypes = { enabled = false },
                parameterNames = { enabled = "literal" },
                parameterTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                variableTypes = { enabled = false },
              },
            },
          },
          --   keys = {
          --     {
          --       "gD",
          --       function()
          --         local params = vim.lsp.util.make_position_params()
          --         LazyVim.lsp.execute({
          --           command = "typescript.goToSourceDefinition",
          --           arguments = { params.textDocument.uri, params.position },
          --           open = true,
          --         })
          --       end,
          --       desc = "Goto Source Definition",
          --     },
          --     {
          --       "gR",
          --       function()
          --         LazyVim.lsp.execute({
          --           command = "typescript.findAllFileReferences",
          --           arguments = { vim.uri_from_bufnr(0) },
          --           open = true,
          --         })
          --       end,
          --       desc = "File References",
          --     },
          --     {
          --       "<leader>co",
          --       LazyVim.lsp.action["source.organizeImports"],
          --       desc = "Organize Imports",
          --     },
          --     {
          --       "<leader>cM",
          --       LazyVim.lsp.action["source.addMissingImports.ts"],
          --       desc = "Add missing imports",
          --     },
          --     {
          --       "<leader>cu",
          --       LazyVim.lsp.action["source.removeUnused.ts"],
          --       desc = "Remove unused imports",
          --     },
          --     {
          --       "<leader>cD",
          --       LazyVim.lsp.action["source.fixAll.ts"],
          --       desc = "Fix all diagnostics",
          --     },
          --     {
          --       "<leader>cV",
          --       function()
          --         LazyVim.lsp.execute({ command = "typescript.selectTypeScriptVersion" })
          --       end,
          --       desc = "Select TS workspace version",
          --     },
          --   },
        },
      },
      setup = {
        tsserver = function()
          -- disable tsserver
          return true
        end,
        vtsls = function(_, opts)
          LazyVim.lsp.on_attach(function(client, buffer)
            client.commands["_typescript.moveToFileRefactoring"] = function(command, ctx)
              ---@type string, string, lsp.Range
              local action, uri, range = unpack(command.arguments)

              local function move(newf)
                client.request("workspace/executeCommand", {
                  command = command.command,
                  arguments = { action, uri, range, newf },
                })
              end

              local fname = vim.uri_to_fname(uri)
              client.request("workspace/executeCommand", {
                command = "typescript.tsserverRequest",
                arguments = {
                  "getMoveToRefactoringFileSuggestions",
                  {
                    file = fname,
                    startLine = range.start.line + 1,
                    startOffset = range.start.character + 1,
                    endLine = range["end"].line + 1,
                    endOffset = range["end"].character + 1,
                  },
                },
              }, function(_, result)
                ---@type string[]
                local files = result.body.files
                table.insert(files, 1, "Enter new path...")
                vim.ui.select(files, {
                  prompt = "Select move destination:",
                  format_item = function(f)
                    return vim.fn.fnamemodify(f, ":~:.")
                  end,
                }, function(f)
                  if f and f:find("^Enter new path") then
                    vim.ui.input({
                      prompt = "Enter move destination:",
                      default = vim.fn.fnamemodify(fname, ":h") .. "/",
                      completion = "file",
                    }, function(newf)
                      return newf and move(newf)
                    end)
                  elseif f then
                    move(f)
                  end
                end)
              end)
            end
          end, "vtsls")
          -- copy typescript settings to javascript
          opts.settings.javascript =
            vim.tbl_deep_extend("force", {}, opts.settings.typescript, opts.settings.javascript or {})
        end,
      },
    },
  },
}
