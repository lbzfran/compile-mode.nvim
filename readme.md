
# Compile-Mode

My own implementation of Emac's Compilation Mode in Neovim.

Contains 3 functions:

`:Compile <args>`

Calls a temporary buffer that executes the arguments its given.
The arguments are temporarily stored during the current session.

`:Recompile`

Re-executes the last arguments passed to the Compile command.

`:ToggleCompileSplit`

By default, the window of the temporary buffer spawns vertically.
Running this will toggle it between horizontal and vertical window.