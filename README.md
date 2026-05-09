# 🌿 treesitter-tag-hop.nvim

A lightweight Neovim plugin that lets you jump between matching HTML tags or navigate tag blocks at the same indentation level, powered by Tree-sitter.

> [!IMPORTANT]
> Release 1.1.0 supports Neovim 0.12+

## Features

- Jump between matching HTML tags (`<div> ⇄ </div>`)
- Navigate up and down tags at the same indentation level
- Skip smaller jumps for faster navigation
- Powered by nvim-treesitter

## Installation

Go to the [default configuration](#default-configuration) below to see the defaults and descriptions

### lazy.nvim

```lua
{
  "double-tilde/treesitter-tag-hop.nvim",
  config = function()
    require("treesitter-tag-hop").setup({
      filetypes = { "html", "php", "htmlhugo" },
      skip_matching = 2,
      show_messages = false,
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
      filetypes = { "html", "php" },
      skip_matching = 1,
      show_messages = true,
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

| Current Tag Type | Direction | Action                |
| ---------------- | --------- | --------------------- |
| `<start_tag>`    | next      | Jump to `</end_tag>`  |
| `<start_tag>`    | prev      | Jump to indented up   |
| `</end_tag>`     | prev      | Jump to `<start_tag>` |
| `</end_tag>`     | next      | Jump to indented down |

### Default Configuration

```lua
require("treesitter-tag-hop").setup({
  filetypes = { "html" }, -- List of filetypes to enable plugin.
  skip_matching = 1,      -- If the matching tag is 1 row away or less, skip to
                          -- the next element instead. Set to 0 to disable.
  show_messages = false,  -- Show debug messages via vim.notify.
})
```

#### Requirements

- Neovim 0.12+ (tag-hop may still work with older versions but this is untested)
- nvim-treesitter properly installed and configured (the latest version of treesitter requires `treesitter-cli` to be installed, see nvim-treesitter docs)
- Tree-sitter parser for html installed (:TSInstall html)

#### License

MIT License.
