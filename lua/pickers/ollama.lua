local Form = require("plugins.nui-form")

local fn = require("utils.fn")

local M = {}

M.toggle = function()
  local register = vim.fn.getreg('"')
  local diags = vim.lsp.diagnostic.get_line_diagnostics()

  local form =
    Form:new(
    {
      on_submit = function(state)
        local id = state.type[1].id

        local prompt =
          fn.switch(
          id,
          {
            ["chat"] = function()
              return state.chat
            end,
            ["ask"] = function()
              return "Regarding the following text:\n" .. state.text .. "\n" .. state.question
            end,
            ["enhance-grammar"] = function()
              return "Modify the following text to improve grammar and spelling, just output the final text in English without additional quotes around it:\n" ..
                state.text
            end,
            ["enhance-wording"] = function()
              return "Modify the following text to use better wording, just output the final text without additional quotes around it:\n" ..
                state.text
            end,
            ["make-concise"] = function()
              return "Modify the following text to make it as simple and concise as possible, just output the final text without additional quotes around it:\n" ..
                state.text
            end,
            ["generate-simple-description"] = function()
              return "Provide a simple and concise description of the following code:\n" .. state.code
            end,
            ["generate-detailed-description"] = function()
              return "Provide a detailed description of the following code:\n" .. state.code
            end,
            ["suggest-better-naming"] = function()
              return "Take all variable and function names, and provide only a list with suggestions with improved naming:\n" ..
                state.code
            end,
            ["review-code"] = function()
              return "Review the following code and make concise suggestions, only output the result in format:\n```" ..
                vim.bo.filetype .. "\n" .. state.code .. "\n```"
            end,
            ["simplify-code"] = function()
              return "Simplify the following code, only output the result in format:\n```" ..
                vim.bo.filetype .. "\n" .. state.code .. "\n```"
            end,
            ["improve-code"] = function()
              return "improve the following code, only output the result in format:\n```" ..
                vim.bo.filetype .. "\n" .. state.code .. "\n```"
            end,
            ["issue"] = function()
              local content =
                table.concat(vim.api.nvim_buf_get_lines(vim.api.nvim_get_current_buf(), 0, -1, false), "\n")

              return "provide more a simple and concise insight about the following issue, try to fix it\n" ..
                state.issue .. "\nin the following code\n```" .. vim.bo.filetype .. "\n" .. content .. "\n```"
            end
          }
        )

        return require("gen").exec({prompt = prompt})
      end
    }
  )

  local data = {
    {
      text = "chit-chat",
      id = "chat"
    },
    {
      text = "ask regarding the following text/code",
      id = "ask"
    },
    {
      type = "separator",
      text = "󰦨 text "
    },
    {
      text = "modify the following text to improve grammar and spelling",
      id = "enhance-grammar"
    },
    {
      text = "modify the following text to use better wording",
      id = "enhance-wording"
    },
    {
      text = "modify the following text to make it as simple and concise as possible",
      id = "make-concise"
    },
    {
      type = "separator",
      text = "󰅪 code "
    },
    {
      text = "generate a simple and concise description of the following code",
      id = "generate-simple-description"
    },
    {
      text = "generate a detailed description of the following code",
      id = "generate-detailed-description"
    },
    {
      text = "use better names for all provided variables and functions",
      id = "suggest-better-naming"
    },
    {
      text = "review the following code and make concise suggestions",
      id = "review-code"
    },
    {
      text = "simplify the following code",
      id = "simplify-code"
    },
    {
      text = "improve the following code",
      id = "improve-code"
    }
  }

  if #diags > 0 then
    table.insert(
      data,
      3,
      {
        text = "learn more about the following issue",
        id = "issue"
      }
    )
  end

  -- vim.notify(vim.inspect(diags))

  form:set_content(
    form.select(
      {
        height = 10,
        focus = true,
        key = "type",
        label = "Hey, Ollama, I'd like to…",
        shrink_on_blur = true,
        data = data,
        default_value = {"chat"}
      }
    ),
    form.text_input(
      {
        height = 16,
        key = "issue",
        label = "Issue",
        wrap = true,
        icon = "",
        default_value = table.concat(
          fn.ireduce(
            diags,
            function(acc, diag)
              fn.ieach(
                vim.split(diag.message, "\n"),
                function(message)
                  table.insert(acc, fn.trim(message))
                end
              )
              return acc
            end,
            {}
          ),
          "\n"
        ),
        hidden = function(state)
          local id = state.type[1].id
          return #diags == 0 or not (id == "issue")
        end
      }
    ),
    form.text_input(
      {
        height = 6,
        key = "chat",
        icon = "󰭻",
        label = "Chat",
        wrap = true,
        hidden = function(state)
          local id = state.type[1].id
          return not (id == "chat")
        end
      }
    ),
    form.text_input(
      {
        height = 6,
        key = "question",
        icon = "",
        label = "Question",
        wrap = true,
        hidden = function(state)
          local id = state.type[1].id
          return not (id == "ask")
        end
      }
    ),
    form.text_input(
      {
        height = 16,
        key = "text",
        icon = "󰦨",
        label = "Text",
        default_value = register,
        wrap = true,
        hidden = function(state)
          return not fn.isome(
            {
              "ask",
              "enhance-grammar",
              "enhance-wording",
              "make-concise"
            },
            function(key)
              return key == state.type[1].id
            end
          )
        end
      }
    ),
    form.text_input(
      {
        height = 16,
        key = "code",
        icon = "",
        label = "Code",
        default_value = register,
        filetype = vim.bo.filetype,
        hidden = function(state)
          return not fn.isome(
            {
              "generate-simple-description",
              "generate-detailed-description",
              "suggest-better-naming",
              "review-code",
              "simplify-code",
              "improve-code"
            },
            function(key)
              return key == state.type[1].id
            end
          )
        end
      }
    ),
    form.footer()
  )

  form:open()
end

return M
