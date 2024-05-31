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
- Run the command `ImplGenerate` to generate a list of all the interfaces in the standard library
- Run the command `ImplSearch` while your cursor is on top of a type definition to fuzzy find a list of available interfaces to implement. The necessary methods will be added once an interface is selected

## Demo

https://github.com/jack-rabe/impl.nvim/assets/76982748/b8c0a82a-aa17-4ca8-bbd0-197c3dc42573
