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
                 configuration = {
                   runtimes = {
                     {
                       name = "JavaSE-23",
                       path = "/usr/libexec/java_home -v21",
                     },
                   },
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
               },
            })
          end,
        },
      },
    },
  },
}
