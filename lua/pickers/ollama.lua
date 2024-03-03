local Renderer = require("plugins.nui-components")

local fn = require("utils.fn")

local M = {}

M.toggle = function()
  local register = vim.fn.getreg('"')
  local diags = vim.lsp.diagnostic.get_line_diagnostics()

  local h =
    Renderer:new(
    {
      width = 80,
      height = 40,
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
    h.option("chit-chat", {id = "chat"}),
    h.option("ask regarding the following text/code", {id = "ask"}),
    h.separator("󰦨 text "),
    h.option("modify the following text to improve grammar and spelling", {id = "enhance-grammar"}),
    h.option("modify the following text to use better wording", {id = "enhance-wording"}),
    h.option("modify the following text to make it as simple and concise as possible", {id = "make-concise"}),
    h.separator("󰅪 code "),
    h.option("generate a simple and concise description of the following code", {id = "generate-simple-description"}),
    h.option("generate a detailed description of the following code", {id = "generate-detailed-description"}),
    h.option("use better names for all provided variables and functions", {id = "suggest-better-naming"}),
    h.option("review the following code and make concise suggestions", {id = "review-code"}),
    h.option("simplify the following code", {id = "simplify-code"}),
    h.option("improve the following code", {id = "improve-code"})
  }

  if #diags > 0 then
    table.insert(data, 3, h.option("learn more about the following issue", {id = "issue"}))
  end

  local body =
    h.rows(
    h.select(
      {
        size = 8,
        focus = true,
        id = "type",
        label = "Hey, Ollama, I'd like to…",
        shrink_to = 1,
        data = data,
        default_value = {"chat"}
      }
    ),
    h.text_input(
      {
        flex = 1,
        id = "issue",
        label = {
          text = "Issue",
          icon = ""
        },
        wrap = true,
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
        on_state_change = function(state)
          local id = state.type[1].id

          return {
            hidden = #diags == 0 or not (id == "issue")
          }
        end
      }
    ),
    h.text_input(
      {
        flex = 1,
        id = "chat",
        label = {
          text = "Chat",
          icon = "󰭻"
        },
        wrap = true,
        on_state_change = function(state)
          local id = state.type[1].id
          return {
            hidden = not (id == "chat")
          }
        end
      }
    ),
    h.text_input(
      {
        flex = 1,
        id = "question",
        label = {
          text = "Question",
          icon = ""
        },
        wrap = true,
        on_state_change = function(state)
          local id = state.type[1].id
          return {
            hidden = not (id == "ask")
          }
        end
      }
    ),
    h.text_input(
      {
        flex = 2,
        id = "text",
        label = {
          text = "Text",
          icon = "󰦨"
        },
        default_value = register,
        wrap = true,
        on_state_change = function(state)
          local hidden =
            not fn.isome(
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

          return {
            hidden = hidden
          }
        end
      }
    ),
    h.text_input(
      {
        flex = 1,
        id = "code",
        label = {
          text = "Code",
          icon = ""
        },
        default_value = register,
        filetype = vim.bo.filetype,
        on_state_change = function(state)
          local hidden =
            not fn.isome(
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

          return {
            hidden = hidden
          }
        end
      }
    )
  )

  h:render(body)
end

return M
