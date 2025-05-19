# 🌿 treesitter-tag-hop.nvim

A lightweight Neovim plugin that lets you jump between matching HTML tags or navigate tag blocks at the same indentation level, powered by Tree-sitter.

## Features

- Jump between matching HTML tags (`<div> ⇄ </div>`)
- Navigate up and down tags at the same indentation level
- Powered by nvim-treesitter

## Installation

### lazy.nvim

```lua
{
  "double-tilde/treesitter-tag-hop.nvim",
  config = function()
    require("treesitter-tag-hop").setup({
      filetypes = { "html" }, -- customize supported filetypes
      show_messages = false, -- toggle debug messages
    })
  end
}
```

### packer.nvim

```lua
use({
  "double-tilde/treesitter-tag-hop.nvim",
  config = function()
    require("treesitter-tag-hop").setup({
      filetypes = { "html" },
      show_messages = false,
    })
  end
})
```

### vim-plug

```vim
Plug 'double-tilde/treesitter-tag-hop.nvim'
```

Then in your init.lua or init.vim:

```lua
require("treesitter-tag-hop").setup()
```

## Usage

Create keymaps to jump forward or backward between tags:

```lua
vim.keymap.set({ "n", "v" }, "]t", function() require("treesitter-tag-hop").jump_tag("next") end, { desc = "Jump to next tag" })
vim.keymap.set({ "n", "v" }, "[t", function() require("treesitter-tag-hop").jump_tag("prev") end, { desc = "Jump to previous tag" })
```

### Behavior:


| Current Tag Type | Direction | Action                   |
|------------------|-----------|--------------------------|
| `<start_tag>`    | next      | Jump to `</end_tag>`     |
| `<start_tag>`    | prev      | Jump to indented up      |
| `</end_tag>`     | prev      | Jump to `<start_tag>`    |
| `</end_tag>`     | next      | Jump to indented down    |


### Default Configuration

```lua
require("treesitter-tag-hop").setup({
  filetypes = { "html" },  -- List of filetypes to enable plugin
  show_messages = false,   -- Show debug messages via vim.notify
})
```

#### Requirements

- Neovim 0.8+
- nvim-treesitter properly installed and configured
- Tree-sitter parser for html installed (:TSInstall html)

#### License

MIT License.
