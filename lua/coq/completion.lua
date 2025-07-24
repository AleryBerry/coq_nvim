local function mark_lua_function(fn)
  fn._lua_origin = true
  return fn
end

local function get_custom_format()
  -- Check both possible locations for custom format
  if vim.g.coq_settings and type(vim.g.coq_settings.custom_format) == "function" then
    return vim.g.coq_settings.custom_format
  end
  return nil
end
(function(...)
  COQ.send_comp = function(col, items)
    vim.schedule(
      function()
        local legal_modes = {
          ["i"] = true,
          ["ic"] = true,
          ["ix"] = true
        }
        local legal_cmodes = {
          [""] = true,
          ["eval"] = true,
          ["function"] = true,
          ["ctrl_x"] = true
        }
        local mode = vim.api.nvim_get_mode().mode
        local comp_mode = vim.fn.complete_info({ "mode" }).mode
        if legal_modes[mode] and legal_cmodes[comp_mode] then
          -- when `#items ~= 0` there is something to show
          -- when `#items == 0` but `comp_mode == "eval"` there is something to close
          if #items ~= 0 or comp_mode == "eval" then
            -- Apply custom formatting if defined
            local custom_format = get_custom_format()
            if custom_format then
              local formatted_items = {}
              if custom_format then
                for _, item in ipairs(items) do
                  item = custom_format(item)
                end
              end
              items = formatted_items
            end

            vim.fn.complete(col, items)
          end
        end
      end
    )
  end
end)(...)
