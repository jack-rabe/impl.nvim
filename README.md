# impl.nvim

A Neovim Plugin to streamline implementing interfaces in Go.

## Requirements
- Neovim 0.9 or greater
- Go 1.16 or greater
- luarocks 3.11 or greater

## Installation

First, install `impl` to generate a list of available interfaces.

```
go install github.com/jack-rabe/impl@latest
```

Then, use your preferred method or plugin manager to install [impl.nvim](https://github.com/jack-rabe/impl.nvim/).
It looks like this for [lazy.nvim](https://github.com/folke/lazy.nvim).

```lua
-- init.lua:
{
    'jack-rabe/impl.nvim',
    dependencies = {
      'nvim-telescope/telescope.nvim',
    }
}
```

## Usage
- Run the command `ImplGenerate stdlib` to generate a list of all the interfaces in the standard library.
- Run the command `ImplGenerate project` to generate a list of all the interfaces in your current git repo.
- Run the command `ImplSearch` while your cursor is on top of a type definition to fuzzy find a list of available interfaces to implement. The necessary methods will be added once an interface is selected.
  - Note: it is possible to change the appearance of the [telescope](https://github.com/nvim-telescope/telescope.nvim) finder by calling `impl.setup`.
```lua
require('impl').setup({
  layout_strategy = 'vertical',
  layout_config = { width = 0.5 }
})
```
 [lazy.nvim](https://github.com/folke/lazy.nvim) will call `setup` automatically if you specify opts.

## Demo

https://github.com/jack-rabe/impl.nvim/assets/76982748/04610721-f426-46de-a635-f974c8d35e05
