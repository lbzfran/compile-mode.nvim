
# Compile-Mode

My own implementation of Emac's Compilation Mode in Neovim.

## Functionality

Contains 3 functions:

`:Compile <args>`

Calls a temporary buffer that executes the arguments its given.

The buffer can be closed with `q` when it's in focus.

The passed arguments are temporarily stored during the current session,
and replaced everytime a new set of arguments are given to the command.

`:Recompile`

Re-executes the last arguments passed to the Compile command.

This command is mapped to `<leader>g` by default (currently hardcoded).

`:ToggleCompileSplit`

By default, the window of the temporary buffer spawns vertically.
Running this will toggle it between horizontal and vertical window.

## Installation

Simply add using your favorite package manager:

```lua
-- lazy.nvim
return {
  "lbzfran/compile-mode.nvim",
  config function()
    require("compile-mode").setup()
  end
}
```
