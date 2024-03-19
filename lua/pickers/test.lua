local n = require("nui-components")

local M = {}

M.toggle = function()
  local renderer =
    n.create_renderer(
    {
      width = 80,
      height = 40
    }
  )

  renderer:add_mappings(
    {
      {
        mode = {"n", "i"},
        from = "<leader>c",
        to = function()
          renderer:close()
        end
      }
    }
  )

  local data = {
    n.option("chit-chat", {id = "chat"}),
    n.option("ask regarding the following text/code", {id = "ask"}),
    n.separator("󰦨 text "),
    n.option("modify the following text to improve grammar and spelling", {id = "enhance-grammar"}),
    n.option("modify the following text to use better wording", {id = "enhance-wording"}),
    n.option("modify the following text to make it as simple and concise as possible", {id = "make-concise"}),
    n.separator("󰅪 code "),
    n.option("generate a simple and concise description of the following code", {id = "generate-simple-description"}),
    n.option("generate a detailed description of the following code", {id = "generate-detailed-description"}),
    n.option("use better names for all provided variables and functions", {id = "suggest-better-naming"}),
    n.option("review the following code and make concise suggestions", {id = "review-code"}),
    n.option("simplify the following code", {id = "simplify-code"}),
    n.option("improve the following code", {id = "improve-code"})
  }

  local signal =
    n.create_signal(
    {
      checkbox = true,
      text = "hello world",
      button_text = "Close",
      toggle_flex = false,
      text_content = "Hello there",
      data = data,
      selected_nodes = {"chat"}
    }
  )

  local subscription =
    signal:observe(
    function(prev, current)
      require("fidget").notify(vim.inspect({prev.text, current.text}))
    end,
    400
  )

  renderer:on_unmount(
    function()
      subscription:unsubscribe()
    end
  )

  local body =
    n.rows(
    n.columns(
      {flex = 0},
      n.button(
        {
          label = "First",
          on_press = function()
            signal.toggle_flex = not signal.toggle_flex:get()
          end
        }
      ),
      n.gap(1),
      n.button(
        {
          label = "Second",
          on_press = function()
            renderer:set_size({width = 100, height = 60})
          end
        }
      ),
      n.gap({flex = 1}),
      n.button(
        {
          label = signal.button_text,
          on_press = function()
            local data = vim.deepcopy(signal.data:get())
            local id = tostring(math.random())
            table.insert(data, 1, n.option(id, {id = id}))
            -- vim.notify(vim.inspect(signal.data:get()))
            signal.data = data
          end,
          focus_key = "<D-1>"
        }
      )
    ),
    n.columns(
      {flex = 3},
      n.rows(
        n.prompt(
          {
            on_submit = function(v)
              print(v)
            end
          }
        ),
        n.text_input(
          {
            focus = true,
            flex = 1,
            value = signal.text,
            id = "t1",
            border_icon = "",
            border_label = "Code",
            border_style = "rounded",
            max_lines = 5,
            on_change = function(value)
              signal.text = value
            end,
            on_mount = function(c)
              c:set_border_text("bottom", "hello", "right")
            end
          }
        ),
        n.text_input(
          {
            -- flex = signal.toggle_flex:map(
            --   function(value)
            --     return value and 2 or 1
            --   end
            -- ),
            flex = 1,
            max_lines = 3,
            id = "t3",
            border_label = "State",
            value = signal.text
          }
        ),
        n.gap(1),
        n.text(
          {
            content = signal.text_content
          }
        ),
        n.gap(1),
        n.checkbox(
          {
            id = "checkbox2",
            label = "is checkbox checked?\n(check me)",
            value = signal.checkbox
          }
        ),
        n.checkbox(
          {
            id = "checkbox",
            label = "check me",
            value = signal.checkbox,
            on_change = function(is_checked)
              signal.checkbox = is_checked
            end
          }
        ),
        n.gap(1),
        n.select(
          {
            size = 10,
            -- focus = true,
            id = "type",
            border_label = "Hey, Ollama, I'd like to…",
            collapse_on_blur_to = 1,
            selected = {"chat"},
            data = signal.data,
            multiselect = true,
            on_select = function(nodes)
              signal.selected_nodes = nodes
            end
          }
        )
      ),
      n.rows(
        {flex = 1},
        n.select(
          {
            size = 10,
            -- focus = true,
            key = "type",
            border_label = "Custom select component",
            data = data,
            selected = signal.selected_nodes,
            on_select = function(nodes)
              signal.selected_nodes = nodes
            end
          }
        ),
        n.columns(
          n.text_input(
            {
              flex = 1,
              border_label = "Button text",
              on_change = function(value)
                signal.button_text = value
              end
            }
          ),
          n.rows(
            n.text_input(
              {
                id = "r1",
                flex = 1,
                border_label = "Text content",
                hidden = signal.checkbox,
                on_change = function(value)
                  signal.text_content = value
                end
              }
            ),
            n.text_input(
              {
                id = "r2",
                flex = 1,
                border_label = "Code",
                hidden = signal.text:map(
                  function(v)
                    return v == "hide me"
                  end
                )
              }
            )
          )
        )
      )
    )
  )

  renderer:render(body)
end

return M
