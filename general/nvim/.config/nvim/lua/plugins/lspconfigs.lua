-- return {}
return {
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
      },
    },
  },
}
