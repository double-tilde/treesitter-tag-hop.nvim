--- Tag jumping utility for HTML files using Tree-sitter.
-- Allows jumping between matching or indented HTML tags.

local config = {
  filetypes = { "html" },
  skip_matching = 1,
  show_messages = false,
}

local M = {}

--- Retrieves the tag node (start or end) at the current cursor position.
-- @return TSNode|nil The current tag node under the cursor, or nil if not found.
local function get_tag()
  local node = vim.treesitter.get_node()

  while node do
    local node_type = node:type()
    if node_type == "start_tag" or node_type == "end_tag" then
      return node
    end
    node = node:parent()
  end
end

--- Finds the matching tag node for a given start or end tag.
-- @param node TSNode The tag node (start_tag or end_tag).
-- @return TSNode|nil The matching tag node, or nil if not found.
local function get_matching_tag_node(node)
  local parent = node:parent()
  if not parent then
    return
  end

  local node_type = node:type()

  for child in parent:iter_children() do
    if child ~= node then
      local child_type = child:type()
      if
          (node_type == "start_tag" and child_type == "end_tag")
          or (node_type == "end_tag" and child_type == "start_tag")
      then
        return child
      end
    end
  end
end

--- Moves the cursor to the given tag node.
-- @param tag_node TSNode The node to move the cursor to.
local function goto_tag(tag_node)
  if not tag_node then
    return
  end
  local start_row, start_col = tag_node:start()

  for i = 0, tag_node:child_count() - 1 do
    local node_tag_name = tag_node:child(i)
    if node_tag_name:type() == "tag_name" then
      start_row, start_col = node_tag_name:start()
      break
    end
  end

  vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
end

--- Moves the cursor to the next or previous tag node with the same indentation.
-- Useful for navigating structurally similar tags.
-- @param node TSNode The current tag node.
-- @param flipped boolean to change direction of hopping, optional.
local function goto_indented(node, flipped)
  local node_type = node:type()
  local direction = node_type == "start_tag" and -1 or 1
  if flipped then
    direction = node_type == "start_tag" and 1 or -1
  end

  local parent = node:parent()
  if not parent then
    return
  end

  local sibling = direction == 1 and parent:next_sibling()
      or parent:prev_sibling()

  local count = sibling:child_count()
  local child = direction == 1 and sibling:child(0) or sibling:child(count - 1)
  local child_row, child_col = child:start()

  for i = 0, child:child_count() - 1 do
    local child_tag_name = child:child(i)
    if child_tag_name:type() == "tag_name" then
      child_row, child_col = child_tag_name:start()
      break
    end
  end

  vim.api.nvim_win_set_cursor(0, { child_row + 1, child_col })
end


--- Jumps the cursor to the matching tag node (start or end).
-- @param node TSNode The current tag node.
local function goto_matching(node)
  local match = get_matching_tag_node(node)

  if not match then
    goto_indented(node)
    return
  end

  local start_row = node:start()
  local end_row = match:start()

  if start_row > end_row then
    start_row = match:start()
    end_row = node:start()
  end

  if (config.skip_matching > 0) then
    if (end_row - start_row <= config.skip_matching) then
      goto_indented(node, true)
      return
    end
  end

  goto_tag(match)
end

--- Jumps the cursor to a matching or indented tag based on direction.
-- @param dir string Direction to jump: `"next"` or `"prev"`.
function M.jump_tag(dir)
  local ft = vim.bo.filetype
  if not vim.tbl_contains(config.filetypes, ft) then
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local parser = vim.treesitter.get_parser(bufnr)
  parser:parse()

  local node = get_tag()
  if node ~= nil then
    if (node:type() == "start_tag" and dir == "next") or (node:type() == "end_tag" and dir == "prev") then
      if config.show_messages then
        vim.notify("jump_tag - matching: " .. tostring(node), vim.log.levels.INFO)
      end
      goto_matching(node)
    elseif (node:type() == "start_tag" and dir == "prev") or (node:type() == "end_tag" and dir == "next") then
      if config.show_messages then
        vim.notify("jump_tag - indented: " .. tostring(node), vim.log.levels.INFO)
      end
      goto_indented(node)
    end
  end
end

--- Sets up the module with user-defined configuration.
-- @param user_config table Optional table to override default config.
function M.setup(user_config)
  config = vim.tbl_deep_extend("force", config, user_config or {})
end

return {
  setup = M.setup,
  jump_tag = M.jump_tag,
  M,
}
