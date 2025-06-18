return {
  "nvim-java/nvim-java",
  config = false,
  ft = { "java" },
  dependencies = {
    {
      "neovim/nvim-lspconfig",
      opts = {
        servers = {
          -- Your JDTLS configuration goes here
          jdtls = {
             settings = {
               java = {
                 eclipse = { downloadSources = true },
                 maven = { downloadSources = true },
                 implementationsCodeLens = { enabled = true },
                 referencesCodeLens = { enabled = true },
                 format = { enabled = true },
                 configuration = {
                   runtimes = {
                     {
                       name = "JavaSE-21",
                       path = "/usr/libexec/java_home -v21",
                     },
                   },
                 },
                 sources = {
                    organizeImports = {
                    starThreshold = 9999,
                    staticStarThreshold = 9999,
                },
                },
                codeGeneration = {
                    toString = {
                        template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}',
                    },
                    useBlocks = true,
                },
               },
             },
          },
        },
        setup = {
          jdtls = function()
            -- Your nvim-java configuration goes here
            require("java").setup({
               root_markers = {
                 "settings.gradle",
                 "settings.gradle.kts",
                 "pom.xml",
                 "build.gradle",
                 "mvnw",
                 "gradlew",
                 "build.gradle",
                 "build.gradle.kts",
                 ".git",
               },
               lombok = {
                    version = 'nightly',
               },
            })
          end,
        },
      },
    },
  },
}
