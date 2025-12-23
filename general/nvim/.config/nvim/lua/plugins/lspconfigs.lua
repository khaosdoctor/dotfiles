-- return {}
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- make sure mason installs the server
      servers = {
        lua_ls = {},
        biome = {
          settings = {
            workingDirectories = { mode = "auto" },
          },
          root_dir = function(fname)
            return require("lspconfig").util.root_pattern("biome.jsonc", "biome.json")(fname)
          end,
        },
        bashls = {},
        cssls = {},
        dockerls = {},
        docker_compose_language_service = {},
        eslint = {
          settings = {
            workingDirectories = { mode = "auto" },
          },
          root_dir = function(fname)
            return require("lspconfig").util.root_pattern(
              ".eslintrc.js",
              ".eslintrc.json",
              ".eslintrc.cjs",
              ".eslintrc.yaml",
              ".eslintrc.yml",
              ".eslintrc",
              "eslint.config.js",
              "eslint.config.mjs"
            )(fname)
          end,
        },
        cssmodules_ls = {},
        css_variables = {},
        yamlls = {},
        html = {},
        jsonls = {},
        jqls = {},
        taplo = {},
        volar = {},
        ruby_lsp = {},
        denols = {
          -- Prevents deno from being loaded into node projects
          root_dir = function(fname)
            return require("lspconfig").util.root_pattern("deno.json", "deno.jsonc")(fname)
          end,
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
        vtsls = {
          -- TypeScript language server - will auto-detect project root
          keys = {
            {
              "<leader>co",
              function()
                vim.lsp.buf.code_action({
                  apply = true,
                  context = {
                    only = { "source.organizeImports" },
                    diagnostics = {},
                  },
                })
              end,
              desc = "Organize Imports",
            },
            {
              "<leader>cO",
              function()
                vim.lsp.buf.code_action({
                  apply = true,
                  context = {
                    only = { "source.removeUnused" },
                    diagnostics = {},
                  },
                })
              end,
              desc = "Remove Unused Imports",
            },
          },
        },
      },
    },
  },
}
