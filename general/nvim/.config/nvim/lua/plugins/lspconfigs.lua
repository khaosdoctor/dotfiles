return {
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "bashls",
          "clangd",
          "cssls",
          "denols",
          "dockerls",
          "docker_compose_language_service",
          "eslint",
          "emmet_ls",
          "html",
          "volar",
          "jsonls",
          "ltex",
          "marksman",
          "taplo",
          "cssmodules_ls",
          "css_variables",
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      lspconfig.lua_ls.setup({})
      lspconfig.bashls.setup({})
      lspconfig.cssls.setup({})

      lspconfig.dockerls.setup({})
      lspconfig.docker_compose_language_service.setup({})
      lspconfig.eslint.setup({})
      lspconfig.emmet_ls.setup({})
      lspconfig.html.setup({})
      lspconfig.jsonls.setup({})
      lspconfig.jqls.setup({})
      lspconfig.ltex.setup({})
      lspconfig.marksman.setup({})
      lspconfig.taplo.setup({})
      lspconfig.volar.setup({})
      lspconfig.denols.setup({
        root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
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
        on_attach = on_attach,
      })
      lspconfig.tsserver.setup({
        init_options = {
          plugins = {
            {
              name = "@vue/typescript-plugin",
              location = "/usr/lib/node_modules/@vue/typescript-plugin",
              languages = { "javascript", "typescript", "vue" },
            },
          },
        },
        filetypes = {
          "javascript",
          "javascriptreact",
          "javascript.jsx",
          "typescript",
          "typescriptreact",
          "typescript.tsx",
          "vue",
        },
        on_attach = function(client, bufnr)
          on_attach(client, bufnr)
          vim.keymap.set("n", "<leader>rn", function()
            vim.lsp.buf.execute_command({
              command = "_typescript.organizeImports",
              arguments = { vim.fn.expand("%:p") },
            })
          end, { buffer = bufnr, remap = false })
        end,
        root_dir = function(filename, bufnr)
          local denoRootDir = lspconfig.util.root_pattern("deno.json", "deno.jsonc")
          -- prevents tsserver from attaching in deno projects
          if denoRootDir then
            return nil
          end
          return lspconfig.util.root_pattern("package.json")(filename)
        end,
      })
      lspconfig.cssmodules_ls.setup({})
      lspconfig.css_variables.setup({})
    end,
  },
}
