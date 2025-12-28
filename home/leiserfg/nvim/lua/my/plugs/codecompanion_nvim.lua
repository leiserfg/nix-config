return {
  "codecompanion.nvim",
  after = function()
    require("codecompanion").setup {
      interactions = {
        chat = {
          adapter = "copilot",
          model = "claude-4-5-sonnet",
          variables = {
            ["buffer"] = {
              opts = {
                default_params = "diff",
              },
            },
          },
        },
        inline = {
          adapter = "copilot",
          model = "claude-4-5-sonnet",
        },
        agent = {
          adapter = "copilot",
          model = "claude-4-5-sonnet",
        },
      },
      rules = {
        opts = {
          chat = {
            enabled = true,
            default_rules = "default",
            autoload = "default",
          },
        },
      },
      display = {
        chat = {
          icons = {
            chat_context = "📎️",
          },
          fold_context = true,
        },
      },
      prompt_library = {
        ["JJ Code Review"] = {
          strategy = "chat",
          description = "Code review",
          prompts = {
            {
              role = "system",
              content = "You are an experienced developer which makes good but not too verbose comments and avoids bullshit chat",
            },
            {
              role = "user",
              content = function()
                return string.format(
                  [[Review the changes in the diff bellow. Don't do a resume of the changes, just comment what you see wrong or remarcable. Whenever it makes sence, include the file and number line.
            In case of change request, include a diff. Changes:

    ```diff
    %s
    ```
            ]],
                  vim.fn.system "jj diff '@..trunk()'"
                )
              end,
            },
          },
        },
        ["Code Review"] = {
          strategy = "chat",
          description = "Code review",
          prompts = {
            {
              role = "system",
              content = "You are an experienced developer which makes good but not too verbose comments and avoids bullshit chat",
            },
            {
              role = "user",
              content = function()
                return string.format(
                  [[Review the changes in the diff bellow. Don't do a resume of the changes, just comment what you see wrong or remarcable. Whenever it makes sence, include the file and number line.
            In case of change request, include a diff. Changes:

    ```diff
    %s
    ```
            ]],
                  vim.fn.system "git diff --no-ext-diff $(git symbolic-ref refs/remotes/origin/HEAD --short)..HEAD"
                )
              end,
            },
          },
        },
      },
    }
  end,
}